//! Support for packages.

pub mod creator;
pub mod package_version;
pub mod qualified_package;

use crate::graph::{Graph, error::Error};
use package_version::PackageVersionContext;
use qualified_package::QualifiedPackageContext;
use sea_orm::{
    ActiveModelTrait, ColumnTrait, ConnectionTrait, EntityTrait, QueryFilter, Set, prelude::Uuid,
};
use sea_query::SelectStatement;
use std::fmt::{Debug, Formatter};
use tracing::instrument;
use trustify_common::{
    db::limiter::LimiterTrait,
    model::{Paginated, PaginatedResults},
    purl::{Purl, PurlErr},
};
use trustify_entity as entity;

impl Graph {
    /// Ensure the fetch knows about and contains a record for a *fully-qualified* package.
    ///
    /// This method will ensure the versioned package being referenced is also ingested.
    ///
    /// The `pkg` parameter does not necessarily require the presence of qualifiers, but
    /// is assumed to be *complete*.
    #[instrument(skip(self, connection), err(level=tracing::Level::INFO))]
    pub async fn ingest_qualified_package<C: ConnectionTrait>(
        &self,
        purl: &Purl,
        connection: &C,
    ) -> Result<QualifiedPackageContext, Error> {
        let package = self.ingest_package(purl, connection).await?;
        let package_version = package.ingest_package_version(purl, connection).await?;
        package_version
            .ingest_qualified_package(purl, connection)
            .await
    }

    /// Ensure the fetch knows about and contains a record for a *versioned* package.
    ///
    /// This method will ensure the package being referenced is also ingested.
    pub async fn ingest_package_version<C: ConnectionTrait>(
        &self,
        pkg: &Purl,
        connection: &C,
    ) -> Result<PackageVersionContext, Error> {
        if let Some(found) = self.get_package_version(pkg, connection).await? {
            return Ok(found);
        }
        let package = self.ingest_package(pkg, connection).await?;

        package.ingest_package_version(pkg, connection).await
    }

    /// Ensure the fetch knows about and contains a record for a *versionless* package.
    ///
    /// This method will ensure the package being referenced is also ingested.
    pub async fn ingest_package<C: ConnectionTrait>(
        &self,
        purl: &Purl,
        connection: &C,
    ) -> Result<PackageContext, Error> {
        if let Some(found) = self.get_package(purl, connection).await? {
            Ok(found)
        } else {
            let model = entity::base_purl::ActiveModel {
                id: Set(purl.package_uuid()),
                r#type: Set(purl.ty.clone()),
                namespace: Set(purl.namespace.clone()),
                name: Set(purl.name.clone()),
            };

            Ok(PackageContext::new(self, model.insert(connection).await?))
        }
    }

    /// Retrieve a *fully-qualified* package entry, if it exists.
    ///
    /// Non-mutating to the fetch.
    pub async fn get_qualified_package<C: ConnectionTrait>(
        &self,
        purl: &Purl,
        connection: &C,
    ) -> Result<Option<QualifiedPackageContext>, Error> {
        if let Some(package_version) = self.get_package_version(purl, connection).await? {
            package_version
                .get_qualified_package(purl, connection)
                .await
        } else {
            Ok(None)
        }
    }

    pub async fn get_qualified_package_by_id<C: ConnectionTrait>(
        &self,
        id: Uuid,
        connection: &C,
    ) -> Result<Option<QualifiedPackageContext>, Error> {
        let found = entity::qualified_purl::Entity::find_by_id(id)
            .one(connection)
            .await?;

        if let Some(qualified_package) = found {
            if let Some(package_version) = self
                .get_package_version_by_id(qualified_package.versioned_purl_id, connection)
                .await?
            {
                Ok(Some(QualifiedPackageContext::new(
                    &package_version,
                    qualified_package.clone(),
                )))
            } else {
                Ok(None)
            }
        } else {
            Ok(None)
        }
    }

