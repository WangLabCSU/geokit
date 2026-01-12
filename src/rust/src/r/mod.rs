use std::{collections::HashSet, path::Path, result::Result};

use anyhow::{anyhow, Context};
use extendr_api::prelude::*;
use indexmap::IndexMap;
use indicatif::{ParallelProgressIterator, ProgressBar, ProgressStyle};
use memchr::memchr;
use rayon::{
    iter::{IndexedParallelIterator, IntoParallelRefIterator, ParallelIterator},
    ThreadPoolBuilder,
};

use crate::r::soft::GEOSoftRecord;

use super::geo::{GEOEntity, GEOType};

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
    resolver::resolvers_from_format(
        &accession,
        &format,
        &amount,
        &scope,
        &ftp_over_https,
        |gtype| match gtype {
            GEOType::Datasets | GEOType::Platforms | GEOType::Series => "soft",
            GEOType::Samples => "text",
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
    resolver::resolvers_from_famount(
        &accession,
        &famount,
        &scope,
        &ftp_over_https,
        |_| "brief",
        "html",
    )
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
    let (urls, fnames): (Vec<String>, Vec<_>) = resolver::resolvers_from_famount(
        &accession,
        &famount,
        &scope,
        &ftp_over_https,
        |gtype| match gtype {
            GEOType::Datasets | GEOType::Series => "soft",
            GEOType::Platforms | GEOType::Samples => "full",
        },
        "text",
    )
    .map_or_else(
        |e| Err(format!("Failed to initialize the resolvers: {:?}", e)),
        |resolvers| {
            resolvers
                .into_iter()
                .map(|resolver| {
                    resolver
                        .fname()
                        .ok_or_else(|| {
                            format!(
                                "Missing filename for resolver with URL '{}'. {}",
                                resolver.url(),
                                "Ensure that the famount is correct (e.g., not 'suppl' or 'matrix' type)."
                            )
                        })
                        .map(|fname| (resolver.url(), fname))
                })
                .collect::<Result<Vec<_>, String>>() // Collecting the mapped results into a Result<Vec<_>, String>
                .map(|items| items.into_iter().unzip()) // Using unzip only after it's a valid Result
        },
    )?;
    Ok(extendr_api::list![urls = urls, fnames = fnames])
}

#[extendr]
fn geo_parse_soft(
    path: Robj,
    format: Robj,
    reuse_buffer: bool,
    threads: Option<usize>,
) -> Result<List, String> {
    let path = path
        .as_str_vector()
        .ok_or_else(|| anyhow!("Expected a character vector"))
        .with_context(|| format!("Invalid 'path'"))
        .map_err(|err| format!("{:?}", err))?;
    let format = format
        .as_str_vector()
        .ok_or_else(|| anyhow!("Expected a character vector"))
        .with_context(|| format!("Invalid 'format'"))
        .map_err(|err| format!("{:?}", err))?;

    // use rayon to implement parallel
    let mut pool_builder = ThreadPoolBuilder::new();
    if let Some(threads) = threads {
        pool_builder = pool_builder.num_threads(threads);
    }
    let record_res = pool_builder
        .build()
        .with_context(|| format!("Failed to create rayon thread pool"))
        .map_err(|err| format!("{:?}", err))?
        .install(|| {
            // for each path, we parse the soft file, each file has multiple records
            let style = ProgressStyle::with_template(
                "{prefix:.bold.cyan/blue} {human_pos}/{human_len} {spinner:.green} [{elapsed_precise}] {per_sec} (ETA {eta})",
            )?;
            path.par_iter()
                .zip(format)
                .progress()
                .with_prefix("Parsing GEO File")
                .with_style(style)
                .map(|(path, format)| geo_parse_soft_impl(path, format, reuse_buffer))
                .collect::<Result<Vec<Vec<GEOSoftRecord>>, _>>()
        });

    let out = record_res
        .map_err(|err| format!("{:?}", err))?
        // for each record, we convert it into a Robj
        .into_iter()
        .map(|record_vec| {
            record_vec
                .into_iter()
                .map(|record| record.try_into().map_err(|err| anyhow!("{}", err)))
                .collect::<anyhow::Result<Vec<Robj>>>()
        })
        .collect::<anyhow::Result<Vec<Vec<Robj>>>>()
        .map_err(|err| format!("{:?}", err))?
        // for each path, all of its records are grouped into a List
        .into_iter()
        .map(|record_vec| List::from_values(record_vec))
        // in the final, we create a single list for all path
        .collect::<List>();
    Ok(out)
}

fn geo_parse_soft_impl(
    path: &str,
    format: &str,
    reuse_buffer: bool,
) -> anyhow::Result<Vec<GEOSoftRecord>> {
    let path: &Path = path.as_ref();
    let iter_records: Box<dyn Iterator<Item = anyhow::Result<soft::GEOSoftRecord>>>;
    let mut reader = soft::GEOSoftReader::from_path(path)?;
    let format = match format {
        "standard" => soft::GEOSoftFormat::Standard,
        "matrix" => soft::GEOSoftFormat::Matrix,
        _ => {
            return Err(error::RGEOParseError::InvalidSoftFormat)
                .with_context(|| format!("Invalid format"));
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
    iter_records.collect::<anyhow::Result<Vec<_>>>()
}

#[extendr]
#[cfg(feature = "pprof")]
fn pprof_geo_parse_soft(
    path: Robj,
    format: Robj,
    reuse_buffer: bool,
    threads: usize,
    pprof_file: &str,
) -> Result<Vec<Robj>, String> {
    let guard = pprof::ProfilerGuardBuilder::default()
        .frequency(2000)
        .build()
        .with_context(|| format!("Failed to create profile guard"))
        .map_err(|e| format!("{:?}", e))?;
    let out = geo_parse_soft(path, format, reuse_buffer, threads);
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
fn parse_key_value_elements(elements: List, separator: u8) -> Result<extendr_api::List, String> {
    let element_vec = elements
        .as_slice()
        .into_iter()
        .map(|robj| {
            robj.as_str_vector()
                .ok_or_else(|| format!("Invalid elements: Expected a list of character vector"))
        })
        .collect::<Result<Vec<Vec<&str>>, String>>()?;

    let mut out: IndexMap<&str, Vec<Option<String>>> = IndexMap::new();
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
                        // add it or append it to the exist one
                        if reference.contains(label) {
                            entry.push(Some(value.to_owned()));
                            reference.remove(label);
                        } else {
                            if let Some(last) = entry.pop() {
                                if let Some(last_str) = last {
                                    let new = format!("{}; {}", last_str, value);
                                    entry.push(Some(new));
                                } else {
                                    entry.push(Some(value.to_owned()));
                                }
                            }
                        }
                    } else {
                        let mut entry = Vec::with_capacity(total);
                        entry.resize(num_added, None);
                        entry.push(Some(value.to_owned()));
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

#[cfg(not(feature = "pprof"))]
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

#[cfg(feature = "pprof")]
extendr_module! {
    mod r;
    fn geo_gtype;
    fn geo_url;
    fn geo_landing_page;
    fn geo_file_url_and_fname;
    fn geo_parse_soft;
    fn pprof_geo_parse_soft;
    fn is_all_same;
    fn parse_key_value_elements;
}
