use std::{path::Path, result::Result};

use anyhow::{anyhow, Context};
use extendr_api::prelude::*;

use super::geo::GEOEntity;

mod error;
mod helper;
mod resolver;
mod soft;

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
    resolver::resolvers_from_format_url(&accession, &format, &amount, &scope, &ftp_over_https)
        .map_err(|e| format!("{:?}", e))
        .map(|resolvers| {
            resolvers
                .into_iter()
                .map(|resovler| resovler.url())
                .collect()
        })
}

#[extendr]
fn geo_landing_page(
    accession: Robj,
    famount: Robj,
    scope: Robj,
    ftp_over_https: Robj,
) -> Result<Vec<String>, String> {
    resolver::resolvers_from_famount_landing(&accession, &famount, &scope, &ftp_over_https)
        .map_err(|e| format!("{:?}", e))
        .map(|resolvers| {
            resolvers
                .into_iter()
                .map(|resovler| resovler.landing_page())
                .collect()
        })
}

#[extendr]
fn geo_soft_url_and_fname(
    accession: Robj,
    famount: Robj,
    scope: Robj,
    ftp_over_https: Robj,
) -> Result<extendr_api::List, String> {
    let (urls, fnames): (Vec<String>, Vec<Option<String>>) =
        resolver::resolvers_from_famount_soft(&accession, &famount, &scope, &ftp_over_https)
            .map_err(|e| format!("{:?}", e))
            .map(|resolvers| {
                resolvers
                    .into_iter()
                    .map(|resovler| (resovler.url(), resovler.fname()))
                    .unzip()
            })?;
    Ok(extendr_api::list![urls = urls, fnames = fnames])
}

#[extendr]
fn geo_parse_soft(path: &str, reuse_buffer: bool) -> Result<Vec<Robj>, String> {
    let path: &Path = path.as_ref();
    let iter_records: Box<dyn Iterator<Item = anyhow::Result<soft::GEOSoftRecord>>>;
    let mut reader = soft::GEOSoftReader::from_path(path).map_err(|err| format!("{}", err))?;
    reader.reuse_buffer(reuse_buffer);
    if path
        .extension()
        .and_then(|e| e.to_str())
        .map_or(false, |s| s.eq_ignore_ascii_case("gz"))
    {
        iter_records = Box::new(reader.into_gzip_reader());
    } else {
        iter_records = Box::new(reader);
    }
    iter_records
        .map(|record_res| {
            record_res.map_or_else(
                |err| Err(err),
                |record| record.try_into().map_err(|err| anyhow!("{}", err)),
            )
        })
        .collect::<anyhow::Result<Vec<Robj>>>()
        .map_err(|err| format!("{:?}", err))
}

#[extendr]
fn is_all_same(x: Robj) -> Result<bool, String> {
    let x = x
        .as_str_vector()
        .ok_or_else(|| format!("Expected a character vector"))?;
    if x.is_empty() {
        return Ok(true); // Empty collection is considered "uniform"
    }

    // SAFETY, x is not empty
    let reference = *unsafe { x.get_unchecked(0) };

    for item in x {
        if item != reference {
            return Ok(true); // Return false as soon as a different value is found
        }
    }

    Ok(true) // All values are the same
}

extendr_module! {
    mod r;
    fn geo_gtype;
    fn geo_url;
    fn geo_landing_page;
    fn geo_soft_url_and_fname;
    fn geo_parse_soft;
    fn is_all_same;
}
