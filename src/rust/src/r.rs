use std::result::Result;

use anyhow::Context;
use extendr_api::prelude::*;

use super::resolver;
use crate::resolver::GEOEntry;

#[extendr]
fn geo_gtype(accession: &str, abbre: bool) -> Result<String, String> {
    resolver::GEOType::try_from(accession)
        .map(|gtype| {
            if abbre {
                gtype.abbre().to_string()
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

#[extendr]
fn geo_landing_url(
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
    fn geo_landing_url;
}
