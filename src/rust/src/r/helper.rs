use std::str::FromStr;

use anyhow::{anyhow, Result};
use extendr_api::prelude::*;

/// Convert an R object to a string vector of length `len`.
/// - If the R object has length 1, its value is recycled.
/// - Otherwise, its length must match `len`.
pub(in crate::r) fn robj_to_vec_str<'a>(value: &'a Robj, len: usize) -> Result<Vec<&'a str>> {
    let value = value
        .as_str_vector()
        .ok_or_else(|| anyhow!("Expected a character vector"))?;

    match value.len() {
        1 => Ok(vec![unsafe { *value.get_unchecked(0) }; len]), // recycle single value
        n if n == len => Ok(value),
        n => Err(anyhow!(
            "Length mismatch: got {} element(s), but expected {}",
            n,
            len
        )),
    }
}

/// Convert an R object to an optional string vector (with recycling).
/// Returns `None` if the R object is NULL.
pub(in crate::r) fn robj_to_option_vec_str<'a>(
    value: &'a Robj,
    len: usize,
) -> Result<Option<Vec<&'a str>>> {
    if value.is_null() {
        return Ok(None);
    }
    robj_to_vec_str(value, len).map(|o| Some(o))
}

/// Convert an R object to an optional boolean vector (with recycling).
/// Returns `None` if the R object is NULL.
/// Fails if the R object contains `NA`.
pub(in crate::r) fn robj_to_option_vec_bool(value: &Robj, len: usize) -> Result<Option<Vec<bool>>> {
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

pub(in crate::r) fn parse_string(value: Vec<Option<String>>) -> Robj {
    let input_str = value
        .iter()
        .map(|option_str| option_str.as_ref().map(|s| s.as_str()))
        .collect::<Vec<_>>();

    if let Ok(i32_vec) = input_str
        .iter()
        .map(|option_str| option_str.map(|s| s.parse::<i32>()).transpose())
        .collect::<std::result::Result<Vec<Option<i32>>, <i32 as FromStr>::Err>>()
    {
        return Robj::from(i32_vec);
    };
    if let Ok(f64_vec) = input_str
        .iter()
        .map(|option_str| option_str.map(|s| s.parse::<f64>()).transpose())
        .collect::<std::result::Result<Vec<Option<f64>>, <f64 as FromStr>::Err>>()
    {
        return Robj::from(f64_vec);
    };
    if let Ok(bool_vec) = input_str
        .iter()
        .map(|option_str| {
            option_str
                .map(|s| s.to_ascii_lowercase().parse::<bool>())
                .transpose()
        })
        .collect::<std::result::Result<Vec<Option<bool>>, <bool as FromStr>::Err>>()
    {
        return Robj::from(bool_vec);
    };
    Robj::from(value)
}
