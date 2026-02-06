use std::{
    borrow::Cow,
    fs::File,
    io::{self, BufReader, Read},
    path::Path,
};

use anyhow::{anyhow, Context};
use extendr_api::{extendr, extendr_module, Attributes, List, Robj};
use hashbrown::HashSet;
use indexmap::IndexMap;
use indicatif::{ProgressBar, ProgressFinish, ProgressStyle};
use memchr::memchr;
use rayon::{
    iter::{IndexedParallelIterator, IntoParallelRefIterator, ParallelIterator},
    ThreadPoolBuilder,
};

#[cfg(not(feature = "isal"))]
use flate2::bufread::GzDecoder as GzipDecoder;
#[cfg(feature = "isal")]
use isal::read::GzipDecoder;

use super::geo::{GEOEntity, GEOSoftFormat, GEOSoftLine, GEOSoftReader, GEOType};

mod error;
mod helper;
mod resolver;
mod soft;

use soft::RGEOSoftRecord;

#[extendr]
fn geo_gtype(accession: Robj, abbre: bool) -> Result<Vec<String>, String> {
    accession
        .as_str_vector()
        .ok_or_else(|| anyhow!("Expected a character vector"))
        .with_context(|| "Invalid 'accession'".to_string())
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
    use_lines: Robj,
    threads: Option<usize>,
) -> Result<List, String> {
    let path = path
        .as_str_vector()
        .ok_or_else(|| anyhow!("Expected a character vector"))
        .with_context(|| "Invalid 'path'".to_string())
        .map_err(|err| format!("{:?}", err))?;
    let format = helper::robj_to_vec_str(&format, path.len())
        .with_context(|| "Invalid 'format'".to_string())
        .map_err(|err| format!("{:?}", err))?;
    let use_lines = helper::robj_to_option_vec_str(&use_lines, path.len())
        .with_context(|| "Invalid 'use_lines'".to_string())
        .map_err(|err| format!("{:?}", err))?;

    // use rayon to implement parallel
    let mut pool_builder = ThreadPoolBuilder::new();
    if let Some(threads) = threads {
        pool_builder = pool_builder.num_threads(threads);
    }
    let record_res = pool_builder
        .build()
        .with_context(|| "Failed to create rayon thread pool".to_string())
        .map_err(|err| format!("{:?}", err))?
        .install(|| {
            // for each path, we parse the soft file, each file has multiple records
            let style = ProgressStyle::with_template(
                "{prefix:.bold.cyan/blue} {human_pos}/{human_len} {spinner:.green} [{elapsed_precise}] {per_sec} (ETA {eta})",
            ).with_context(|| "Invalid progress style".to_string())?;
            let pb = ProgressBar::new(path.len() as u64)
                .with_prefix("Parsing GEO File")
                .with_style(style)
                .with_finish(ProgressFinish::Abandon);
            path.par_iter()
                .zip(format)
                .map(|(path, format)| {
                    let out = geo_parse_soft_impl(path, format, &use_lines.as_deref());
                    pb.inc(1);
                    out
                })
                .collect::<Result<Vec<Vec<RGEOSoftRecord>>, _>>()
        })
        .map_err(|err| format!("{:?}", err))?;

    // Building the result into R object
    let style = ProgressStyle::with_template(
        "{prefix:.bold.cyan/blue} {human_pos}/{human_len} {spinner:.green} [{elapsed_precise}] {per_sec} (ETA {eta})",
    ).with_context(|| "Invalid progress style".to_string()).map_err(|err| format!("{:?}", err))?;
    let pb = ProgressBar::new(record_res.len() as u64)
        .with_prefix("Building R object")
        .with_style(style)
        .with_finish(ProgressFinish::Abandon);
    record_res
        // each vec containing all records found in the file
        .into_iter()
        .map(|record_vec| {
            // for each record in the file, we convert it into a Robj
            // and then collected all records into a list
            let out = record_vec
                .iter()
                .map(Robj::try_from)
                .collect::<Result<List, _>>();
            pb.inc(1);
            out
        })
        .collect::<Result<List, _>>()
        .map_err(|err| format!("{:?}", err))
}

fn geo_parse_soft_impl(
    path: &str,
    format: &str,
    use_lines: &Option<&[&str]>,
) -> anyhow::Result<Vec<RGEOSoftRecord>> {
    let path: &Path = path.as_ref();
    let file =
        File::open(path).with_context(|| format!("Failed to open file: {}", path.display()))?;
    let format = match format {
        "standard" => GEOSoftFormat::Standard,
        "matrix" => GEOSoftFormat::Matrix,
        _ => {
            return Err(error::RGEOParseError::InvalidSoftFormat)
                .with_context(|| "Invalid 'format'".to_string());
        }
    };
    let reader: Box<dyn Read> = if path
        .extension()
        .and_then(|e| e.to_str())
        .is_some_and(|s| s.eq_ignore_ascii_case("gz"))
    {
        Box::new(GzipDecoder::new(BufReader::with_capacity(
            4 * (1 << 20),
            file,
        )))
    } else {
        Box::new(file)
    };

    let mut builder = GEOSoftReader::<Box<dyn Read>>::builder();
    builder.format(format);
    if let Some(use_lines) = use_lines {
        for line in *use_lines {
            let line = match *line {
                "datatable" => GEOSoftLine::Datatable,
                "metadata" => GEOSoftLine::Metadata,
                _ => {
                    return Err(error::RGEOParseError::InvalidSoftLines)
                        .with_context(|| "Invalid 'use_lines'".to_string())
                }
            };
            builder.line(line);
        }
    }
    let mut reader = builder.build_from_reader(reader);
    let records = reader.records();
    let out = records
        .map(|record_res| record_res.map(RGEOSoftRecord::from))
        .collect::<io::Result<Vec<_>>>()?;
    Ok(out)
}