    #[instrument(skip(self, connection), err(level=tracing::Level::INFO))]
    pub async fn get_qualified_packages_by_query<C: ConnectionTrait>(
        &self,
        query: SelectStatement,
        connection: &C,
    ) -> Result<Vec<QualifiedPackageContext>, Error> {
        let found = entity::qualified_purl::Entity::find()
            .filter(entity::qualified_purl::Column::Id.in_subquery(query))
            .all(connection)
            .await?;

        let mut package_versions = Vec::new();

        for base in &found {
            if let Some(package_version) = self
                .get_package_version_by_id(base.versioned_purl_id, connection)
                .await?
            {
                let qualified_package =
                    QualifiedPackageContext::new(&package_version, base.clone());
                package_versions.push(qualified_package);
            }
        }

        Ok(package_versions)
    }

    /// Retrieve a *versioned* package entry, if it exists.
    ///
    /// Non-mutating to the fetch.
    pub async fn get_package_version<C: ConnectionTrait>(
        &self,
        purl: &Purl,
        connection: &C,
    ) -> Result<Option<PackageVersionContext<'_>>, Error> {
        if let Some(pkg) = self.get_package(purl, connection).await? {
            pkg.get_package_version(purl, connection).await
        } else {
            Ok(None)
        }
    }

    #[instrument(skip(self, connection), err)]
    pub async fn get_package_version_by_id<C: ConnectionTrait>(
        &self,
        id: Uuid,
        connection: &C,
    ) -> Result<Option<PackageVersionContext>, Error> {
        if let Some(package_version) = entity::versioned_purl::Entity::find_by_id(id)
            .one(connection)
            .await?
        {
            if let Some(package) = self
                .get_package_by_id(package_version.base_purl_id, connection)
                .await?
            {
                Ok(Some(PackageVersionContext::new(&package, package_version)))
            } else {
                Ok(None)
            }
        } else {
            Ok(None)
        }
    }

    /// Retrieve a *versionless* package entry, if it exists.
    ///
    /// Non-mutating to the fetch.
    pub async fn get_package<C: ConnectionTrait>(
        &self,
        purl: &Purl,
        connection: &C,
    ) -> Result<Option<PackageContext>, Error> {
        Ok(entity::base_purl::Entity::find()
            .filter(entity::base_purl::Column::Type.eq(&purl.ty))
            .filter(if let Some(ns) = &purl.namespace {
                entity::base_purl::Column::Namespace.eq(ns)
            } else {
                entity::base_purl::Column::Namespace.is_null()
            })
            .filter(entity::base_purl::Column::Name.eq(&purl.name))
            .one(connection)
            .await?
            .map(|package| PackageContext::new(self, package)))
    }

    #[instrument(skip(self, connection), err)]
    pub async fn get_package_by_id<C: ConnectionTrait>(
        &self,
        id: Uuid,
        connection: &C,
    ) -> Result<Option<PackageContext>, Error> {
        if let Some(found) = entity::base_purl::Entity::find_by_id(id)
            .one(connection)
            .await?
        {
            Ok(Some(PackageContext::new(self, found)))
        } else {
            Ok(None)
        }
    }
}

/// Live context for base package.
#[derive(Clone)]
pub struct PackageContext<'g> {
    pub graph: &'g Graph,
    pub base_purl: entity::base_purl::Model,
}

impl Debug for PackageContext<'_> {
    fn fmt(&self, f: &mut Formatter<'_>) -> std::fmt::Result {
        self.base_purl.fmt(f)
    }
}

impl<'g> PackageContext<'g> {
    pub fn new(graph: &'g Graph, package: entity::base_purl::Model) -> Self {
        Self {
            graph,
            base_purl: package,
        }
    }

