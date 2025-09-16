use std::result::Result;

use anyhow::Context;
use extendr_api::prelude::*;

use super::resolver;

#[extendr]
fn geo_gtype(accession: &str, abbre: bool) -> Result<String, String> {
    resolver::GEOType::try_from(accession)
        .map(|gtype| {
            if abbre {
                gtype.prefix().to_string()
            } else {
                gtype.to_string()
            }
        })
        .with_context(|| format!("Invalid accession: {}", accession))
        .map_err(|e| format!("{:?}", e))
}

#[extendr]
fn geo_url(
    accession: &str,
    famount: Option<&str>,
    scope: Option<&str>,
    format: Option<&str>,
    over_https: Option<bool>,
) -> Result<String, String> {
    resolver::GEOResolver::new(accession, famount, scope, format, over_https)
        .map(|resovler| resovler.url())
        .map_err(|e| format!("{:?}", e))
}

extendr_module! {
    mod r;
    fn geo_gtype;
    fn geo_url;
}
