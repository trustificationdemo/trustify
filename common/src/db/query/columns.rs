use std::collections::BTreeMap;
use std::fmt::{Display, Formatter};

use sea_orm::entity::ColumnDef;
use sea_orm::{ColumnTrait, ColumnType, EntityTrait, IntoIdentity, Iterable, sea_query};
use sea_query::extension::postgres::PgExpr;
use sea_query::{Alias, ColumnRef, Expr, IntoColumnRef, IntoIden, SimpleExpr};

use super::Error;

/// Context of columns which can be used for filtering and sorting.
#[derive(Default, Debug, Clone)]
pub struct Columns {
    columns: Vec<(ColumnRef, ColumnType)>,
    translator: Option<Translator>,
    json_keys: BTreeMap<&'static str, &'static str>,
    exprs: BTreeMap<&'static str, (Expr, ColumnType)>,
}

impl Display for Columns {
    fn fmt(&self, f: &mut Formatter<'_>) -> std::fmt::Result {
        for (r, ty) in &self.columns {
            writeln!(f)?;
            match r {
                ColumnRef::SchemaTableColumn(_, t, c) | ColumnRef::TableColumn(t, c) => {
                    write!(f, "  \"{}\".\"{}\"", t.to_string(), c.to_string())?
                }
                ColumnRef::Column(c) => write!(f, "  \"{}\"", c.to_string())?,
                _ => write!(f, "  {r:?}")?,
            }
            write!(f, " : ")?;
            match ty {
                ColumnType::Text | ColumnType::String(_) | ColumnType::Char(_) => {
                    write!(f, "String")?
                }
                ColumnType::Enum { name, variants } => write!(
                    f,
                    "Enum({}) {:?}",
                    name.to_string(),
                    variants.iter().map(|v| v.to_string()).collect::<Vec<_>>()
                )?,
                t => write!(f, "  {t:?}")?,
            }
        }
        Ok(())
    }
}

pub trait IntoColumns {
    fn columns(self) -> Columns;
}

impl IntoColumns for Columns {
    fn columns(self) -> Columns {
        self
    }
}

impl<E: EntityTrait> IntoColumns for E {
    fn columns(self) -> Columns {
        Columns::from_entity::<E>()
    }
}

pub type Translator = fn(&str, &str, &str) -> Option<String>;

impl Columns {
    /// Construct a new columns context from an entity type.
    pub fn from_entity<E: EntityTrait>() -> Self {
        let columns = E::Column::iter()
            .map(|c| {
                let (t, u) = c.as_column_ref();
                let column_ref = ColumnRef::TableColumn(t, u);
                let column_type = c.def().get_column_type().clone();
                (column_ref, column_type)
            })
            .collect();
        Self {
            columns,
            translator: None,
            json_keys: BTreeMap::new(),
            exprs: BTreeMap::new(),
        }
    }

    /// Add an arbitrary column into the context.
    pub fn add_column<I: IntoIdentity>(mut self, name: I, def: ColumnDef) -> Self {
        self.columns.push((
            name.into_identity().into_column_ref(),
            def.get_column_type().clone(),
        ));
        self
    }

    /// Add columns from another column context.
    ///
    /// Any columns already existing within this context will *not* be replaced
    /// by columns from the argument.
    pub fn add_columns<C: IntoColumns>(mut self, columns: C) -> Self {
        let columns = columns.columns();

        for (col_ref, col_def) in columns.columns {
            if !self
                .columns
                .iter()
                .any(|(existing_col_ref, _)| *existing_col_ref == col_ref)
            {
                self.columns.push((col_ref, col_def))
            }
        }

        self
    }

    /// Add an arbitrary expression into the context.
    pub fn add_expr(mut self, name: &'static str, expr: SimpleExpr, ty: ColumnType) -> Self {
        self.exprs.insert(name, (Expr::expr(expr), ty));
        self
    }

    /// Add a translator to the context
    pub fn translator(mut self, f: Translator) -> Self {
        self.translator = Some(f);
        self
    }

    /// Alias a table name
    pub fn alias(mut self, from: &str, to: &str) -> Self {
        self.columns = self
            .columns
            .into_iter()
            .map(|(r, d)| match r {
                ColumnRef::TableColumn(t, c) if t.to_string().eq_ignore_ascii_case(from) => {
                    (ColumnRef::TableColumn(Alias::new(to).into_iden(), c), d)
                }
                _ => (r, d),
            })
            .collect();
        self
    }