#[extendr]
#[cfg(feature = "pprof")]
fn pprof_geo_parse_soft(
    path: Robj,
    format: Robj,
    use_lines: Robj,
    threads: Option<usize>,
    pprof_file: &str,
) -> Result<List, String> {
    let guard = pprof::ProfilerGuardBuilder::default()
        .frequency(2000)
        .build()
        .with_context(|| format!("Failed to create pprof profile guard"))
        .map_err(|e| format!("{:?}", e))?;
    let out = geo_parse_soft(path, format, use_lines, threads);
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
#[cfg(not(feature = "pprof"))]
fn pprof_geo_parse_soft(
    _path: Robj,
    _format: Robj,
    _use_lines: Robj,
    _threads: Option<usize>,
    _pprof_file: &str,
) -> Result<List, String> {
    Err(r###"
This function requires the 'pprof' feature. 
Please compile with the '--features pprof' argument or set the 'GEOKIT_FEATURES' environment variable to 'pprof'.
        "###.to_string())
}

#[extendr]
fn parse_key_value_elements(elements: List, separator: u8) -> Result<extendr_api::List, String> {
    let element_vec = elements
        .as_slice()
        .iter()
        .map(|robj| {
            robj.as_str_vector()
                .ok_or_else(|| "Invalid elements: Expected a list of character vector".to_string())
        })
        .collect::<Result<Vec<Vec<&str>>, String>>()?;

    let mut out: IndexMap<&str, Vec<Option<Cow<str>>>> = IndexMap::new();
    // A set to track which keys we've added so far.
    let mut keys = HashSet::new();
    // Placeholder for remaining keys that still need to be added.
    let mut remaining_keys;
    // Get the total number of elements for size optimization.
    let total = element_vec.capacity();

    // Iterate over each list of elements (e.g., rows of key-value pairs).
    for (num_added, elements) in element_vec.into_iter().enumerate() {
        // reserve the spaces to be added
        if let Some(num_elements) = elements.len().checked_sub(out.len()) {
            out.reserve(num_elements);
        }
        // Create a copy of the set of keys to track remaining ones.
        remaining_keys = keys.clone();
        for element in elements {
            // for each paired element in the format of  'key: value'
            let element_bytes = element.as_bytes();
            if let Some(pos) = memchr(separator, element_bytes) {
                // Split the element into key and value based on the separator.
                if let (Some(label), Some(value)) =
                    (element_bytes.get(..pos), element_bytes.get((pos + 1)..))
                {
                    // SAFETY: The bytes are guaranteed to be valid UTF-8 because they are from a string.
                    let label = unsafe { str::from_utf8_unchecked(label) }.trim_ascii();
                    let value = unsafe { str::from_utf8_unchecked(value) }.trim_ascii();

                    // Check if the key already exists in the map.
                    if let Some(entry) = out.get_mut(label) {
                        // If key exists, append the value or concatenate it with existing ones.
                        if remaining_keys.remove(label) {
                            // we have not added it, just append it to the entry
                            entry.push(Some(Cow::Borrowed(value)));
                        } else if let Some(last_opt) = entry.last_mut() {
                            if let Some(last_cow) = last_opt {
                                // Concatenate values if there are multiple for the same key.
                                let new = format!("{}; {}", last_cow, value);
                                *last_cow = Cow::Owned(new);
                            } else {
                                *last_opt = Some(Cow::Borrowed(value));
                            }
                        }
                    } else {
                        // If the key doesn't exist, create a new entry.
                        let mut entry = Vec::with_capacity(total);
                        // Reserve space for previously added elements.
                        entry.resize(num_added, None);
                        entry.push(Some(Cow::Borrowed(value)));
                        out.insert(label, entry);
                        keys.insert(label); // Mark this key as added.
                    }
                };
            }
        }

        // For entry not added in this elements, we add None
        let remaining_keys = remaining_keys.iter();
        for key in remaining_keys {
            if let Some(entry) = out.get_mut(key) {
                entry.push(None);
            }
        }
    }
    let (keys, columns): (Vec<_>, Vec<_>) = out
        .into_iter()
        .map(|(key, value)| (key, helper::robj_from_parsing_str(&value)))
        .unzip();
    let mut olist = extendr_api::List::from_values(columns);
    olist.set_names(keys)?;
    Ok(olist)
}

#[extendr]
fn is_all_same(x: Robj) -> Result<bool, String> {
    let x = x
        .as_str_vector()
        .ok_or_else(|| "Expected a character vector".to_string())?;
    if let Some(&reference) = x.first() {
        for item in x {
            if item != reference {
                return Ok(false); // Return false as soon as a different value is found
            }
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
    fn pprof_geo_parse_soft;
    fn geo_parse_soft;
    fn is_all_same;
    fn parse_key_value_elements;
}
