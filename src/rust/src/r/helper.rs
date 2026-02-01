use anyhow::{anyhow, Result};
use extendr_api::{Rinternals, Robj};

/// Convert an R object to a string vector of length `len`.
/// - If the R object has length 1, its value is recycled.
/// - Otherwise, its length must match `len`.
pub(super) fn robj_to_vec_str(value: &Robj, len: usize) -> Result<Vec<&str>> {
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
pub(super) fn robj_to_option_vec_str(value: &Robj, len: usize) -> Result<Option<Vec<&str>>> {
    if value.is_null() {
        return Ok(None);
    }
    robj_to_vec_str(value, len).map(Some)
}

/// Convert an R object to an optional boolean vector (with recycling).
/// Returns `None` if the R object is NULL.
/// Fails if the R object contains `NA`.
pub(super) fn robj_to_option_vec_bool(value: &Robj, len: usize) -> Result<Option<Vec<bool>>> {
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

/// Sampling-based inference: test up to SAMPLE_SIZE cells to decide whether the
/// column can be parsed as i32, f64, or bool. If so, parse the whole column
/// once and return an R vector of that type. Otherwise, return an R character
/// vector created directly from the input `value` (no cloning).
pub(super) fn robj_from_parsing_str<T>(value: &[Option<T>]) -> Robj
where
    T: AsRef<str>,
{
    // the total sampling numbers // data table uses 10_000
    const SAMPLE_SIZE: usize = 5_000;

    // how many times should we sampling
    // Sample 100 equally spaced points: beginning, middle, and end
    const SAMPLE_TIMES: usize = 100;
    debug_assert!(SAMPLE_SIZE >= SAMPLE_TIMES);

    // transfrom the iput into string slice
    let input_str = value
        .iter()
        .map(|opt| opt.as_ref().map(|value| value.as_ref()))
        .collect::<Vec<Option<&str>>>();

    // Fast sample pass (no allocations): inspect up to SAMPLE_SIZE cells.
    let mut can_int = true;
    let mut can_f64 = true;
    let mut can_bool = true;

    // the numbers for each sampling
    let sampling_size = SAMPLE_SIZE / SAMPLE_TIMES; // 50

    // the intervals between two sampling
    // Divide into 100 parts for beginning, middle, and end
    let sampling_interval = (input_str.len() / SAMPLE_TIMES)
        .checked_sub(sampling_size)
        .unwrap_or(0);
    let mut sampling_numbers = 0;
    let mut index = 0;
    while index < input_str.len() {
        // SAFETY: index are within bounds of value
        if let Some(s) = unsafe { input_str.get_unchecked(index) } {
            if can_f64 && s.parse::<f64>().is_err() {
                can_int = false; // int can be parsed by f64
                can_f64 = false;
            }
            if can_int && s.parse::<i32>().is_err() {
                can_int = false;
            }
            if can_bool && !(s.eq_ignore_ascii_case("true") || s.eq_ignore_ascii_case("false")) {
                can_bool = false;
            }
            if !can_int && !can_f64 && !can_bool {
                break;
            }
        }
        index += 1;
        sampling_numbers += 1;
        if sampling_interval > 0 && sampling_numbers >= sampling_size {
            index += sampling_interval;
            sampling_numbers = 0;
        }
    }

    // Parse whole column once according to inferred type (prefer integer over float).
    if can_int {
        if let Ok(robj) = input_str
            .iter()
            .map(|opt| opt.and_then(|s| Some(s.parse::<i32>())).transpose())
            .collect::<std::result::Result<Robj, _>>()
        {
            return robj;
        }
    }

    if can_f64 {
        if let Ok(robj) = input_str
            .iter()
            .map(|opt| opt.and_then(|s| Some(s.parse::<f64>())).transpose())
            .collect::<std::result::Result<Robj, _>>()
        {
            return robj;
        }
    }

    if can_bool {
        if let Ok(robj) = input_str
            .iter()
            .map(|opt| {
                opt.and_then(|s| {
                    if s.eq_ignore_ascii_case("true") {
                        Some(Ok(true))
                    } else if s.eq_ignore_ascii_case("false") {
                        Some(Ok(false))
                    } else {
                        Some(Err(())) // Ignore the error
                    }
                })
                .transpose()
            })
            .collect::<std::result::Result<Robj, _>>()
        {
            return robj;
        }
    }

    // Fallback: keep as character vector, reuse original `value` (no extra cloning).
    Robj::from(input_str)
}
