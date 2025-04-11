mod details;
mod summary;

pub use details::advisory_vulnerability::*;
pub use details::*;
pub use summary::*;

use crate::{Error, organization::model::OrganizationSummary};
use sea_orm::{ConnectionTrait, LoaderTrait, ModelTrait, prelude::Uuid};
use serde::{Deserialize, Serialize};
use time::OffsetDateTime;
use tracing::instrument;
use trustify_common::memo::Memo;
use trustify_entity::{advisory, labels::Labels, organization};
use utoipa::ToSchema;

#[derive(Serialize, Deserialize, Debug, Clone, ToSchema, PartialEq, Eq)]
pub struct AdvisoryHead {
    /// The opaque UUID of the advisory.
    #[serde(with = "uuid::serde::urn")]
    #[schema(value_type=String)]
    pub uuid: Uuid,

    /// The identifier of the advisory, as assigned by the issuing organization.
    pub identifier: String,

    /// The identifier of the advisory, as provided by the document.
    pub document_id: String,

    /// The issuer of the advisory, if known. If no issuer is able to be
    /// determined, this field will not be included in a response.
    #[schema(required)]
    pub issuer: Option<OrganizationSummary>,

    /// The date (in RFC3339 format) of when the advisory was published, if any.
    #[schema(required)]
    #[serde(with = "time::serde::rfc3339::option")]
    pub published: Option<OffsetDateTime>,

    /// The date (in RFC3339 format) of when the advisory was last modified, if any.
    #[serde(with = "time::serde::rfc3339::option")]
    pub modified: Option<OffsetDateTime>,

    /// The date (in RFC3339 format) of when the advisory was withdrawn, if any.
    #[schema(required)]
    #[serde(with = "time::serde::rfc3339::option")]
    pub withdrawn: Option<OffsetDateTime>,

    /// The title of the advisory as assigned by the issuing organization.
    #[schema(required)]
    pub title: Option<String>,

    /// Informational labels attached by the system or users to this advisory.
    pub labels: Labels,
}

impl AdvisoryHead {
    #[instrument(skip_all, fields(advisory.id = ?advisory.id), err(level=tracing::Level::INFO))]
    pub async fn from_advisory<C: ConnectionTrait>(
        advisory: &advisory::Model,
        issuer: Memo<organization::Model>,
        tx: &C,
    ) -> Result<Self, Error> {
        let issuer = match &issuer {
            Memo::Provided(Some(issuer)) => Some(OrganizationSummary::from_entity(issuer)),
            Memo::Provided(None) => None,
            Memo::NotProvided => advisory
                .find_related(organization::Entity)
                .one(tx)
                .await?
                .map(|issuer| OrganizationSummary::from_entity(&issuer)),
        };

        Ok(Self {
            uuid: advisory.id,
            identifier: advisory.identifier.clone(),
            document_id: advisory.document_id.clone(),
            issuer,
            published: advisory.published,
            modified: advisory.modified,
            withdrawn: advisory.withdrawn,
            title: advisory.title.clone(),
            labels: advisory.labels.clone(),
        })
    }

    pub async fn from_entities<C: ConnectionTrait>(
        entities: &[advisory::Model],
        tx: &C,
    ) -> Result<Vec<Self>, Error> {
        let mut heads = Vec::new();

        let issuers = entities.load_one(organization::Entity, tx).await?;

        for (advisory, issuer) in entities.iter().zip(issuers) {
            let issuer = issuer.map(|issuer| OrganizationSummary::from_entity(&issuer));

            heads.push(Self {
                uuid: advisory.id,
                identifier: advisory.identifier.clone(),
                document_id: advisory.document_id.clone(),
                issuer,
                published: advisory.published,
                modified: advisory.modified,
                withdrawn: advisory.withdrawn,
                title: advisory.title.clone(),
                labels: advisory.labels.clone(),
            })
        }

        Ok(heads)
    }
}
