use super::SbomService;
use crate::{
    Error,
    sbom::model::{
        SbomExternalPackageReference, SbomNodeReference, SbomPackage, SbomPackageRelation,
        SbomSummary, Which, details::SbomDetails,
    },
};
use futures_util::{StreamExt, TryStreamExt, stream};
use sea_orm::{
    ColumnTrait, ConnectionTrait, DbErr, EntityTrait, FromQueryResult, IntoSimpleExpr, QueryFilter,
    QueryOrder, QueryResult, QuerySelect, RelationTrait, Select, SelectColumns, StreamTrait,
    prelude::Uuid,
};
use sea_query::{Expr, JoinType, extension::postgres::PgExpr};
use serde_json::Value;
use std::{collections::HashMap, fmt::Debug};
use tracing::instrument;
use trustify_common::{
    cpe::Cpe,
    db::{
        limiter::{LimiterTrait, limit_selector},
        multi_model::{FromQueryResultMultiModel, SelectIntoMultiModel},
        query::{Columns, Filtering, IntoColumns, Query},
    },
    id::{Id, TrySelectForId},
    model::{Paginated, PaginatedResults},
    purl::Purl,
};
use trustify_entity::{
    advisory, advisory_vulnerability, base_purl,
    cpe::{self, CpeDto},
    labels::Labels,
    organization, package_relates_to_package,
    qualified_purl::{self, CanonicalPurl},
    relationship::Relationship,
    sbom::{self, SbomNodeLink},
    sbom_node, sbom_package, sbom_package_cpe_ref, sbom_package_purl_ref, source_document, status,
    versioned_purl, vulnerability,
};

impl SbomService {
    #[instrument(skip(self, connection), err(level=tracing::Level::INFO))]
    async fn fetch_sbom<C: ConnectionTrait>(
        &self,
        id: Id,
        connection: &C,
    ) -> Result<Option<(sbom::Model, Option<sbom_node::Model>)>, Error> {
        let select = sbom::Entity::find()
            .join(JoinType::LeftJoin, sbom::Relation::SourceDocument.def())
            .try_filter(id)?;

        Ok(select
            .find_also_linked(SbomNodeLink)
            .one(connection)
            .await?)
    }

    /// fetch one sbom
    #[instrument(skip(self, connection), err(level=tracing::Level::INFO))]
    pub async fn fetch_sbom_details<C>(
        &self,
        id: Id,
        statuses: Vec<String>,
        connection: &C,
    ) -> Result<Option<SbomDetails>, Error>
    where
        C: ConnectionTrait + StreamTrait,
    {
        Ok(match self.fetch_sbom(id, connection).await? {
            Some(row) => SbomDetails::from_entity(row, self, connection, statuses).await?,
            None => None,
        })
    }

    /// fetch the summary of one sbom
    pub async fn fetch_sbom_summary<C: ConnectionTrait>(
        &self,
        id: Id,
        connection: &C,
    ) -> Result<Option<SbomSummary>, Error> {
        Ok(match self.fetch_sbom(id, connection).await? {
            Some(row) => SbomSummary::from_entity(row, self, connection).await?,
            None => None,
        })
    }

    /// delete one sbom
    pub async fn delete_sbom<C: ConnectionTrait>(
        &self,
        id: Uuid,
        connection: &C,
    ) -> Result<u64, Error> {
        let query = sbom::Entity::delete_by_id(id);

        let result = query.exec(connection).await?;

        Ok(result.rows_affected)
    }

