use std::result::Result;

use anyhow::{anyhow, Context};
use extendr_api::prelude::*;

use super::resolver::{self, GEOEntry, GEOParseError};

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
    format: Robj,
    amount: Robj,
    scope: Robj,
    over_https: Robj,
) -> Result<Vec<String>, String> {
    resolvers_from_robj(&accession, &format, &amount, &scope, &over_https).map(|resolvers| {
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
    let resolver = match famount {
        None | Some("none") | Some("brief") | Some("quick") | Some("data") | Some("full") => {
            resolver::GEOResolver::new(accession, "html", famount, scope, over_https)
        }
        Some("soft") | Some("soft_full") | Some("miniml") | Some("matrix") | Some("annot")
        | Some("suppl") => {
            let format = unsafe { famount.unwrap_unchecked() };
            resolver::GEOResolver::new(accession, format, None, None, over_https)
        }
        // ---------- Invalid famount ----------
        // If famount is not in ACC or FTP categories, return error.
        _ => {
            return Err(GEOParseError::InvalidFamount)
                .with_context(|| {
                    // Safe unwrap ('famount' is Some in this branch)
                    let famount = unsafe { famount.unwrap_unchecked() };
                    format!("Invalid 'famount': {}", famount)
                })
                .map_err(|e| format!("{:?}", e));
        }
    };
    resolver.map_or_else(
        |e| Err(format!("{:?}", e)),
        |resovler| Ok(resovler.landing_page()),
    )
}

extendr_module! {
    mod r;
    fn geo_gtype;
    fn geo_url;
    fn geo_landing_page;
}
