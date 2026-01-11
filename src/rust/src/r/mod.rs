use std::{collections::HashSet, path::Path, result::Result};

use anyhow::{anyhow, Context};
use extendr_api::prelude::*;
use indexmap::IndexMap;
use memchr::memchr;

use super::geo::{GEOADBFormat, GEOEntity, GEOFTPFormat, GEOType};

mod error;
mod helper;
mod resolver;
mod soft;

use resolver::GEOFormat;

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
    resolver::resolvers_from_format(
        &accession,
        &format,
        &amount,
        &scope,
        &ftp_over_https,
        |gtype| match gtype {
            GEOType::Datasets | GEOType::Platforms | GEOType::Series => {
                GEOFormat::FTP(GEOFTPFormat::SOFT)
            }
            GEOType::Samples => GEOFormat::ADB(GEOADBFormat::Text),
        },
    )
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
    resolver::resolvers_from_famount(&accession, &famount, &scope, &ftp_over_https, |_| {
        GEOFormat::ADB(GEOADBFormat::Html)
    })
    .map_err(|e| format!("{:?}", e))
    .map(|resolvers| {
        resolvers
            .into_iter()
            .map(|resovler| resovler.landing_page())
            .collect()
    })
}

#[extendr]
fn geo_file_url_and_fname(
    accession: Robj,
    famount: Robj,
    scope: Robj,
    ftp_over_https: Robj,
) -> Result<extendr_api::List, String> {
    let (urls, fnames): (Vec<String>, Vec<Option<String>>) =
        resolver::resolvers_from_famount(&accession, &famount, &scope, &ftp_over_https, |gtype| {
            match gtype {
                GEOType::Datasets | GEOType::Platforms | GEOType::Series => {
                    GEOFormat::FTP(GEOFTPFormat::SOFT)
                }
                GEOType::Samples => GEOFormat::ADB(GEOADBFormat::Text),
            }
        })
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
fn geo_parse_soft(
    path: &str,
    format: &str,
    reuse_buffer: bool,
    pprof_file: &str,
) -> Result<Vec<Robj>, String> {
    let guard = pprof::ProfilerGuardBuilder::default()
        .frequency(2000)
        .build()
        .with_context(|| format!("cannot create profile guard"))
        .map_err(|e| format!("{:?}", e))?;
    let path: &Path = path.as_ref();
    let iter_records: Box<dyn Iterator<Item = anyhow::Result<soft::GEOSoftRecord>>>;
    let mut reader = soft::GEOSoftReader::from_path(path).map_err(|err| format!("{}", err))?;
    let format = match format {
        "standard" => soft::GEOSoftFormat::Standard,
        "matrix" => soft::GEOSoftFormat::Matrix,
        _ => {
            return Err(error::RGEOParseError::InvalidSoftFormat)
                .with_context(|| format!("Invalid format"))
                .map_err(|err| format!("{:?}", err));
        }
    };
    reader.format(format);
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
    let out = iter_records
        .map(|record_res| {
            record_res.map_or_else(
                |err| Err(err),
                |record| record.try_into().map_err(|err| anyhow!("{}", err)),
            )
        })
        .collect::<anyhow::Result<Vec<Robj>>>()
        .map_err(|err| format!("{:?}", err));

    if let Ok(report) = guard.report().build() {
        let file = std::fs::File::create(pprof_file)
            .with_context(|| format!("Failed to create file {}", pprof_file))
            .map_err(|e| format!("{:?}", e))?;
        let mut options = pprof::flamegraph::Options::default();
        options.image_width = Some(2500);
        report
            .flamegraph_with_options(file, &mut options)
            .with_context(|| format!("Failed to write flamegraph to {}", pprof_file))
            .map_err(|e| format!("{:?}", e))?;
    };
    out
}

#[extendr]
fn parse_key_value_elements(elements: Robj, separator: u8) -> Result<extendr_api::List, String> {
    let list = elements
        .as_list()
        .ok_or_else(|| format!("Invalid elements: Expected a list of character vector"))?;

    let element_vec = list
        .as_slice()
        .into_iter()
        .map(|robj| {
            robj.as_str_vector()
                .ok_or_else(|| format!("Invalid elements: Expected a list of character vector"))
        })
        .collect::<Result<Vec<Vec<&str>>, String>>()?;

    let mut out: IndexMap<&str, Vec<Option<&str>>> = IndexMap::new();
    let mut keys = HashSet::new();
    let mut reference;
    let mut num_added = 0;
    let total = element_vec.capacity();
    for elements in element_vec {
        if let Some(num_elements) = elements.len().checked_sub(out.len()) {
            out.reserve(num_elements);
        }
        reference = keys.clone(); // used to follow if added elements
        for element in elements {
            // for each paired element in the format of  'key: value'
            let element_bytes = element.as_bytes();
            if let Some(pos) = memchr(separator, element_bytes) {
                if pos + 1 < element_bytes.len() {
                    // SAFETY: bytes is coming from string
                    let label =
                        unsafe { str::from_utf8_unchecked(element_bytes.get_unchecked(..pos)) }
                            .trim_ascii();
                    let value =
                        unsafe { str::from_utf8_unchecked(element_bytes.get_unchecked(pos + 1..)) }
                            .trim_ascii();
                    if let Some(entry) = out.get_mut(label) {
                        entry.push(Some(value));
                        reference.remove(label);
                    } else {
                        let mut entry = Vec::with_capacity(total);
                        entry.resize(num_added, None);
                        entry.push(Some(value));
                        out.insert(label, entry);
                        keys.insert(label);
                    }
                }
            }
        }
        num_added += 1;
        // For entry not added in this elements, we add None
        for key in reference {
            if let Some(entry) = out.get_mut(key) {
                entry.push(None);
            }
        }
    }
    let (keys, columns): (Vec<_>, Vec<_>) = out
        .into_iter()
        .map(|(key, value)| (key, helper::parse_string(value)))
        .unzip();
    let mut olist = extendr_api::List::from_values(columns);
    olist.set_names(keys)?;
    Ok(olist)
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
    fn geo_file_url_and_fname;
    fn geo_parse_soft;
    fn is_all_same;
    fn parse_key_value_elements;
}
