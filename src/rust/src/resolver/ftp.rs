use std::fmt;
use std::result::Result;
use std::str::FromStr;
use std::sync::OnceLock;

use anyhow::Context;
use regex::Regex;

use super::error::GEOParseError;
use super::identifier::{GEOIdentifier, GEOType};
use super::GEOEntry;

#[derive(Debug, Clone)]
pub(super) enum GEOFTPFormat {
    SOFT,
    SOFTFull,
    Miniml,
    Matrix,
    Annot,
    Suppl,
}

impl fmt::Display for GEOFTPFormat {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", match self {
            GEOFTPFormat::SOFT => "soft",
            GEOFTPFormat::SOFTFull => "soft_full",
            GEOFTPFormat::Miniml => "miniml",
            GEOFTPFormat::Matrix => "matrix",
            GEOFTPFormat::Annot => "annot",
            GEOFTPFormat::Suppl => "suppl",
        })
    }
}

impl FromStr for GEOFTPFormat {
    type Err = GEOParseError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "soft" => Ok(GEOFTPFormat::SOFT),
            "soft_full" => Ok(GEOFTPFormat::SOFTFull),
            "miniml" => Ok(GEOFTPFormat::Miniml),
            "matrix" => Ok(GEOFTPFormat::Matrix),
            "annot" => Ok(GEOFTPFormat::Annot),
            "suppl" => Ok(GEOFTPFormat::Suppl),
            _ => Err(GEOParseError::InvalidFTPFormat),
        }
    }
}

impl TryFrom<&str> for GEOFTPFormat {
    type Error = GEOParseError;
    fn try_from(value: &str) -> std::result::Result<Self, Self::Error> {
        Self::from_str(value)
    }
}

pub(super) struct GEOFTPResolver {
    pub(super) id: GEOIdentifier,
    file: GEOFTPFormat,
    over_https: bool,
}

impl GEOFTPResolver {
    pub(super) fn new(id: GEOIdentifier) -> Self {
        // Default to SOFT files for all GEO types except GSM, which only provides SUPPL files.
        let file = match &id.gtype {
            GEOType::Samples => GEOFTPFormat::Suppl,
            _ => GEOFTPFormat::SOFT,
        };
        // Note: Always connect to the GEO FTP site via HTTPS by default, since direct FTP often fails.
        Self {
            id,
            file,
            over_https: true,
        }
    }

    // @section GEO file type reference table:
    // |            type            | GDS | GSE | GPL | GSM |
    // | :------------------------: | :-: | :-: | :-: | :-: |
    // |        SOFT (soft)         |  o  |  o  |  o  |  x  |
    // |    SOFTFULL (soft_full)    |  o  |  x  |  x  |  x  |
    // |      MINiML (miniml)       |  x  |  o  |  o  |  x  |
    // |      Matrix (matrix)       |  x  |  o  |  x  |  x  |
    // |     Annotation (annot)     |  x  |  x  |  o  |  x  |
    // | Supplementaryfiles (suppl) |  x  |  o  |  o  |  o  |
    pub(super) fn set_file(
        &mut self,
        file: GEOFTPFormat,
    ) -> std::result::Result<(), GEOParseError> {
        match (&self.id.gtype, &file) {
            (GEOType::Datasets, GEOFTPFormat::SOFT | GEOFTPFormat::SOFTFull)
            | (
                GEOType::Series,
                GEOFTPFormat::SOFT
                | GEOFTPFormat::Miniml
                | GEOFTPFormat::Matrix
                | GEOFTPFormat::Suppl,
            )
            | (
                GEOType::Platforms,
                GEOFTPFormat::SOFT
                | GEOFTPFormat::Miniml
                | GEOFTPFormat::Annot
                | GEOFTPFormat::Suppl,
            )
            | (GEOType::Samples, GEOFTPFormat::Suppl) => {
                self.file = file;
            }
            _ => {
                return Err(GEOParseError::UnavailableFTPFormat {
                    gtype: self.id.gtype.clone(),
                    // `GEOFTPFormat` is not public field
                    ftype: file.to_string(),
                });
            }
        }
        Ok(())
    }

    pub(super) fn over_https(&mut self, over_https: bool) {
        self.over_https = over_https
    }

    pub(super) fn url(&self) -> String {
        static RE: OnceLock<Regex> = OnceLock::new();
        let regex = RE.get_or_init(|| {
            Regex::new(r"\d{1,3}$")
                .with_context(|| "Failed to create regex")
                .unwrap()
        });
        let id = self.id.accession.to_ascii_lowercase();
        format!(
            "{}/{}/{}/{}/{}/{}",
            // Construct the FTP/HTTPS download URL for the current GEO identifier and file type.
            if self.over_https {
                "https://ftp.ncbi.nlm.nih.gov/geo"
            } else {
                "ftp://ftp.ncbi.nlm.nih.gov/geo"
            },
            self.id.gtype.to_string().to_ascii_lowercase(),
            // Replace the last 1–3 digits in the ID with "nnn" for the directory path.
            regex.replace(&id, "nnn"),
            id,
            // `Soft` and `SoftFull` share the same directory ("soft").
            match &self.file {
                GEOFTPFormat::SOFT | GEOFTPFormat::SOFTFull => "soft",
                GEOFTPFormat::Miniml => "miniml",
                GEOFTPFormat::Matrix => "matrix",
                GEOFTPFormat::Annot => "annot",
                GEOFTPFormat::Suppl => "suppl",
            },
            match self.entry() {
                GEOEntry::Dir => "",
                GEOEntry::File(ref fname) => fname,
            }
        )
    }

    pub(super) fn entry(&self) -> GEOEntry {
        let fname = match (&self.id.gtype, &self.file) {
            (GEOType::Datasets, GEOFTPFormat::SOFT) => {
                format!("{}{}", self.id.accession, ".soft.gz")
            }
            (GEOType::Datasets, GEOFTPFormat::SOFTFull) => {
                format!("{}{}", self.id.accession, "_full.soft.gz")
            }
            (GEOType::Series, GEOFTPFormat::SOFT) => {
                format!("{}{}", self.id.accession, "_family.soft.gz")
            }
            (GEOType::Series, GEOFTPFormat::Miniml) => {
                format!("{}{}", self.id.accession, "_family.xml.tgz")
            }
            (GEOType::Platforms, GEOFTPFormat::Annot) => {
                format!("{}{}", self.id.accession, ".annot.gz")
            }
            (GEOType::Platforms, GEOFTPFormat::Miniml) => {
                format!("{}{}", self.id.accession, "_family.xml.tgz")
            }
            (GEOType::Platforms, GEOFTPFormat::SOFT) => {
                format!("{}{}", self.id.accession, "_family.soft.gz")
            }

            // Certain types (e.g., Series Matrix, Supplementary files) are directories, not single files.
            // build the filename
            (_, GEOFTPFormat::Matrix | GEOFTPFormat::Suppl) => {
                return GEOEntry::Dir;
            }
            _ => unreachable!(),
        };
        GEOEntry::File(fname)
    }
}