    /// fetch all SBOMs
    pub async fn fetch_sboms<C: ConnectionTrait>(
        &self,
        search: Query,
        paginated: Paginated,
        labels: impl Into<Labels>,
        connection: &C,
    ) -> Result<PaginatedResults<SbomSummary>, Error> {
        let labels = labels.into();

        let query = if labels.is_empty() {
            sbom::Entity::find()
        } else {
            sbom::Entity::find().filter(Expr::col(sbom::Column::Labels).contains(labels))
        };
        let limiter = query
            .join(JoinType::Join, sbom::Relation::SourceDocument.def())
            .find_also_linked(SbomNodeLink)
            .filtering_with(
                search,
                Columns::from_entity::<sbom::Entity>()
                    .add_columns(sbom_node::Entity)
                    .add_columns(source_document::Entity)
                    .alias("sbom_node", "r0"),
            )?
            .limiting(connection, paginated.offset, paginated.limit);

        let total = limiter.total().await?;
        let sboms = limiter.fetch().await?;

        let items = stream::iter(sboms.into_iter())
            .then(|row| async { SbomSummary::from_entity(row, self, connection).await })
            .try_filter_map(futures_util::future::ok)
            .try_collect()
            .await?;

        Ok(PaginatedResults { total, items })
    }

    /// Fetch all packages from an SBOM.
    ///
    /// If you need to find packages based on their relationship, even in the relationship to
    /// SBOM itself, use [`Self::fetch_related_packages`].
    #[instrument(skip(self, connection), err(level=tracing::Level::INFO))]
    pub async fn fetch_sbom_packages<C: ConnectionTrait>(
        &self,
        sbom_id: Uuid,
        search: Query,
        paginated: Paginated,
        connection: &C,
    ) -> Result<PaginatedResults<SbomPackage>, Error> {
        let mut query = sbom_package::Entity::find()
            .filter(sbom_package::Column::SbomId.eq(sbom_id))
            .join(JoinType::Join, sbom_package::Relation::Node.def())
            .select_only()
            .column_as(sbom_package::Column::NodeId, "id")
            .group_by(sbom_package::Column::NodeId)
            .column_as(sbom_package::Column::Version, "version")
            .group_by(sbom_package::Column::Version)
            .column_as(sbom_node::Column::Name, "name")
            .group_by(sbom_node::Column::Name)
            .join(JoinType::LeftJoin, sbom_package::Relation::Purl.def())
            .join(JoinType::LeftJoin, sbom_package::Relation::Cpe.def());

        query = join_purls_and_cpes(query)
            .filtering_with(
                search,
                sbom_package::Entity
                    .columns()
                    .add_columns(sbom_node::Entity)
                    .add_columns(base_purl::Entity)
                    .add_columns(sbom_package_cpe_ref::Entity)
                    .add_columns(sbom_package_purl_ref::Entity),
            )?
            // default order
            .order_by_asc(sbom_node::Column::Name)
            .order_by_asc(sbom_package::Column::Version);

        // limit and execute

        let limiter = limit_selector::<'_, _, _, _, PackageCatcher>(
            connection,
            query,
            paginated.offset,
            paginated.limit,
        );

        let total = limiter.total().await?;
        let packages = limiter.fetch().await?;

        // collect results

        let mut items = Vec::new();

        for row in packages {
            items.push(package_from_row(row));
        }

