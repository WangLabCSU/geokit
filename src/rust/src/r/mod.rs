use std::result::Result;

use anyhow::{anyhow, Context};
use extendr_api::prelude::*;

use super::geo::{GEOADBFormat, GEOEntity};

mod error;
mod helper;
mod resolver;

#[extendr]
fn geo_gtype(accession: Robj, abbre: bool) -> Result<Vec<String>, String> {
    accession
        .as_str_vector()
        .ok_or_else(|| anyhow!("Expected a character vector"))
        .with_context(|| format!("Invalid 'accession'"))
        .map_err(|e| format!("{:?}", e))?
        .iter()
        .map(|acc| {
            GEOEntity::try_from(*acc)
                .map(|entity| {
                    if abbre {
                        entity.gtype().abbre().to_string()
                    } else {
                        entity.gtype().to_string()
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
    ftp_over_https: Robj,
) -> Result<Vec<String>, String> {
    resolver::resolvers_from_format(&accession, &format, &amount, &scope, &ftp_over_https).map(
        |resolvers| {
            resolvers
                .into_iter()
                .map(|resovler| resovler.url())
                .collect()
        },
    )
}

#[extendr]
fn geo_landing_page(
    accession: Robj,
    famount: Robj,
    scope: Robj,
    ftp_over_https: Robj,
) -> Result<Vec<String>, String> {
    resolver::resolvers_from_famount(
        &accession,
        &famount,
        &scope,
        &ftp_over_https,
        &GEOADBFormat::Html,
    )
    .map(|resolvers| {
        resolvers
            .into_iter()
            .map(|resovler| resovler.landing_page())
            .collect()
    })
}

extendr_module! {
    mod r;
    fn geo_gtype;
    fn geo_url;
    fn geo_landing_page;
}
