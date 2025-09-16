use std::fmt;
use std::result::Result;
use std::str::FromStr;

use super::error::GEOParseError;

#[derive(Debug, Clone)]
pub(crate) enum GEOType {
    Datasets,
    Platforms,
    Samples,
    Series,
}

impl GEOType {
    pub(crate) fn prefix(&self) -> &'static str {
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
        write!(f, "{}", match self {
            GEOType::Datasets => "Datasets",
            GEOType::Series => "Series",
            GEOType::Platforms => "Platforms",
            GEOType::Samples => "Samples",
        })
    }
}

impl FromStr for GEOType {
    type Err = GEOParseError;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        GEOIdentifier::from_str(s).map(|o| o.gtype)
    }
}

impl TryFrom<&str> for GEOType {
    type Error = GEOParseError;
    fn try_from(value: &str) -> std::result::Result<Self, Self::Error> {
        Self::from_str(value.as_ref())
    }
}

// only used internal
pub(super) struct GEOIdentifier {
    pub(super) accession: String,
    pub(super) gtype: GEOType,
}

impl FromStr for GEOIdentifier {
    type Err = GEOParseError;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let accession = s.to_uppercase();
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
        Ok(Self { accession, gtype })
    }
}

impl TryFrom<&str> for GEOIdentifier {
    type Error = GEOParseError;
    fn try_from(value: &str) -> std::result::Result<Self, Self::Error> {
        Self::from_str(value.as_ref())
    }
}