    /// Ensure the fetch knows about and contains a record for a *version* of this package.
    pub async fn ingest_package_version<C: ConnectionTrait>(
        &self,
        purl: &Purl,
        connection: &C,
    ) -> Result<PackageVersionContext<'g>, Error> {
        if let Some(version) = &purl.version {
            if let Some(found) = self.get_package_version(purl, connection).await? {
                Ok(found)
            } else {
                let model = entity::versioned_purl::ActiveModel {
                    id: Set(purl.version_uuid()),
                    base_purl_id: Set(self.base_purl.id),
                    version: Set(version.clone()),
                };

                Ok(PackageVersionContext::new(
                    self,
                    model.insert(connection).await?,
                ))
            }
        } else {
            Err(Error::Purl(PurlErr::MissingVersion(purl.to_string())))
        }
    }

    /// Retrieve a *version* package entry for this package, if it exists.
    ///
    /// Non-mutating to the fetch.
    pub async fn get_package_version<C: ConnectionTrait>(
        &self,
        purl: &Purl,
        connection: &C,
    ) -> Result<Option<PackageVersionContext<'g>>, Error> {
        Ok(entity::versioned_purl::Entity::find()
            .filter(entity::versioned_purl::Column::BasePurlId.eq(self.base_purl.id))
            .filter(entity::versioned_purl::Column::Version.eq(purl.version.clone()))
            .one(connection)
            .await
            .map(|package_version| {
                package_version
                    .map(|package_version| PackageVersionContext::new(self, package_version))
            })?)
    }

    /// Retrieve known versions of this package.
    ///
    /// Non-mutating to the fetch.
    pub async fn get_versions<C: ConnectionTrait>(
        &self,
        connection: &C,
    ) -> Result<Vec<PackageVersionContext>, Error> {
        Ok(entity::versioned_purl::Entity::find()
            .filter(entity::versioned_purl::Column::BasePurlId.eq(self.base_purl.id))
            .all(connection)
            .await?
            .into_iter()
            .map(|each| PackageVersionContext::new(self, each))
            .collect())
    }

    pub async fn get_versions_paginated<C: ConnectionTrait>(
        &self,
        paginated: Paginated,
        connection: &C,
    ) -> Result<PaginatedResults<PackageVersionContext>, Error> {
        let limiter = entity::versioned_purl::Entity::find()
            .filter(entity::versioned_purl::Column::BasePurlId.eq(self.base_purl.id))
            .limiting(connection, paginated.limit, paginated.offset);

        Ok(PaginatedResults {
            total: limiter.total().await?,
            items: limiter
                .fetch()
                .await?
                .drain(0..)
                .map(|each| PackageVersionContext::new(self, each))
                .collect(),
        })
    }
}

#[cfg(test)]
#[allow(clippy::unwrap_used)]
mod tests {
    use std::collections::BTreeMap;
    use std::num::NonZeroU64;
    use std::str::FromStr;

    use sea_orm::{
        EntityTrait, IntoSimpleExpr, QueryFilter, QuerySelect, QueryTrait, TransactionTrait,
    };
    use sea_query::{Expr, SimpleExpr};
    use serde_json::json;
    use test_context::test_context;
    use test_log::test;

    use trustify_common::model::Paginated;
    use trustify_common::purl::Purl;
    use trustify_entity::qualified_purl;
    use trustify_entity::qualified_purl::Qualifiers;
    use trustify_test_context::TrustifyContext;

    use crate::graph::Graph;
    use crate::graph::error::Error;

    #[test_context(TrustifyContext, skip_teardown)]
    #[test(tokio::test)]
    async fn ingest_packages(ctx: TrustifyContext) -> Result<(), anyhow::Error> {
        let system = Graph::new(ctx.db.clone());

        let pkg1 = system
            .ingest_package(&"pkg:maven/io.quarkus/quarkus-core".try_into()?, &ctx.db)
            .await?;

        let pkg2 = system
            .ingest_package(&"pkg:maven/io.quarkus/quarkus-core".try_into()?, &ctx.db)
            .await?;

        let pkg3 = system
            .ingest_package(&"pkg:maven/io.quarkus/quarkus-addons".try_into()?, &ctx.db)
            .await?;

        assert_eq!(pkg1.base_purl.id, pkg2.base_purl.id,);

        assert_ne!(pkg1.base_purl.id, pkg3.base_purl.id);

        Ok(())
    }

    #[test_context(TrustifyContext, skip_teardown)]
    #[test(tokio::test)]
    async fn ingest_package_versions_missing_version(
        ctx: TrustifyContext,
    ) -> Result<(), anyhow::Error> {
        let system = Graph::new(ctx.db.clone());

        let result = system
            .ingest_package_version(&"pkg:maven/io.quarkus/quarkus-addons".try_into()?, &ctx.db)
            .await;

        assert!(result.is_err());

        Ok(())
    }