        Ok(PaginatedResults { items, total })
    }

    /// Get all packages describing the SBOM.
    #[instrument(skip(self, db), err(level=tracing::Level::INFO))]
    pub async fn describes_packages<C: ConnectionTrait>(
        &self,
        sbom_id: Uuid,
        paginated: Paginated,
        db: &C,
    ) -> Result<PaginatedResults<SbomPackage>, Error> {
        self.fetch_related_packages(
            sbom_id,
            Default::default(),
            paginated,
            Which::Left,
            SbomNodeReference::All,
            Some(Relationship::Describes),
            db,
        )
        .await
        .map(|r| r.map(|rel| rel.package))
    }

    #[instrument(skip(self, connection), err(level=tracing::Level::INFO))]
    pub async fn count_related_sboms<C: ConnectionTrait>(
        &self,
        references: Vec<SbomExternalPackageReference<'_>>,
        connection: &C,
    ) -> Result<Vec<i64>, Error> {
        #[derive(Clone, Copy, PartialEq, Eq, Hash, Debug)]
        enum Id {
            Cpe(Uuid),
            Purl(Uuid),
        }

        let ids = references
            .iter()
            .map(|r| match r {
                SbomExternalPackageReference::Cpe(c) => Id::Cpe(c.uuid()),
                SbomExternalPackageReference::Purl(p) => Id::Purl(p.qualifier_uuid()),
            })
            .collect::<Vec<_>>();

        let mut counts_map = HashMap::new();

        let cpes = ids
            .iter()
            .filter_map(|id| match id {
                Id::Cpe(id) => Some(*id),
                _ => None,
            })
            .collect::<Vec<_>>();

        counts_map.extend(
            sbom::Entity::find()
                .join(JoinType::Join, sbom::Relation::Packages.def())
                .join(JoinType::Join, sbom_package::Relation::Cpe.def())
                .filter(sbom_package_cpe_ref::Column::CpeId.is_in(cpes))
                .group_by(sbom_package_cpe_ref::Column::CpeId)
                .select_only()
                .column(sbom_package_cpe_ref::Column::CpeId)
                .column_as(sbom_package::Column::SbomId.count(), "count")
                .into_tuple::<(Uuid, i64)>()
                .all(connection)
                .await?
                .into_iter()
                .map(|(id, count)| (Id::Cpe(id), count)),
        );

        let purls = ids
            .iter()
            .filter_map(|id| match id {
                Id::Purl(id) => Some(*id),
                _ => None,
            })
            .collect::<Vec<_>>();

        counts_map.extend(
            sbom::Entity::find()
                .join(JoinType::Join, sbom::Relation::Packages.def())
                .join(JoinType::Join, sbom_package::Relation::Purl.def())
                .filter(sbom_package_purl_ref::Column::QualifiedPurlId.is_in(purls))
                .group_by(sbom_package_purl_ref::Column::QualifiedPurlId)
                .select_only()
                .column(sbom_package_purl_ref::Column::QualifiedPurlId)
                .column_as(sbom_package::Column::SbomId.count(), "count")
                .into_tuple::<(Uuid, i64)>()
                .all(connection)
                .await?
                .into_iter()
                .map(|(id, count)| (Id::Purl(id), count)),
        );

        // now use the inbound order and retrieve results in that order

        let result: Vec<i64> = ids
            .into_iter()
            .map(|id| counts_map.get(&id).copied().unwrap_or_default())
            .collect();

        // return result

        Ok(result)
    }

    #[instrument(skip(self, connection), err(level=tracing::Level::INFO))]
    pub async fn find_related_sboms<C: ConnectionTrait>(
        &self,
        package_ref: SbomExternalPackageReference<'_>,
        paginated: Paginated,
        query: Query,
        connection: &C,
    ) -> Result<PaginatedResults<SbomSummary>, Error> {
        let select = sbom::Entity::find().join(JoinType::Join, sbom::Relation::Packages.def());

        let select = match package_ref {
            SbomExternalPackageReference::Purl(purl) => select
                .join(JoinType::Join, sbom_package::Relation::Purl.def())
                .filter(sbom_package_purl_ref::Column::QualifiedPurlId.eq(purl.qualifier_uuid())),
            SbomExternalPackageReference::Cpe(cpe) => select
                .join(JoinType::Join, sbom_package::Relation::Cpe.def())
                .filter(sbom_package_cpe_ref::Column::CpeId.eq(cpe.uuid())),
        };

        let query = select.find_also_linked(SbomNodeLink).filtering_with(
            query,
            Columns::from_entity::<sbom::Entity>()
                .add_columns(sbom_node::Entity)
                .alias("sbom_node", "r0"),
        )?;

        // limit and execute

        let limiter = query.limiting(connection, paginated.offset, paginated.limit);

        let total = limiter.total().await?;
        let sboms = limiter.fetch().await?;

        // collect results

        let items = stream::iter(sboms.into_iter())
            .then(|row| async { SbomSummary::from_entity(row, self, connection).await })
            .try_filter_map(futures_util::future::ok)
            .try_collect()
            .await?;

        Ok(PaginatedResults { items, total })
    }

    /// Fetch all related packages in the context of an SBOM.
    #[allow(clippy::too_many_arguments)]
    #[instrument(skip(self, db), err(level=tracing::Level::INFO))]
    pub async fn fetch_related_packages<C: ConnectionTrait>(
        &self,
        sbom_id: Uuid,
        search: Query,
        paginated: Paginated,
        which: Which,
        reference: impl Into<SbomNodeReference<'_>> + Debug,
        relationship: Option<Relationship>,
        db: &C,
    ) -> Result<PaginatedResults<SbomPackageRelation>, Error> {
        // which way

        log::debug!("Which: {which:?}");

        // select all qualified packages for which we have relationships

        let (filter, join) = match which {
            Which::Left => (
                package_relates_to_package::Column::LeftNodeId,
                package_relates_to_package::Relation::Right,
            ),
            Which::Right => (
                package_relates_to_package::Column::RightNodeId,
                package_relates_to_package::Relation::Left,
            ),
        };

        let mut query = package_relates_to_package::Entity::find()
            .filter(package_relates_to_package::Column::SbomId.eq(sbom_id))
            .select_only()
            .select_column_as(sbom_node::Column::NodeId, "id")
            .group_by(sbom_node::Column::NodeId)
            .select_column_as(sbom_node::Column::Name, "name")
            .group_by(sbom_node::Column::Name)
            .select_column_as(
                package_relates_to_package::Column::Relationship,
                "relationship",
            )
            .group_by(package_relates_to_package::Column::Relationship)
            .select_column_as(sbom_package::Column::Group, "group")
            .group_by(sbom_package::Column::Group)
            .select_column_as(sbom_package::Column::Version, "version")
            .group_by(sbom_package::Column::Version)
            // join the other side
            .join(JoinType::Join, join.def())
            .join(JoinType::Join, sbom_node::Relation::Package.def())
            .join(JoinType::LeftJoin, sbom_package::Relation::Purl.def())
            .join(JoinType::LeftJoin, sbom_package::Relation::Cpe.def());

        // collect PURLs and CPEs

        query = join_purls_and_cpes(query);

        // filter for reference

        query = match reference.into() {
            SbomNodeReference::All => {
                // sbom - add join to sbom table
                query.join(JoinType::Join, sbom_node::Relation::Sbom.def())
            }
            SbomNodeReference::Package(node_id) => {
                // package - set node id filter
                query.filter(filter.eq(node_id))
            }
        };

        // apply filter conditions

        query = query.filtering(search)?;

        // add relationship type filter

        if let Some(relationship) = relationship {
            query = query.filter(package_relates_to_package::Column::Relationship.eq(relationship));
        }

        // limit and execute

        let limiter = limit_selector::<'_, _, _, _, PackageCatcher>(
            db,
            query,
            paginated.offset,
            paginated.limit,
        );

        let total = limiter.total().await?;
        let packages = limiter.fetch().await?;

        // collect results

        let mut items = Vec::new();

        for row in packages {
            if let Some(relationship) = row.relationship {
                items.push(SbomPackageRelation {
                    relationship,
                    package: package_from_row(row),
                });
            }
        }

        Ok(PaginatedResults { items, total })
    }

    /// A simplified version of [`Self::fetch_related_packages`].
    ///
    /// It uses [`Which::Right`] and the provided reference, [`Default::default`] for the rest.
    pub async fn related_packages<C: ConnectionTrait>(
        &self,
        sbom_id: Uuid,
        relationship: impl Into<Option<Relationship>>,
        pkg: impl Into<SbomNodeReference<'_>> + Debug,
        tx: &C,
    ) -> Result<Vec<SbomPackage>, Error> {
        let result = self
            .fetch_related_packages(
                sbom_id,
                Default::default(),
                Default::default(),
                Which::Left,
                pkg,
                relationship.into(),
                tx,
            )
            .await?;

        // TODO: this will break when adding pagination, as we effectively only process a single page

        // turn into a map, removing duplicates

        let result: HashMap<_, _> = result
            .items
            .into_iter()
            .map(|r| (r.package.id.clone(), r.package))
            .collect();

        // take the de-duplicated values and return them

        Ok(result.into_values().collect())
    }
}

