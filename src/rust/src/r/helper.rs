use anyhow::{anyhow, Result};
use extendr_api::prelude::*;
use rand::{prelude::IteratorRandom, rng};

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

/// Convert a column represented as Vec<Option<String>> into the most specific R vector.
///
/// Sampling-based inference: test up to SAMPLE_SIZE non-NA cells to decide whether the
/// column can be parsed as i32, f64, or bool. If so, parse the whole column once and
/// return an R vector of that type. Otherwise, return an R character vector created
/// directly from the input `value` (no cloning).
pub(in crate::r) fn parse_string(value: Vec<Option<String>>) -> Robj {
    const SAMPLE_SIZE: usize = 10_000;

    let reservoir = if value.len() <= SAMPLE_SIZE {
        (0..value.len()).collect()
    } else {
        let mut rng = rng();
        (0..value.len()).choose_multiple(&mut rng, SAMPLE_SIZE)
    };

    // Fast sample pass (no allocations): inspect up to SAMPLE_SIZE non-None cells.
    let mut can_int = true;
    let mut can_f64 = true;
    let mut can_bool = true;

    for index in reservoir {
        // SAFETY: reservoir indices are within bounds of value
        if let Some(s) = unsafe { value.get_unchecked(index) } {
            if can_f64 && s.parse::<f64>().is_err() {
                can_int = false; // int can be parsed by f64
                can_f64 = false;
            }
            if can_int && s.parse::<i32>().is_err() {
                can_f64 = false;
            }
            if can_bool && !(s.eq_ignore_ascii_case("true") || s.eq_ignore_ascii_case("false")) {
                can_bool = false;
            }
            if !can_int && !can_f64 && !can_bool {
                break;
            }
        }
    }

    // Parse whole column once according to inferred type (prefer integer over float).
    if can_int {
        let parsed: Vec<Option<i32>> = value
            .into_iter()
            .map(|opt| opt.and_then(|s| s.trim().parse::<i32>().ok()))
            .collect();
        return Robj::from(parsed);
    }

    if can_f64 {
        let parsed: Vec<Option<f64>> = value
            .into_iter()
            .map(|opt| opt.and_then(|s| s.trim().parse::<f64>().ok()))
            .collect();
        return Robj::from(parsed);
    }

    if can_bool {
        let parsed: Vec<Option<bool>> = value
            .into_iter()
            .map(|opt| {
                opt.and_then(|s| {
                    let s = s.trim();
                    if s.eq_ignore_ascii_case("true") {
                        Some(true)
                    } else if s.eq_ignore_ascii_case("false") {
                        Some(false)
                    } else {
                        None
                    }
                })
            })
            .collect();
        return Robj::from(parsed);
    }

    // Fallback: keep as character vector, reuse original `value` (no extra cloning).
    Robj::from(value)
}
