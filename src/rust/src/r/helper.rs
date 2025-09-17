use anyhow::{anyhow, Context, Result};
use extendr_api::prelude::*;

use crate::resolver;

pub(super) fn resolvers_from_robj(
    accession: &Robj,
    famount: &Robj,
    format: &Robj,
    scope: &Robj,
    over_https: &Robj,
) -> Result<Vec<resolver::GEOResolver>, String> {
    let accession = accession
        .as_str_vector()
        .ok_or_else(|| anyhow!("Expected a character vector"))
        .with_context(|| format!("Invalid 'accession'"))
        .map_err(|e| format!("{:?}", e))?;
    let famount = robj_to_option_vec_str(&famount, accession.len())
        .with_context(|| format!("Invalid 'famount'"))
        .map_err(|e| format!("{:?}", e))?;
    let format = robj_to_option_vec_str(&format, accession.len())
        .with_context(|| format!("Invalid 'format'"))
        .map_err(|e| format!("{:?}", e))?;
    let scope = robj_to_option_vec_str(&scope, accession.len())
        .with_context(|| format!("Invalid 'scope'"))
        .map_err(|e| format!("{:?}", e))?;
    let over_https = robj_to_option_vec_bool(&over_https, accession.len())
        .with_context(|| format!("Invalid 'over_https'"))
        .map_err(|e| format!("{:?}", e))?;
    accession
        .into_iter()
        .enumerate()
        .map(|(i, acc)| {
            let famount = famount.as_ref().map(|v| v[i]);
            let format = format.as_ref().map(|v| v[i]);
            let scope = scope.as_ref().map(|v| v[i]);
            let over_https = over_https.as_ref().map(|v| v[i]);
            resolver::GEOResolver::new(acc, famount, format, scope, over_https)
                .map_err(|e| format!("{:?}", e))
        })
        .collect()
}

fn robj_to_option_vec_str<'a>(value: &'a Robj, len: usize) -> Result<Option<Vec<&'a str>>> {
    if value.is_null() {
        return Ok(None);
    }

    let value = value
        .as_str_vector()
        .ok_or_else(|| anyhow!("Expected a character vector"))?;

    match value.len() {
        1 => Ok(Some(vec![unsafe { *value.get_unchecked(0) }; len])), // recycle single value
        n if n == len => Ok(Some(value)),
        n => Err(anyhow!(
            "Length mismatch: got {} element(s), but expected {}",
            n,
            len
        )),
    }
}

fn robj_to_option_vec_bool(value: &Robj, len: usize) -> Result<Option<Vec<bool>>> {
    if value.is_null() {
        return Ok(None);
    }
    let value = value
        .as_logical_slice()
        .ok_or_else(|| anyhow!("Expected a logical vector"))?
        .iter()
        .map(|rbool| {
            if rbool.is_true() {
                Ok(true)
            } else if rbool.is_false() {
                Ok(false)
            } else {
                Err(anyhow!("missing value is not allowed"))
            }
        })
        .collect::<Result<Vec<bool>, anyhow::Error>>()?;

    match value.len() {
        1 => Ok(Some(vec![unsafe { *value.get_unchecked(0) }; len])), // recycle single value
        n if n == len => Ok(Some(value)),
        n => Err(anyhow!(
            "Length mismatch: got {} element(s), but expected {}",
            n,
            len
        )),
    }
}