/// Join CPE and PURL information.
///
/// Given a select over something which already joins sbom_package_purl_ref and
/// sbom_package_cpe_ref, this adds joins to fetch the data for PURLs and CPEs so that it can be
/// built using [`package_from_row`].
///
/// This will add the columns `purls` and `cpes` to the selected output.
fn join_purls_and_cpes<E>(query: Select<E>) -> Select<E>
where
    E: EntityTrait,
{
    query
        .join(
            JoinType::LeftJoin,
            sbom_package_purl_ref::Relation::Purl.def(),
        )
        .join(
            JoinType::LeftJoin,
            qualified_purl::Relation::VersionedPurl.def(),
        )
        .join(JoinType::LeftJoin, versioned_purl::Relation::BasePurl.def())
        // aggregate the purls
        .select_column_as(
            Expr::cust_with_exprs(
                "coalesce(array_agg(distinct $1) filter (where $2), '{}')",
                [
                    qualified_purl::Column::Purl.into_simple_expr(),
                    sbom_package_purl_ref::Column::QualifiedPurlId
                        .is_not_null()
                        .into_simple_expr(),
                ],
            ),
            "purls",
        )
        .join(
            JoinType::LeftJoin,
            sbom_package_cpe_ref::Relation::Cpe.def(),
        )
        // aggregate the cpes
        .select_column_as(
            Expr::cust_with_exprs(
                "to_json(coalesce(array_agg(distinct $1) filter (where $2), '{}'))",
                [
                    Expr::col(cpe::Entity).into_simple_expr(),
                    sbom_package_cpe_ref::Column::CpeId.is_not_null(),
                ],
            ),
            "cpes",
        )
}

