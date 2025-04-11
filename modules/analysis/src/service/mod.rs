mod load;
mod query;
mod walk;

pub use collector::*;
pub use query::*;
pub use walk::*;

mod collector;
pub mod render;
#[cfg(test)]
mod test;

use crate::{
    Error,
    config::AnalysisConfig,
    model::{AnalysisStatus, BaseSummary, GraphMap, Node, PackageGraph, graph},
};
use fixedbitset::FixedBitSet;
use futures::{StreamExt, stream};
use opentelemetry::global;
use petgraph::{
    Direction,
    graph::{Graph, NodeIndex},
    prelude::EdgeRef,
    visit::{IntoNodeIdentifiers, VisitMap, Visitable},
};
use sea_orm::{
    ColumnTrait, DatabaseBackend, EntityOrSelect, EntityTrait, QueryFilter, QuerySelect,
    RelationTrait, Statement, prelude::ConnectionTrait,
};
use sea_query::JoinType;
use std::{
    collections::{HashMap, HashSet},
    fmt::Debug,
    sync::Arc,
};
use tracing::instrument;
use trustify_common::{
    db::query::Value,
    model::{Paginated, PaginatedResults},
};
use trustify_entity::{
    relationship::Relationship,
    sbom,
    sbom_external_node::{self, DiscriminatorType, ExternalType},
    sbom_node_checksum, source_document,
};
use uuid::Uuid;

type NodeGraph = Graph<graph::Node, Relationship, petgraph::Directed>;

#[derive(Clone)]
pub struct AnalysisService {
    graph_cache: Arc<GraphMap>,
}

#[derive(Clone, Debug, PartialEq, Eq)]
struct ResolvedSbom {
    // The ID of the SBOM the node was found in
    pub sbom_id: Uuid,
    // The ID of the node
    pub node_id: String,
}

async fn resolve_external_sbom<C: ConnectionTrait>(
    node_id: String,
    connection: &C,
) -> Option<ResolvedSbom> {
    // we first lookup in sbom_external_node
    let sbom_external_node = match sbom_external_node::Entity::find()
        .filter(sbom_external_node::Column::NodeId.eq(node_id.as_str()))
        .one(connection)
        .await
    {
        Ok(Some(entity)) => entity,
        _ => return None,
    };

    match sbom_external_node.external_type {
        ExternalType::SPDX => {
            // For spdx, sbom_external_node discriminator_type and discriminator_value are used
            // to lookup sbom_id via join to SourceDocument. The node_id is just the external_node_ref.

            let discriminator_value = sbom_external_node.discriminator_value?;

            if discriminator_value.is_empty() {
                return None;
            }

            let query =
                sbom::Entity::find().join(JoinType::Join, sbom::Relation::SourceDocument.def());

            let query = match sbom_external_node.discriminator_type? {
                DiscriminatorType::Sha256 => {
                    query.filter(source_document::Column::Sha256.eq(&discriminator_value))
                }
                _ => return None,
            };

            match query.one(connection).await {
                Ok(Some(entity)) => Some(ResolvedSbom {
                    sbom_id: entity.sbom_id,
                    node_id: sbom_external_node.external_node_ref,
                }),
                _ => None,
            }
        }
        ExternalType::CycloneDx => {
            // For cyclonedx, sbom_external_node discriminator_type and discriminator_value are used
            // we construct external_doc_id to lookup sbom_id directly from sbom entity. The node_id
            // is the external_node_ref

            let discriminator_value = sbom_external_node.discriminator_value?;

            if discriminator_value.is_empty() {
                return None;
            }

            let external_doc_ref = sbom_external_node.external_doc_ref;
            let external_doc_id = format!("urn:cdx:{}/{}", external_doc_ref, discriminator_value);

            match sbom::Entity::find()
                .filter(sbom::Column::DocumentId.eq(external_doc_id))
                .one(connection)
                .await
            {
                Ok(Some(entity)) => Some(ResolvedSbom {
                    sbom_id: entity.sbom_id,
                    node_id: sbom_external_node.external_node_ref,
                }),
                _ => None,
            }
        }
        ExternalType::RedHatProductComponent => {
            // for RH variations we assume the sbom_external_node_ref is the package checksum
            // which is used on sbom_node_checksum to lookup related value then
            // perform another lookup on sbom_node_checksum (matching by value) to find resultant
            // sbom_id/node_id
            resolve_rh_external_sbom_descendants(
                sbom_external_node.sbom_id,
                sbom_external_node.external_node_ref,
                connection,
            )
            .await
        }
    }
}

