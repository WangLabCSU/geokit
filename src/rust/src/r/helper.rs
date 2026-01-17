use anyhow::{anyhow, Result};
use extendr_api::{Rinternals, Robj};

/// Convert an R object to a string vector of length `len`.
/// - If the R object has length 1, its value is recycled.
/// - Otherwise, its length must match `len`.
pub(in crate::r) fn robj_to_vec_str(value: &Robj, len: usize) -> Result<Vec<&str>> {
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
pub(in crate::r) fn robj_to_option_vec_str(
    value: &Robj,
    len: usize,
) -> Result<Option<Vec<&str>>> {
    if value.is_null() {
        return Ok(None);
    }
    robj_to_vec_str(value, len).map(Some)
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