#[derive(FromQueryResult)]
struct PackageCatcher {
    id: String,
    name: String,
    group: Option<String>,
    version: Option<String>,
    purls: Vec<Value>,
    cpes: Value,
    relationship: Option<Relationship>,
}

/// Convert values from a "package row" into an SBOM package
fn package_from_row(row: PackageCatcher) -> SbomPackage {
    let purl = row
        .purls
        .into_iter()
        .flat_map(|purl| {
            serde_json::from_value::<CanonicalPurl>(purl.clone())
                .inspect_err(|err| {
                    log::warn!("Failed to deserialize PURL: {err}");
                })
                .ok()
        })
        .map(|purl| Purl::from(purl).into())
        .collect();

    let cpe = row
        .cpes
        .as_array()
        .into_iter()
        .flatten()
        .flat_map(|cpe| {
            serde_json::from_value::<CpeDto>(cpe.clone())
                .inspect_err(|err| {
                    log::warn!("Failed to deserialize CPE: {err}");
                })
                .ok()
        })
        .flat_map(|cpe| {
            log::debug!("CPE: {cpe:?}");
            Cpe::try_from(cpe)
                .inspect_err(|err| {
                    log::warn!("Failed to build CPE: {err}");
                })
                .ok()
        })
        .map(|cpe| cpe.to_string())
        .collect();

    SbomPackage {
        id: row.id,
        name: row.name,
        group: row.group,
        version: row.version,
        purl,
        cpe,
    }
}

