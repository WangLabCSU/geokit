use std::fmt;
use std::result::Result;
use std::str::FromStr;

use super::error::GEOParseError;

#[derive(Debug, Clone)]
pub enum GEOType {
    Datasets,
    Platforms,
    Samples,
    Series,
}

impl GEOType {
    pub fn as_str(&self) -> &'static str {
        match self {
            GEOType::Datasets => "Datasets",
            GEOType::Series => "Series",
            GEOType::Platforms => "Platforms",
            GEOType::Samples => "Samples",
        }
    }
    pub fn abbre(&self) -> &'static str {
        match self {
            GEOType::Datasets => "GDS",
            GEOType::Series => "GSE",
            GEOType::Platforms => "GPL",
            GEOType::Samples => "GSM",
        }
    }
}

impl fmt::Display for GEOType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

#[derive(Debug, Clone)]
pub struct GEOEntity {
    accession: String,
    gtype: GEOType,
}

impl GEOEntity {
    pub fn accession(&self) -> &str {
        self.accession.as_str()
    }

    pub fn gtype(&self) -> &GEOType {
        &self.gtype
    }
}

impl fmt::Display for GEOEntity {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self.accession)
    }
}

impl FromStr for GEOEntity {
    type Err = GEOParseError;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let accession = s.trim().to_ascii_uppercase();

        // Determine GEO type from the 3-letter prefix.
        let gtype = if accession.starts_with("GDS") {
            GEOType::Datasets
        } else if accession.starts_with("GPL") {
            GEOType::Platforms
        } else if accession.starts_with("GSM") {
            GEOType::Samples
        } else if accession.starts_with("GSE") {
            GEOType::Series
        } else {
            return Err(GEOParseError::InvalidAccession);
        };

        // SAFETY: `accession` must be >= 3 characters if it passed the prefix check above.
        if accession.len() == 3
            || !unsafe { accession.get_unchecked(3..) }
                .chars()
                .all(|c| c.is_ascii_digit())
        {
            return Err(GEOParseError::InvalidAccession);
        }

        Ok(Self { accession, gtype })
    }
}

impl TryFrom<&str> for GEOEntity {
    type Error = GEOParseError;
    fn try_from(value: &str) -> Result<Self, Self::Error> {
        Self::from_str(value)
    }
}