    #[test_context(TrustifyContext, skip_teardown)]
    #[test(tokio::test)]
    async fn ingest_package_versions(ctx: TrustifyContext) -> Result<(), anyhow::Error> {
        let system = Graph::new(ctx.db.clone());

        let pkg1 = system
            .ingest_package_version(
                &"pkg:maven/io.quarkus/quarkus-core@1.2.3".try_into()?,
                &ctx.db,
            )
            .await?;

        let pkg2 = system
            .ingest_package_version(
                &"pkg:maven/io.quarkus/quarkus-core@1.2.3".try_into()?,
                &ctx.db,
            )
            .await?;

        let pkg3 = system
            .ingest_package_version(
                &"pkg:maven/io.quarkus/quarkus-core@4.5.6".try_into()?,
                &ctx.db,
            )
            .await?;

        assert_eq!(pkg1.package.base_purl.id, pkg2.package.base_purl.id);
        assert_eq!(pkg1.package_version.id, pkg2.package_version.id);

        assert_eq!(pkg1.package.base_purl.id, pkg3.package.base_purl.id);
        assert_ne!(pkg1.package_version.id, pkg3.package_version.id);

        Ok(())
    }

    #[test_context(TrustifyContext, skip_teardown)]
    #[test(tokio::test)]
    async fn get_versions_paginated(ctx: TrustifyContext) -> Result<(), anyhow::Error> {
        let system = Graph::new(ctx.db.clone());

        const TOTAL_ITEMS: u64 = 200;
        let _page_size = NonZeroU64::new(50).unwrap();

        for v in 0..TOTAL_ITEMS {
            let version = format!("pkg:maven/io.quarkus/quarkus-core@{v}").try_into()?;

            let _ = system.ingest_package_version(&version, &ctx.db).await?;
        }

        let pkg = system
            .get_package(&"pkg:maven/io.quarkus/quarkus-core".try_into()?, &ctx.db)
            .await?
            .unwrap();

        let all_versions = pkg.get_versions(&ctx.db).await?;

        assert_eq!(TOTAL_ITEMS, all_versions.len() as u64);

        let paginated = pkg
            .get_versions_paginated(
                Paginated {
                    offset: 50,
                    limit: 50,
                },
                &ctx.db,
            )
            .await?;

        assert_eq!(TOTAL_ITEMS, paginated.total);
        assert_eq!(50, paginated.items.len());

        let _next_paginated = pkg
            .get_versions_paginated(
                Paginated {
                    offset: 100,
                    limit: 50,
                },
                &ctx.db,
            )
            .await?;

        assert_eq!(TOTAL_ITEMS, paginated.total);
        assert_eq!(50, paginated.items.len());

        Ok(())
    }

    #[test_context(TrustifyContext, skip_teardown)]
    #[test(tokio::test)]
    async fn ingest_qualified_packages_transactionally(
        ctx: TrustifyContext,
    ) -> Result<(), anyhow::Error> {
        let system = Graph::new(ctx.db.clone());

        let tx_system = system.clone();

        ctx.db.transaction(|tx| {
            Box::pin(async move {
                let pkg1 = tx_system
                    .ingest_qualified_package(
                        &"pkg:oci/ubi9-container@sha256:2f168398c538b287fd705519b83cd5b604dc277ef3d9f479c28a2adb4d830a49?repository_url=registry.redhat.io/ubi9&tag=9.2-755.1697625012".try_into()?,
                        tx,
                    )
                    .await?;

                let pkg2 = tx_system
                    .ingest_qualified_package(
                    &"pkg:oci/ubi9-container@sha256:2f168398c538b287fd705519b83cd5b604dc277ef3d9f479c28a2adb4d830a49?repository_url=registry.redhat.io/ubi9&tag=9.2-755.1697625012".try_into()?,
                        tx,
                    )
                    .await?;

                assert_eq!(pkg1, pkg2);

                Ok::<(), Error>(())
            })
        }).await?;

        Ok(())
    }