async fn resolve_rh_external_sbom_descendants<C: ConnectionTrait>(
    sbom_external_sbom_id: Uuid,
    sbom_external_node_ref: String,
    connection: &C,
) -> Option<ResolvedSbom> {
    // find checksum value for the node
    match sbom_node_checksum::Entity::find()
        .filter(sbom_node_checksum::Column::NodeId.eq(sbom_external_node_ref.clone()))
        .filter(sbom_node_checksum::Column::SbomId.eq(sbom_external_sbom_id))
        .one(connection)
        .await
    {
        Ok(Some(entity)) => {
            // now find if there are any other other nodes with the same checksums
            match sbom_node_checksum::Entity::find()
                .filter(sbom_node_checksum::Column::Value.eq(entity.value.to_string()))
                .filter(sbom_node_checksum::Column::SbomId.ne(entity.sbom_id))
                .one(connection)
                .await
            {
                Ok(Some(matched)) => Some(ResolvedSbom {
                    sbom_id: matched.sbom_id,
                    node_id: matched.node_id,
                }),
                _ => None,
            }
        }
        _ => None,
    }
}

async fn resolve_rh_external_sbom_ancestors<C: ConnectionTrait>(
    sbom_external_sbom_id: Uuid,
    sbom_external_node_ref: String,
    connection: &C,
) -> Vec<ResolvedSbom> {
    // find related checksum value(s) for the node, because any single component can be referred to by multiple
    // sboms, this function returns a Vec<ResolvedSbom>.
    match sbom_node_checksum::Entity::find()
        .filter(sbom_node_checksum::Column::NodeId.eq(sbom_external_node_ref.clone()))
        .filter(sbom_node_checksum::Column::SbomId.eq(sbom_external_sbom_id))
        .one(connection)
        .await
    {
        Ok(Some(entity)) => {
            // now find if there are any other other nodes with the same checksums
            match sbom_node_checksum::Entity::find()
                .filter(sbom_node_checksum::Column::Value.eq(entity.value.to_string()))
                .filter(sbom_node_checksum::Column::SbomId.ne(entity.sbom_id))
                .all(connection)
                .await
            {
                Ok(matches) => {
                    let mut resolved_sboms: Vec<ResolvedSbom> = vec![];
                    for matched in matches {
                        resolved_sboms.push(ResolvedSbom {
                            sbom_id: matched.sbom_id,
                            node_id: matched.node_id,
                        })
                    }
                    resolved_sboms
                }

                _ => vec![],
            }
        }
        _ => {
            vec![]
        }
    }
}

impl AnalysisService {
    /// Create a new analysis service instance with the configured cache size.
    ///
    /// ## Caching
    ///
    /// A new instance will have a new cache. Instanced cloned from it, will share that cache.
    ///
    /// Therefore, it is ok to create a new instance. However, if you want to make use of the
    /// caching, it is necessary to re-use that instance.
    ///
    /// Also, we do not implement default because of this. As a new instance has the implication
    /// of having its own cache. So creating a new instance should be a deliberate choice.
    pub fn new(config: AnalysisConfig) -> Self {
        let graph_cache = Arc::new(GraphMap::new(config.max_cache_size.as_u64()));

        let meter = global::meter("AnalysisService");
        {
            let graph_cache = graph_cache.clone();
            meter
                .u64_observable_gauge("cache_size")
                .with_callback(move |inst| inst.observe(graph_cache.size_used(), &[]))
                .build();
        };
        {
            let graph_cache = graph_cache.clone();
            meter
                .u64_observable_gauge("cache_items")
                .with_callback(move |inst| inst.observe(graph_cache.len(), &[]))
                .build();
        };

        Self { graph_cache }
    }

    pub fn cache_size_used(&self) -> u64 {
        self.graph_cache.size_used()
    }

    pub fn cache_len(&self) -> u64 {
        self.graph_cache.len()
    }

    #[instrument(skip_all, err)]
    pub async fn load_all_graphs<C: ConnectionTrait>(
        &self,
        connection: &C,
    ) -> Result<Vec<(String, Arc<PackageGraph>)>, Error> {
        // retrieve all sboms in trustify

        let distinct_sbom_ids = sbom::Entity::find()
            .select()
            .all(connection)
            .await?
            .into_iter()
            .map(|record| record.sbom_id.to_string()) // Assuming sbom_id is of type String
            .collect();

        self.load_graphs(connection, &distinct_sbom_ids).await
    }