#[derive(Debug)]
pub struct QueryCatcher {
    pub advisory: advisory::Model,
    pub qualified_purl: qualified_purl::Model,
    pub sbom_package: sbom_package::Model,
    pub sbom_node: sbom_node::Model,
    pub advisory_vulnerability: advisory_vulnerability::Model,
    pub vulnerability: vulnerability::Model,
    pub context_cpe: Option<cpe::Model>,
    pub status: status::Model,
    pub organization: Option<organization::Model>,
}

impl FromQueryResult for QueryCatcher {
    fn from_query_result(res: &QueryResult, _pre: &str) -> Result<Self, DbErr> {
        Ok(Self {
            advisory: Self::from_query_result_multi_model(res, "", advisory::Entity)?,
            advisory_vulnerability: Self::from_query_result_multi_model(
                res,
                "",
                advisory_vulnerability::Entity,
            )?,
            vulnerability: Self::from_query_result_multi_model(res, "", vulnerability::Entity)?,
            qualified_purl: Self::from_query_result_multi_model(res, "", qualified_purl::Entity)?,
            sbom_package: Self::from_query_result_multi_model(res, "", sbom_package::Entity)?,
            sbom_node: Self::from_query_result_multi_model(res, "", sbom_node::Entity)?,
            context_cpe: Self::from_query_result_multi_model_optional(res, "", cpe::Entity)?,
            status: Self::from_query_result_multi_model(res, "", status::Entity)?,
            organization: Self::from_query_result_multi_model_optional(
                res,
                "",
                organization::Entity,
            )?,
        })
    }
}

impl FromQueryResultMultiModel for QueryCatcher {
    fn try_into_multi_model<E: EntityTrait>(select: Select<E>) -> Result<Select<E>, DbErr> {
        select
            .try_model_columns(advisory::Entity)?
            .try_model_columns(advisory_vulnerability::Entity)?
            .try_model_columns(vulnerability::Entity)?
            .try_model_columns(base_purl::Entity)?
            .try_model_columns(versioned_purl::Entity)?
            .try_model_columns(qualified_purl::Entity)?
            .try_model_columns(sbom_package::Entity)?
            .try_model_columns(sbom_node::Entity)?
            .try_model_columns(status::Entity)?
            .try_model_columns(cpe::Entity)?
            .try_model_columns(organization::Entity)
    }
}

#[cfg(test)]
mod test {
    use super::*;
    use test_context::test_context;
    use test_log::test;
    use trustify_common::db::query::q;
    use trustify_common::hashing::Digests;
    use trustify_entity::labels::Labels;
    use trustify_test_context::TrustifyContext;

    #[test_context(TrustifyContext)]
    #[test(tokio::test)]
    async fn all_sboms(ctx: &TrustifyContext) -> Result<(), anyhow::Error> {
        let sbom_v1 = ctx
            .graph
            .ingest_sbom(
                Labels::default(),
                &Digests::digest("RHSA-1"),
                Some("http://redhat.com/test.json".to_string()),
                (),
                &ctx.db,
            )
            .await?;
        let sbom_v1_again = ctx
            .graph
            .ingest_sbom(
                Labels::default(),
                &Digests::digest("RHSA-1"),
                Some("http://redhat.com/test.json".to_string()),
                (),
                &ctx.db,
            )
            .await?;
        let sbom_v2 = ctx
            .graph
            .ingest_sbom(
                Labels::default(),
                &Digests::digest("RHSA-2"),
                Some("http://myspace.com/test.json".to_string()),
                (),
                &ctx.db,
            )
            .await?;

        let _other_sbom = ctx
            .graph
            .ingest_sbom(
                Labels::default(),
                &Digests::digest("RHSA-3"),
                Some("http://geocities.com/other.json".to_string()),
                (),
                &ctx.db,
            )
            .await?;

        assert_eq!(sbom_v1.sbom.sbom_id, sbom_v1_again.sbom.sbom_id);
        assert_ne!(sbom_v1.sbom.sbom_id, sbom_v2.sbom.sbom_id);

        let fetch = SbomService::new(ctx.db.clone());

        let fetched = fetch
            .fetch_sboms(
                q("MySpAcE").sort("name,authors,published"),
                Paginated::default(),
                (),
                &ctx.db,
            )
            .await?;

        log::debug!("{:#?}", fetched.items);
        assert_eq!(1, fetched.total);

        Ok(())
    }