    #[test_context(TrustifyContext, skip_teardown)]
    #[test(tokio::test)]
    async fn ingest_qualified_packages(ctx: TrustifyContext) -> Result<(), anyhow::Error> {
        let system = Graph::new(ctx.db.clone());

        let pkg1 = system
            .ingest_qualified_package(
                &"pkg:maven/io.quarkus/quarkus-core@1.2.3".try_into()?,
                &&ctx.db,
            )
            .await?;

        let pkg2 = system
            .ingest_qualified_package(
                &"pkg:maven/io.quarkus/quarkus-core@1.2.3".try_into()?,
                &&ctx.db,
            )
            .await?;

        let pkg3 = system
            .ingest_qualified_package(
                &"pkg:maven/io.quarkus/quarkus-core@1.2.3?type=jar".try_into()?,
                &&ctx.db,
            )
            .await?;

        let pkg4 = system
            .ingest_qualified_package(
                &"pkg:maven/io.quarkus/quarkus-core@1.2.3?type=jar".try_into()?,
                &&ctx.db,
            )
            .await?;

        assert_eq!(pkg1.qualified_package.id, pkg2.qualified_package.id);
        assert_eq!(pkg3.qualified_package.id, pkg4.qualified_package.id);

        assert_ne!(pkg1.qualified_package.id, pkg3.qualified_package.id);

        assert_eq!(
            "pkg:maven/io.quarkus/quarkus-core@1.2.3",
            Purl::from(pkg1).to_string().as_str()
        );
        assert_eq!(
            "pkg:maven/io.quarkus/quarkus-core@1.2.3?type=jar",
            Purl::from(pkg3).to_string().as_str()
        );

        Ok(())
    }

    #[test_context(TrustifyContext, skip_teardown)]
    #[test(tokio::test)]
    async fn query_qualified_packages(ctx: TrustifyContext) -> Result<(), anyhow::Error> {
        let graph = Graph::new(ctx.db.clone());

        for i in [
            "pkg:maven/io.quarkus/quarkus-core@1.2.3",
            "pkg:maven/io.quarkus/quarkus-core@1.2.3?type=jar",
            "pkg:maven/io.quarkus/quarkus-core@1.2.3?type=pom",
        ] {
            graph
                .ingest_qualified_package(&i.try_into()?, &&ctx.db)
                .await?;
        }

        let qualifiers = json!({"type": "jar"});
        // qualifiers @> '{"type": "jar"}'::jsonb
        let select = qualified_purl::Entity::find()
            .select_only()
            .column(qualified_purl::Column::Id)
            .filter(Expr::cust_with_exprs(
                "$1 @> $2::jsonb",
                [
                    qualified_purl::Column::Qualifiers.into_simple_expr(),
                    SimpleExpr::Value(qualifiers.into()),
                ],
            ))
            .into_query();
        let result = graph
            .get_qualified_packages_by_query(select, &ctx.db)
            .await?;

        log::debug!("{result:?}");

        assert_eq!(result.len(), 1);
        assert_eq!(
            result[0].qualified_package.qualifiers,
            Qualifiers(BTreeMap::from_iter([("type".into(), "jar".into())]))
        );

        Ok(())
    }

    #[test]
    fn test_uuid() {
        let purl = Purl::from_str("pkg:maven/io.quarkus/quarkus-core@1.2").unwrap();

        assert_eq!(
            purl.package_uuid().to_string(),
            "d2df7e32-548d-52f0-b31d-61463b78ce90"
        );
        assert_eq!(
            purl.version_uuid().to_string(),
            "709c07a3-3936-5d83-8c4f-734991725cbd"
        );

        let purl = Purl::from_str("pkg:maven/io.quarkus/quarkus-core@1.3").unwrap();

        assert_eq!(
            purl.package_uuid().to_string(),
            "d2df7e32-548d-52f0-b31d-61463b78ce90"
        );
        assert_eq!(
            purl.version_uuid().to_string(),
            "3f263e61-f8a3-5345-ad80-c615c27299e1"
        );
    }
}