    pub fn clear_all_graphs(&self) -> Result<(), Error> {
        self.graph_cache.clear();
        Ok(())
    }

    pub async fn status<C: ConnectionTrait>(
        &self,
        connection: &C,
    ) -> Result<AnalysisStatus, Error> {
        let distinct_sbom_ids = sbom::Entity::find().select().all(connection).await?;

        Ok(AnalysisStatus {
            sbom_count: distinct_sbom_ids.len() as u32,
            graph_count: self.graph_cache.len() as u32,
        })
    }

    /// Collect nodes from the graph
    #[instrument(skip(self, create))]
    async fn collect_graph<'a, C>(
        &self,
        query: impl Into<GraphQuery<'a>> + Debug,
        graphs: &[(String, Arc<PackageGraph>)],
        create: C,
    ) -> Vec<Node>
    where
        C: AsyncFn(&Graph<graph::Node, Relationship>, NodeIndex, &graph::Node) -> Node,
    {
        let query = query.into();

        stream::iter(
            graphs
                .iter()
                .filter(|(sbom_id, graph)| acyclic(sbom_id, graph)),
        )
        .flat_map(|(_, graph)| {
            stream::iter(
                graph
                    .node_indices()
                    .filter(|&i| Self::filter(graph, &query, i))
                    .filter_map(|i| graph.node_weight(i).map(|w| (i, w))),
            )
            .then(|(node_index, package_node)| create(graph, node_index, package_node))
        })
        .collect::<Vec<_>>()
        .await
    }

    #[instrument(skip(self, connection, graph_cache))]
    pub async fn run_graph_query<'a, C: ConnectionTrait>(
        &self,
        query: impl Into<GraphQuery<'a>> + Debug,
        options: QueryOptions,
        graphs: &[(String, Arc<PackageGraph>)],
        connection: &C,
        graph_cache: Arc<GraphMap>,
    ) -> Vec<Node> {
        let relationships = options.relationships;

        self.collect_graph(query, graphs, async |graph, node_index, node| {
            log::debug!(
                "Discovered node - sbom: {}, node: {}",
                node.sbom_id,
                node.node_id
            );
            Node {
                base: node.into(),
                relationship: None,
                ancestors: Box::pin(
                    Collector::new(
                        &graph_cache,
                        graphs,
                        graph,
                        node_index,
                        Direction::Incoming,
                        options.ancestors,
                        &relationships,
                        connection,
                    )
                    .collect(),
                )
                .await,
                descendants: Box::pin(
                    Collector::new(
                        &graph_cache,
                        graphs,
                        graph,
                        node_index,
                        Direction::Outgoing,
                        options.descendants,
                        &relationships,
                        connection,
                    )
                    .collect(),
                )
                .await,
            }
        })
        .await
    }

    /// locate components, retrieve dependency information, from a single SBOM
    /// TODO - this is only used by a test
    #[instrument(skip(self, connection), err)]
    pub async fn retrieve_single<C: ConnectionTrait>(
        &self,
        sbom_id: Uuid,
        query: impl Into<GraphQuery<'_>> + Debug,
        options: impl Into<QueryOptions> + Debug,
        paginated: Paginated,
        connection: &C,
    ) -> Result<PaginatedResults<Node>, Error> {
        let distinct_sbom_ids = vec![sbom_id.to_string()];

        let query = query.into();
        let options = options.into();

        let graphs = self.load_graphs(connection, &distinct_sbom_ids).await?;
        let components = self
            .run_graph_query(
                query,
                options,
                &graphs,
                connection,
                self.graph_cache.clone(),
            )
            .await;

        Ok(paginated.paginate_array(&components))
    }

    /// locate components, retrieve dependency information
    #[instrument(skip(self, connection), err)]
    pub async fn retrieve<C: ConnectionTrait>(
        &self,
        query: impl Into<GraphQuery<'_>> + Debug,
        options: impl Into<QueryOptions> + Debug,
        paginated: Paginated,
        connection: &C,
    ) -> Result<PaginatedResults<Node>, Error> {
        let query = query.into();
        let options = options.into();

        let graphs = self.load_graphs_query(connection, query).await?;

        let components = self
            .run_graph_query(
                query,
                options,
                &graphs,
                connection,
                self.graph_cache.clone(),
            )
            .await;

        Ok(paginated.paginate_array(&components))
    }

    #[instrument(skip(self, connection), err)]
    pub async fn retrieve_latest<C: ConnectionTrait>(
        &self,
        query: impl Into<GraphQuery<'_>> + Debug,
        options: impl Into<QueryOptions> + Debug,
        paginated: Paginated,
        connection: &C,
    ) -> Result<PaginatedResults<Node>, Error> {
        let query = query.into();
        let options = options.into();

        let graphs = self.load_graphs_query(connection, query).await?;

        let components = self
            .run_graph_query(
                query,
                options,
                &graphs,
                connection,
                self.graph_cache.clone(),
            )
            .await;

        // This is a limited scope implementation of 'latest filtering' which performs a
        // post-processing of a normal result set. The query type (name, cpe, purl or generic)
        // determines
        let latest_sbom_ids = match query {
            GraphQuery::Component(ComponentReference::Id(name)) => {
                let sql = r#"
                    SELECT distinct sbom.sbom_id
                    FROM sbom_node
                    JOIN sbom ON sbom.sbom_id = sbom_node.sbom_id
                    WHERE sbom_node.node_id = $1
                    AND sbom.published = (
                        SELECT MAX(published)
                        FROM sbom
                        JOIN sbom_node ON sbom.sbom_id = sbom_node.sbom_id
                        WHERE sbom_node.node_id = $1
                    );
                "#;
                let stmt =
                    Statement::from_sql_and_values(DatabaseBackend::Postgres, sql, [name.into()]);
                let rows = connection.query_all(stmt).await?;
                rows.into_iter()
                    .filter_map(|row| {
                        row.try_get_by_index::<Uuid>(0)
                            .ok()
                            .map(|sbom_id| sbom_id.to_string())
                    })
                    .collect::<Vec<String>>()
            }
            GraphQuery::Component(ComponentReference::Name(name)) => {
                let sql = r#"
                    SELECT distinct sbom.sbom_id
                    FROM sbom_node
                    JOIN sbom ON sbom.sbom_id = sbom_node.sbom_id
                    WHERE sbom_node.name = $1
                    AND sbom.published = (
                        SELECT MAX(published)
                        FROM sbom
                        JOIN sbom_node ON sbom.sbom_id = sbom_node.sbom_id
                        WHERE sbom_node.name = $1
                    );
                "#;
                let stmt =
                    Statement::from_sql_and_values(DatabaseBackend::Postgres, sql, [name.into()]);
                let rows = connection.query_all(stmt).await?;
                rows.into_iter()
                    .filter_map(|row| {
                        row.try_get_by_index::<Uuid>(0)
                            .ok()
                            .map(|sbom_id| sbom_id.to_string())
                    })
                    .collect::<Vec<String>>()
            }
            GraphQuery::Component(ComponentReference::Purl(purl)) => {
                let sql = r#"
                    SELECT distinct sbom.sbom_id
                    FROM sbom_package_purl_ref
                    JOIN sbom ON sbom.sbom_id = sbom_package_purl_ref.sbom_id
                    WHERE sbom_package_purl_ref.qualified_purl_id = $1
                    AND sbom.published = (
                        SELECT MAX(published)
                        FROM sbom
                        JOIN sbom_package_purl_ref ON sbom.sbom_id = sbom_package_purl_ref.sbom_id
                        WHERE sbom_package_purl_ref.qualified_purl_id = $1
                    );
                "#;
                let stmt = Statement::from_sql_and_values(
                    DatabaseBackend::Postgres,
                    sql,
                    [purl.qualifier_uuid().into()],
                );
                let rows = connection.query_all(stmt).await?;
                rows.into_iter()
                    .filter_map(|row| {
                        row.try_get_by_index::<Uuid>(0)
                            .ok()
                            .map(|sbom_id| sbom_id.to_string())
                    })
                    .collect::<Vec<String>>()
            }
            GraphQuery::Component(ComponentReference::Cpe(cpe)) => {
                let sql = r#"
                    SELECT distinct sbom.sbom_id
                    FROM sbom_package_cpe_ref
                    JOIN sbom ON sbom.sbom_id = sbom_package_cpe_ref.sbom_id
                    WHERE sbom_package_cpe_ref.cpe_id = $1
                    AND sbom.published = (
                        SELECT MAX(published)
                        FROM sbom
                        JOIN sbom_package_cpe_ref ON sbom.sbom_id = sbom_package_cpe_ref.sbom_id
                        WHERE sbom_package_cpe_ref.cpe_id = $1
                    );
                "#;
                let stmt = Statement::from_sql_and_values(
                    DatabaseBackend::Postgres,
                    sql,
                    [cpe.uuid().into()],
                );
                let rows = connection.query_all(stmt).await?;
                rows.into_iter()
                    .filter_map(|row| {
                        row.try_get_by_index::<Uuid>(0)
                            .ok()
                            .map(|sbom_id| sbom_id.to_string())
                    })
                    .collect::<Vec<String>>()
            }
            GraphQuery::Query(query) => {
                // TODO - when we formally define 'latest authoratative filters' this area will become
                //        much more complex ... for now we are happy with just searching node_id with
                //        LIKE matches.
                let sql = r#"
                    SELECT distinct sbom.sbom_id
                    FROM sbom_node
                    JOIN sbom ON sbom.sbom_id = sbom_node.sbom_id
                    WHERE sbom_node.node_id ~ $1
                    AND sbom.published = (
                        SELECT MAX(published)
                        FROM sbom
                        JOIN sbom_node ON sbom.sbom_id = sbom_node.sbom_id
                        WHERE sbom_node.node_id ~ $1
                    );
                "#;
                let stmt = Statement::from_sql_and_values(
                    DatabaseBackend::Postgres,
                    sql,
                    [query.clone().q.into()],
                );
                let rows = connection.query_all(stmt).await?;
                rows.into_iter()
                    .filter_map(|row| {
                        row.try_get_by_index::<Uuid>(0)
                            .ok()
                            .map(|sbom_id| sbom_id.to_string())
                    })
                    .collect::<Vec<String>>()
            }
        };

        log::debug!("Latest sbom IDs: {:?}", latest_sbom_ids);

        // filter initial set of top level matched nodes by latest_sbom_ids which will ensure
        // our 'starting points' are on nodes that are from latest sboms
        let mut latest_components = vec![];
        for component in components {
            if latest_sbom_ids.contains(&component.sbom_id) {
                latest_components.push(component);
            }
        }
        Ok(paginated.paginate_array(&latest_components))
    }

    /// check if a node in the graph matches the provided query
    fn filter(graph: &Graph<graph::Node, Relationship>, query: &GraphQuery, i: NodeIndex) -> bool {
        match query {
            GraphQuery::Component(ComponentReference::Id(component_id)) => graph
                .node_weight(i)
                .is_some_and(|node| node.node_id.eq(component_id)),
            GraphQuery::Component(ComponentReference::Name(component_name)) => graph
                .node_weight(i)
                .is_some_and(|node| node.name.eq(component_name)),
            GraphQuery::Component(ComponentReference::Purl(purl)) => {
                graph.node_weight(i).is_some_and(|node| match node {
                    graph::Node::Package(package) => package.purl.contains(purl),
                    _ => false,
                })
            }
            GraphQuery::Component(ComponentReference::Cpe(cpe)) => {
                graph.node_weight(i).is_some_and(|node| match node {
                    graph::Node::Package(package) => package.cpe.contains(cpe),
                    _ => false,
                })
            }
            GraphQuery::Query(query) => graph.node_weight(i).is_some_and(|node| {
                let mut context = HashMap::from([
                    ("sbom_id", Value::String(&node.sbom_id)),
                    ("node_id", Value::String(&node.node_id)),
                    ("name", Value::String(&node.name)),
                ]);
                match node {
                    graph::Node::Package(package) => {
                        context.extend([
                            ("version", Value::String(&package.version)),
                            ("purl", Value::from(&package.purl)),
                            ("cpe", Value::from(&package.cpe)),
                        ]);
                    }
                    graph::Node::External(external) => {
                        context.extend([
                            (
                                "external_document_reference",
                                Value::String(&external.external_document_reference),
                            ),
                            (
                                "external_node_id",
                                Value::String(&external.external_node_id),
                            ),
                        ]);
                    }
                    _ => {}
                }
                query.apply(&context)
            }),
        }
    }
}

fn acyclic(id: &str, graph: &Arc<PackageGraph>) -> bool {
    use petgraph::visit::{DfsEvent, depth_first_search};
    let g = graph.as_ref();
    let result = depth_first_search(g, g.node_identifiers(), |event| match event {
        DfsEvent::BackEdge(source, target) => Err((source, target)),
        _ => Ok(()),
    })
    .err();
    if let Some((start, end)) = result {
        // FIXME: we need a better strategy handling such errors
        let start = graph.node_weight(start);
        let end = graph.node_weight(end);
        log::warn!(
            "analysis graph of sbom {id} has circular references (detected: {start:?} -> {end:?})!",
        );
    }
    result.is_none()
}
