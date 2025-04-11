mod config;
mod label;
#[cfg(test)]
mod test;

use crate::{
    Error,
    advisory::{
        model::{AdvisoryDetails, AdvisorySummary},
        service::AdvisoryService,
    },
    endpoints::Deprecation,
    purl::service::PurlService,
};
use actix_web::{HttpResponse, Responder, delete, get, http::header, post, web};
use config::Config;
use futures_util::TryStreamExt;
use sea_orm::TransactionTrait;
use std::str::FromStr;
use trustify_auth::{CreateAdvisory, DeleteAdvisory, ReadAdvisory, authorizer::Require};
use trustify_common::{
    db::{Database, query::Query},
    decompress::decompress_async,
    id::Id,
    model::{BinaryData, Paginated, PaginatedResults},
};
use trustify_entity::labels::Labels;
use trustify_module_ingestor::service::{Format, IngestorService};
use trustify_module_storage::service::StorageBackend;
use utoipa::IntoParams;

pub fn configure(
    config: &mut utoipa_actix_web::service_config::ServiceConfig,
    db: Database,
    upload_limit: usize,
) {
    let advisory_service = AdvisoryService::new(db.clone());
    let purl_service = PurlService::new();

    config
        .app_data(web::Data::new(db))
        .app_data(web::Data::new(advisory_service))
        .app_data(web::Data::new(purl_service))
        .app_data(web::Data::new(Config { upload_limit }))
        .service(all)
        .service(get)
        .service(delete)
        .service(upload)
        .service(download)
        .service(label::set)
        .service(label::update);
}

#[utoipa::path(
    tag = "advisory",
    operation_id = "listAdvisories",
    params(
        Query,
        Paginated,
        Deprecation,
    ),
    responses(
        (status = 200, description = "Matching vulnerabilities", body = PaginatedResults<AdvisorySummary>),
    ),
)]
#[get("/v2/advisory")]
/// List advisories
pub async fn all(
    state: web::Data<AdvisoryService>,
    db: web::Data<Database>,
    web::Query(search): web::Query<Query>,
    web::Query(paginated): web::Query<Paginated>,
    web::Query(Deprecation { deprecated }): web::Query<Deprecation>,
    _: Require<ReadAdvisory>,
) -> actix_web::Result<impl Responder> {
    Ok(HttpResponse::Ok().json(
        state
            .fetch_advisories(search, paginated, deprecated, db.as_ref())
            .await?,
    ))
}

#[utoipa::path(
    tag = "advisory",
    operation_id = "getAdvisory",
    params(
        ("key" = Id, Path),
    ),
    responses(
        (status = 200, description = "Matching advisory", body = AdvisoryDetails),
        (status = 404, description = "Matching advisory not found"),
    ),
)]
#[get("/v2/advisory/{key}")]
/// Get an advisory
pub async fn get(
    state: web::Data<AdvisoryService>,
    db: web::Data<Database>,
    key: web::Path<String>,
    _: Require<ReadAdvisory>,
) -> actix_web::Result<impl Responder> {
    let hash_key = Id::from_str(&key).map_err(Error::IdKey)?;
    let fetched = state.fetch_advisory(hash_key, db.as_ref()).await?;

    if let Some(fetched) = fetched {
        Ok(HttpResponse::Ok().json(fetched))
    } else {
        Ok(HttpResponse::NotFound().finish())
    }
}

#[utoipa::path(
    tag = "advisory",
    operation_id = "deleteAdvisory",
    params(
        ("key" = Id, Path),
    ),
    responses(
        (status = 200, description = "Matching advisory", body = AdvisoryDetails),
        (status = 404, description = "Matching advisory not found"),
    ),
)]
#[delete("/v2/advisory/{key}")]
/// Delete an advisory
pub async fn delete(
    state: web::Data<AdvisoryService>,
    db: web::Data<Database>,
    purl_service: web::Data<PurlService>,
    key: web::Path<String>,
    _: Require<DeleteAdvisory>,
) -> Result<impl Responder, Error> {
    let tx = db.begin().await?;

    let hash_key = Id::from_str(&key)?;
    let fetched = state.fetch_advisory(hash_key, &tx).await?;

    if let Some(fetched) = fetched {
        let rows_affected = state.delete_advisory(fetched.head.uuid, &tx).await?;
        match rows_affected {
            0 => Ok(HttpResponse::NotFound().finish()),
            1 => {
                let _ = purl_service.gc_purls(&tx).await; // ignore gc failure..
                tx.commit().await?;
                Ok(HttpResponse::Ok().json(fetched))
            }
            _ => Err(Error::Internal("Unexpected number of rows affected".into())),
        }
    } else {
        Ok(HttpResponse::NotFound().finish())
    }
}

#[derive(
    IntoParams, Clone, Debug, Default, PartialEq, Eq, serde::Serialize, serde::Deserialize,
)]
struct UploadParams {
    /// Optional issuer if it cannot be determined from advisory contents.
    #[serde(default)]
    issuer: Option<String>,
    /// Optional labels.
    ///
    /// Only use keys with a prefix of `labels.`
    #[serde(flatten, with = "trustify_entity::labels::prefixed")]
    labels: Labels,
}

#[utoipa::path(
    tag = "advisory",
    operation_id = "uploadAdvisory",
    request_body = inline(BinaryData),
    params(UploadParams),
    responses(
        (status = 201, description = "Upload a file"),
        (status = 400, description = "The file could not be parsed as an advisory"),
    )
)]
#[post("/v2/advisory")]
/// Upload a new advisory
pub async fn upload(
    service: web::Data<IngestorService>,
    config: web::Data<Config>,
    web::Query(UploadParams { issuer, labels }): web::Query<UploadParams>,
    content_type: Option<web::Header<header::ContentType>>,
    bytes: web::Bytes,
    _: Require<CreateAdvisory>,
) -> Result<impl Responder, Error> {
    let bytes = decompress_async(bytes, content_type.map(|ct| ct.0), config.upload_limit).await??;
    let result = service
        .ingest(&bytes, Format::Advisory, labels, issuer)
        .await?;
    log::info!("Uploaded Advisory: {}", result.id);
    Ok(HttpResponse::Created().json(result))
}

#[utoipa::path(
    tag = "advisory",
    operation_id = "downloadAdvisory",
    params(
        ("key" = Id, Path),
    ),
    responses(
        (status = 200, description = "Download a an advisory", body = inline(BinaryData)),
        (status = 404, description = "The document could not be found"),
    )
)]
#[get("/v2/advisory/{key}/download")]
/// Download an advisory document
pub async fn download(
    db: web::Data<Database>,
    ingestor: web::Data<IngestorService>,
    advisory: web::Data<AdvisoryService>,
    key: web::Path<String>,
    _: Require<ReadAdvisory>,
) -> Result<impl Responder, Error> {
    // the user requested id
    let id = Id::from_str(&key).map_err(Error::IdKey)?;

    // look up document by id
    let Some(advisory) = advisory.fetch_advisory(id, db.as_ref()).await? else {
        return Ok(HttpResponse::NotFound().finish());
    };

    if let Some(doc) = &advisory.source_document {
        let stream = ingestor
            .get_ref()
            .storage()
            .clone()
            .retrieve(doc.try_into()?)
            .await
            .map_err(Error::Storage)?
            .map(|stream| stream.map_err(Error::Storage));

        Ok(match stream {
            Some(s) => HttpResponse::Ok().streaming(s),
            None => HttpResponse::NotFound().finish(),
        })
    } else {
        Ok(HttpResponse::NotFound().finish())
    }
}
