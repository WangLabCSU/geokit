use std::result::Result;

use anyhow::{anyhow, Context};
use extendr_api::prelude::*;

use super::resolver::{self, GEOEntry};

mod helper;

use helper::resolvers_from_robj;

#[extendr]
fn geo_gtype(accession: Robj, abbre: bool) -> Result<Vec<String>, String> {
    accession
        .as_str_vector()
        .ok_or_else(|| anyhow!("Expected a character vector"))
        .with_context(|| format!("Invalid 'accession'"))
        .map_err(|e| format!("{:?}", e))?
        .iter()
        .map(|acc| {
            resolver::GEOType::try_from(*acc)
                .map(|gtype| {
                    if abbre {
                        gtype.abbre().to_string()
                    } else {
                        gtype.to_string()
                    }
                })
                .with_context(|| format!("Invalid 'accession': {}", acc))
                .map_err(|e| format!("{:?}", e))
        })
        .collect::<Result<Vec<String>, String>>()
}

#[extendr]
fn geo_url(
    accession: Robj,
    famount: Robj,
    scope: Robj,
    format: Robj,
    over_https: Robj,
) -> Result<Vec<String>, String> {
    resolvers_from_robj(&accession, &famount, &scope, &format, &over_https).map(|resolvers| {
        resolvers
            .into_iter()
            .map(|resovler| resovler.url())
            .collect()
    })
}

#[extendr]
fn geo_landing_page(
    accession: &str,
    famount: Option<&str>,
    scope: Option<&str>,
    over_https: Option<bool>,
) -> Result<String, String> {
    resolver::GEOResolver::new(accession, famount, scope, Some("html"), over_https).map_or_else(
        |e| Err(format!("{:?}", e)),
        |resovler| {
            resovler.entry().map_or_else(
                || Ok(resovler.url()),
                |entry| {
                    let url = resovler.url();
                    match entry {
                        GEOEntry::Dir => Ok(url),
                        GEOEntry::File(_) => std::path::Path::new(&url)
                            .parent()
                            .ok_or_else(|| format!("Failed to locate the landing page of {}", url))
                            .map(|o| format!("{}", o.to_string_lossy())),
                    }
                },
            )
        },
    )
}

extendr_module! {
    mod r;
    fn geo_gtype;
    fn geo_url;
    fn geo_landing_page;
}
