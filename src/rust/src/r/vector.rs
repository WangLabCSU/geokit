use std::borrow::Cow;

use extendr_api::Robj;
use rand::{rng, seq::IteratorRandom};

/// Convert a column represented as Vec<Option<String>> into the most specific R vector.
///
/// Sampling-based inference: test up to SAMPLE_SIZE cells to decide whether the
/// column can be parsed as i32, f64, or bool. If so, parse the whole column
/// once and return an R vector of that type. Otherwise, return an R character
/// vector created directly from the input `value` (no cloning).
pub enum Vector {
    I32(Vec<Option<i32>>),
    F64(Vec<Option<f64>>),
    Bool(Vec<Option<bool>>),
    String(Vec<Option<String>>),
}

impl Vector {
    pub fn parse_string<T>(value: Vec<Option<T>>) -> Self
    where
        T: AsRef<str>,
        Vec<Option<T>>: Into<Vector>,
    {
        const SAMPLE_SIZE: usize = 5_000; // data table uses 10_000
        let input_str = value
            .iter()
            .map(|opt| opt.as_ref().map(|value| value.as_ref()))
            .collect::<Vec<Option<&str>>>();

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
            if let Some(s) = unsafe { input_str.get_unchecked(index) } {
                if can_f64 && s.parse::<f64>().is_err() {
                    can_int = false; // int can be parsed by f64
                    can_f64 = false;
                }
                if can_int && s.parse::<i32>().is_err() {
                    can_int = false;
                }
                if can_bool && !(s.eq_ignore_ascii_case("true") || s.eq_ignore_ascii_case("false"))
                {
                    can_bool = false;
                }
                if !can_int && !can_f64 && !can_bool {
                    break;
                }
            }
        }

        // Parse whole column once according to inferred type (prefer integer over float).
        if can_int {
            if let Ok(parsed) = input_str
                .iter()
                .map(|opt| opt.and_then(|s| Some(s.parse::<i32>())).transpose())
                .collect::<std::result::Result<Vec<Option<i32>>, _>>()
            {
                return Vector::I32(parsed);
            }
        }

        if can_f64 {
            if let Ok(parsed) = input_str
                .iter()
                .map(|opt| opt.and_then(|s| Some(s.parse::<f64>())).transpose())
                .collect::<std::result::Result<Vec<Option<f64>>, _>>()
            {
                return Vector::F64(parsed);
            }
        }

        if can_bool {
            if let Ok(parsed) = input_str
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
                .collect::<std::result::Result<Vec<Option<bool>>, _>>()
            {
                return Vector::Bool(parsed);
            }
        }

        // Fallback: keep as character vector, reuse original `value` (no extra cloning).
        value.into()
    }
}

impl From<Vec<Option<i32>>> for Vector {
    fn from(value: Vec<Option<i32>>) -> Self {
        Self::I32(value)
    }
}

impl From<Vec<i32>> for Vector {
    fn from(value: Vec<i32>) -> Self {
        Self::I32(value.into_iter().map(|v| Some(v)).collect())
    }
}

impl From<Vec<Option<f64>>> for Vector {
    fn from(value: Vec<Option<f64>>) -> Self {
        Self::F64(value)
    }
}

impl From<Vec<f64>> for Vector {
    fn from(value: Vec<f64>) -> Self {
        Self::F64(value.into_iter().map(|v| Some(v)).collect())
    }
}

impl From<Vec<Option<String>>> for Vector {
    fn from(value: Vec<Option<String>>) -> Self {
        Self::String(value)
    }
}

impl From<Vec<String>> for Vector {
    fn from(value: Vec<String>) -> Self {
        Self::String(value.into_iter().map(|v| Some(v)).collect())
    }
}

impl<'a> From<Vec<Option<&'a str>>> for Vector {
    fn from(value: Vec<Option<&'a str>>) -> Self {
        Self::String(
            value
                .into_iter()
                .map(|opt| opt.map(|s| s.to_owned()))
                .collect(),
        )
    }
}

impl<'a> From<Vec<&'a str>> for Vector {
    fn from(value: Vec<&'a str>) -> Self {
        Self::String(value.into_iter().map(|v| Some(v.to_owned())).collect())
    }
}

impl<'a> From<Vec<Option<Cow<'a, str>>>> for Vector {
    fn from(value: Vec<Option<Cow<'a, str>>>) -> Self {
        Self::String(
            value
                .into_iter()
                .map(|opt| opt.map(|s| s.into_owned()))
                .collect(),
        )
    }
}

impl<'a> From<Vec<Cow<'a, str>>> for Vector {
    fn from(value: Vec<Cow<'a, str>>) -> Self {
        Self::String(value.into_iter().map(|v| Some(v.into_owned())).collect())
    }
}

impl From<Vec<Option<bool>>> for Vector {
    fn from(value: Vec<Option<bool>>) -> Self {
        Self::Bool(value)
    }
}

impl From<Vec<bool>> for Vector {
    fn from(value: Vec<bool>) -> Self {
        Self::Bool(value.into_iter().map(|v| Some(v)).collect())
    }
}

impl From<Vector> for Robj {
    fn from(value: Vector) -> Self {
        match value {
            Vector::I32(v) => Robj::from(v),
            Vector::F64(v) => Robj::from(v),
            Vector::Bool(v) => Robj::from(v),
            Vector::String(v) => Robj::from(v),
        }
    }
}