    /// Declare which query fields are the nested keys of a JSON column
    pub fn json_keys(mut self, column: &'static str, fields: &[&'static str]) -> Self {
        for each in fields {
            self.json_keys.insert(each, column);
        }
        self
    }

    /// Return the columns that are string-ish
    pub(crate) fn strings(&self) -> impl Iterator<Item = Expr> + '_ {
        self.columns
            .iter()
            .filter_map(|(col_ref, col_type)| match col_type {
                ColumnType::String(_) | ColumnType::Text => Some(Expr::col(col_ref.clone())),
                _ => None,
            })
            .chain(self.exprs.iter().filter_map(|(_, (ex, ty))| match ty {
                ColumnType::String(_) | ColumnType::Text => Some(ex.clone()),
                _ => None,
            }))
            .chain(self.json_keys.iter().map(|(field, column)| {
                Expr::expr(Expr::col(column.into_identity()).cast_json_field(*field))
            }))
    }

    /// Look up the column context for a given simple field name.
    pub(crate) fn for_field(&self, field: &str) -> Result<(Expr, ColumnType), Error> {
        fn name_match(tgt: &str) -> impl Fn(&&(ColumnRef, ColumnType)) -> bool + '_ {
            |(col, _)| {
                matches!(col,
                         ColumnRef::Column(name)
                         | ColumnRef::TableColumn(_, name)
                         | ColumnRef::SchemaTableColumn(_, _, name)
                         if name.to_string().eq_ignore_ascii_case(tgt))
            }
        }
        if let Some(v) = self.exprs.get(field) {
            // expressions take precedence over matching column names, if any
            Ok(v.clone())
        } else {
            self.columns
                .iter()
                .find(name_match(field))
                .map(|(r, d)| (Expr::col(r.clone()), d.clone()))
                .or_else(|| {
                    self.columns
                        .iter()
                        .filter(|(_, ty)| matches!(ty, ColumnType::Json | ColumnType::JsonBinary))
                        .find(name_match(self.json_keys.get(field)?))
                        .map(|(r, ty)| {
                            (
                                Expr::expr(Expr::col(r.clone()).cast_json_field(field)),
                                ty.clone(),
                            )
                        })
                })
                .ok_or(Error::SearchSyntax(format!(
                    "Invalid field name: '{field}'"
                )))
        }
    }

    pub(crate) fn translate(&self, field: &str, op: &str, value: &str) -> Option<String> {
        match self.translator {
            None => None,
            Some(f) => f(field, op, value),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::super::tests::*;
    use super::super::*;
    use super::*;
    use sea_orm::{ColumnType, ColumnTypeTrait, QuerySelect, QueryTrait};
    use sea_query::{Expr, Func, SimpleExpr};
    use test_log::test;

    #[test(tokio::test)]
    async fn conditions_on_extra_columns() -> Result<(), anyhow::Error> {
        let query = advisory::Entity::find()
            .select_only()
            .column(advisory::Column::Id)
            .expr_as(
                Func::char_length(Expr::col("location".into_identity())),
                "location_len",
            );

        let sql = query
            .filtering_with(
                q("location_len>10"),
                advisory::Entity
                    .columns()
                    .add_column("location_len", ColumnType::Integer.def()),
            )?
            .build(sea_orm::DatabaseBackend::Postgres)
            .to_string();

        assert_eq!(
            sql,
            r#"SELECT "advisory"."id", CHAR_LENGTH("location") AS "location_len" FROM "advisory" WHERE "location_len" > 10"#
        );

        Ok(())
    }

    #[test(tokio::test)]
    async fn filters_extra_columns() -> Result<(), anyhow::Error> {
        let test = |s: &str, expected: &str, def: ColumnDef| {
            let stmt = advisory::Entity::find()
                .select_only()
                .column(advisory::Column::Id)
                .filtering_with(q(s), advisory::Entity.columns().add_column("len", def))
                .unwrap()
                .build(sea_orm::DatabaseBackend::Postgres)
                .to_string()
                .split("WHERE ")
                .last()
                .unwrap()
                .to_string();
            assert_eq!(stmt, expected);
        };

        use ColumnType::*;
        test("len=42", r#""len" = 42"#, Integer.def());
        test("len!=42", r#""len" <> 42"#, Integer.def());
        test("len~42", r#""len" ILIKE '%42%'"#, Text.def());
        test("len!~42", r#""len" NOT ILIKE '%42%'"#, Text.def());
        test("len>42", r#""len" > 42"#, Integer.def());
        test("len>=42", r#""len" >= 42"#, Integer.def());
        test("len<42", r#""len" < 42"#, Integer.def());
        test("len<=42", r#""len" <= 42"#, Integer.def());

        Ok(())
    }

    #[test(tokio::test)]
    async fn translation() -> Result<(), anyhow::Error> {
        let clause = |query: Query| -> Result<String, Error> {
            Ok(advisory::Entity::find()
                .select_only()
                .column(advisory::Column::Id)
                .filtering_with(
                    query,
                    advisory::Entity.columns().translator(|f, op, v| {
                        match (f, op, v) {
                            ("severity", "=", "low") => Some("score>=0&score<3"),
                            ("severity", "=", "medium") => Some("score>=3&score<6"),
                            ("severity", "=", "high") => Some("score>=6&score<10"),
                            ("severity", ">", "low") => Some("score>3"),
                            ("severity", ">", "medium") => Some("score>6"),
                            ("severity", ">", "high") => Some("score>10"),
                            ("severity", "<", "low") => Some("score<0"),
                            ("severity", "<", "medium") => Some("score<3"),
                            ("severity", "<", "high") => Some("score<6"),
                            ("painful", "=", "true") => Some("severity>high"),
                            _ => None,
                        }
                        .map(String::from)
                        .or_else(|| match (f, v) {
                            ("severity", "") => Some(format!("score:{op}")),
                            _ => None,
                        })
                    }),
                )?
                .build(sea_orm::DatabaseBackend::Postgres)
                .to_string()
                .split("WHERE ")
                .last()
                .unwrap()
                .to_string())
        };

        assert_eq!(
            clause(q("severity>medium").sort("severity:desc"))?,
            r#""advisory"."score" > 6 ORDER BY "advisory"."score" DESC"#,
        );
        assert_eq!(
            clause(q("severity=medium"))?,
            r#""advisory"."score" >= 3 AND "advisory"."score" < 6"#,
        );
        assert_eq!(
            clause(q("severity=low|high"))?,
            r#"("advisory"."score" >= 0 AND "advisory"."score" < 3) OR ("advisory"."score" >= 6 AND "advisory"."score" < 10)"#,
        );
        assert_eq!(clause(q("painful=true"))?, r#""advisory"."score" > 10"#);
        assert!(clause(q("painful=false")).is_err());

        Ok(())
    }

    #[test(tokio::test)]
    async fn table_aliasing() -> Result<(), anyhow::Error> {
        let clause = advisory::Entity::find()
            .select_only()
            .column(advisory::Column::Id)
            .filtering_with(
                q("location=here"),
                advisory::Entity.columns().alias("advisory", "foo"),
            )?
            .build(sea_orm::DatabaseBackend::Postgres)
            .to_string()
            .split("WHERE ")
            .last()
            .unwrap()
            .to_string();

        assert_eq!(clause, r#""foo"."location" = 'here'"#);

        Ok(())
    }

    #[test(tokio::test)]
    async fn json_queries() -> Result<(), anyhow::Error> {
        let clause = |query: Query| -> Result<String, Error> {
            Ok(advisory::Entity::find()
                .filtering_with(
                    query,
                    advisory::Entity
                        .columns()
                        .json_keys("purl", &["name", "type", "version"]),
                )?
                .build(sea_orm::DatabaseBackend::Postgres)
                .to_string()
                .split("WHERE ")
                .last()
                .unwrap()
                .to_string())
        };

        assert_eq!(
            clause(q("name~log4j&version>1.0"))?,
            r#"(("advisory"."purl" ->> 'name') ILIKE '%log4j%') AND ("advisory"."purl" ->> 'version') > '1.0'"#
        );
        assert_eq!(
            clause(q("name=log4j").sort("name"))?,
            r#"("advisory"."purl" ->> 'name') = 'log4j' ORDER BY "advisory"."purl" ->> 'name' ASC"#
        );
        assert_eq!(
            clause(q("foo"))?,
            r#"("advisory"."location" ILIKE '%foo%') OR ("advisory"."title" ILIKE '%foo%') OR (("purl" ->> 'name') ILIKE '%foo%') OR (("purl" ->> 'type') ILIKE '%foo%') OR (("purl" ->> 'version') ILIKE '%foo%')"#
        );
        assert!(clause(q("missing=gone")).is_err());
        assert!(clause(q("").sort("name")).is_ok());
        assert!(clause(q("").sort("nope")).is_err());
        assert!(clause(q("q=x")).is_err());

        Ok(())
    }

    #[test(tokio::test)]
    async fn columns_with_expr() -> Result<(), anyhow::Error> {
        let test = |s: &str, expected: &str, ty: ColumnType| {
            let stmt = advisory::Entity::find()
                .select_only()
                .column(advisory::Column::Id)
                .filtering_with(
                    q(s),
                    advisory::Entity.columns().add_expr(
                        "pearl",
                        SimpleExpr::FunctionCall(
                            Func::cust("get_purl".into_identity())
                                .arg(Expr::col(advisory::Column::Purl)),
                        ),
                        ty,
                    ),
                )
                .unwrap()
                .build(sea_orm::DatabaseBackend::Postgres)
                .to_string()
                .split("WHERE ")
                .last()
                .unwrap()
                .to_string();
            assert_eq!(stmt, expected);
        };

        test(
            "pearl=pkg:rpm/redhat/foo",
            r#"get_purl("purl") = 'pkg:rpm/redhat/foo'"#,
            ColumnType::Text,
        );
        test("pearl=42", r#"get_purl("purl") = 42"#, ColumnType::Integer);

        Ok(())
    }
}