    #[test_context(TrustifyContext)]
    #[test(tokio::test)]
    async fn labels(ctx: &TrustifyContext) -> Result<(), anyhow::Error> {
        let _sbom1 = ctx
            .graph
            .ingest_sbom(
                Labels::new()
                    .add("source", "test")
                    .add("ci", "job1")
                    .add("team", "a"),
                &Digests::digest("RHSA-1"),
                Some("http://redhat.com/test1.json".to_string()),
                (),
                &ctx.db,
            )
            .await?;

        let _sbom2 = ctx
            .graph
            .ingest_sbom(
                Labels::new()
                    .add("source", "test")
                    .add("ci", "job2")
                    .add("team", "b"),
                &Digests::digest("RHSA-2"),
                Some("http://redhat.com/test2.json".to_string()),
                (),
                &ctx.db,
            )
            .await?;

        let _sbom3 = ctx
            .graph
            .ingest_sbom(
                Labels::new()
                    .add("source", "test")
                    .add("ci", "job2")
                    .add("team", "a"),
                &Digests::digest("RHSA-3"),
                Some("http://redhat.com/test3.json".to_string()),
                (),
                &ctx.db,
            )
            .await?;

        let service = SbomService::new(ctx.db.clone());

        let fetched = service
            .fetch_sboms(
                Query::default(),
                Paginated::default(),
                ("ci", "job1"),
                &ctx.db,
            )
            .await?;
        assert_eq!(1, fetched.total);

        let fetched = service
            .fetch_sboms(
                Query::default(),
                Paginated::default(),
                ("ci", "job2"),
                &ctx.db,
            )
            .await?;
        assert_eq!(2, fetched.total);

        let fetched = service
            .fetch_sboms(
                Query::default(),
                Paginated::default(),
                ("ci", "job3"),
                &ctx.db,
            )
            .await?;
        assert_eq!(0, fetched.total);

        let fetched = service
            .fetch_sboms(
                Query::default(),
                Paginated::default(),
                ("foo", "bar"),
                &ctx.db,
            )
            .await?;
        assert_eq!(0, fetched.total);

        let fetched = service
            .fetch_sboms(Query::default(), Paginated::default(), (), &ctx.db)
            .await?;
        assert_eq!(3, fetched.total);

        let fetched = service
            .fetch_sboms(
                Query::default(),
                Paginated::default(),
                [("ci", "job2"), ("team", "a")],
                &ctx.db,
            )
            .await?;
        assert_eq!(1, fetched.total);

        Ok(())
    }

    #[test_context(TrustifyContext, skip_teardown)]
    #[test(tokio::test)]
    async fn delete_sbom(ctx: TrustifyContext) -> Result<(), anyhow::Error> {
        let sbom_v1 = ctx
            .graph
            .ingest_sbom(
                Labels::default(),
                &Digests::digest("RHSA-1"),
                Some("http://redhat.com/test.json".to_string()),
                (),
                &ctx.db,
            )
            .await?;

        let service = SbomService::new(ctx.db.clone());

        let affected = service.delete_sbom(sbom_v1.sbom.sbom_id, &ctx.db).await?;

        log::debug!("{:#?}", affected);
        assert_eq!(1, affected);

        let affected = service.delete_sbom(sbom_v1.sbom.sbom_id, &ctx.db).await?;

        log::debug!("{:#?}", affected);
        assert_eq!(0, affected);

        Ok(())
    }
}
