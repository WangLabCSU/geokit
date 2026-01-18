use std::fmt;
use std::result::Result;
use std::sync::OnceLock;

use regex::Regex;

use crate::geo::entity::{GEOEntity, GEOType};
use crate::geo::error::GEOParseError;

pub struct GEOFTPResolver {
    entity: GEOEntity,
    format: GEOFTPFormat,
    over_https: bool,
}

impl GEOFTPResolver {
    #[allow(dead_code)]
    #[inline]
    pub fn new(entity: GEOEntity) -> Self {
        Self::builder().entity(entity).build().unwrap()
    }

    #[allow(dead_code)]
    #[inline]
    pub fn builder() -> GEOFTPResolverBuilder {
        GEOFTPResolverBuilder::new()
    }

    /// Returns the GEO accession string (e.g., "GSE12345" or "GSM67890")
    /// associated with this resolver.
    #[inline]
    pub fn accession(&self) -> &str {
        self.entity.accession()
    }

    /// Returns the [`GEOType`] (such as `Datasets`, `Series`, or `Samples`)
    /// associated with this resolver.
    #[inline]
    pub fn gtype(&self) -> &GEOType {
        self.entity.gtype()
    }

    #[inline]
    pub fn format(&self) -> &GEOFTPFormat {
        &self.format
    }

    pub fn landing_page(&self) -> String {
        static RE: OnceLock<Regex> = OnceLock::new();
        let regex = RE.get_or_init(|| {
            Regex::new(r"\d{1,3}$")
                .map_err(|e| format!("Failed to create the regex: {}", e))
                .unwrap()
        });
        format!(
            "{}/{}/{}/{}/{}",
            // Construct the FTP/HTTPS download URL for the current GEO identifier and file type.
            if self.over_https {
                "https://ftp.ncbi.nlm.nih.gov/geo"
            } else {
                "ftp://ftp.ncbi.nlm.nih.gov/geo"
            },
            // GEO FTP server uses lowercase
            self.gtype().as_str().to_ascii_lowercase(),
            // Replace the last 1–3 digits in the ID with "nnn" for the directory path.
            regex.replace(self.accession(), "nnn"),
            self.accession(),
            // `SOFT` and `SOFTFull` share the same directory ("soft").
            match &self.format {
                GEOFTPFormat::SOFT | GEOFTPFormat::SOFTFull => "soft",
                GEOFTPFormat::Miniml => "miniml",
                GEOFTPFormat::Matrix => "matrix",
                GEOFTPFormat::Annot => "annot",
                GEOFTPFormat::Suppl => "suppl",
            }
        )
    }

    #[inline]
    pub fn url(&self) -> String {
        self.fname().map_or_else(
            || self.landing_page(),
            |fname| format!("{}/{}", self.landing_page(), fname),
        )
    }

    pub fn fname(&self) -> Option<String> {
        let fname = match (self.gtype(), self.format()) {
            // build the filename
            (GEOType::Datasets, GEOFTPFormat::SOFT) => {
                format!("{}{}", self.accession(), ".soft.gz")
            }
            (GEOType::Datasets, GEOFTPFormat::SOFTFull) => {
                format!("{}{}", self.accession(), "_full.soft.gz")
            }
            (GEOType::Series, GEOFTPFormat::SOFT) => {
                format!("{}{}", self.accession(), "_family.soft.gz")
            }
            (GEOType::Series, GEOFTPFormat::Miniml) => {
                format!("{}{}", self.accession(), "_family.xml.tgz")
            }
            (GEOType::Platforms, GEOFTPFormat::Annot) => {
                format!("{}{}", self.accession(), ".annot.gz")
            }
            (GEOType::Platforms, GEOFTPFormat::Miniml) => {
                format!("{}{}", self.accession(), "_family.xml.tgz")
            }
            (GEOType::Platforms, GEOFTPFormat::SOFT) => {
                format!("{}{}", self.accession(), "_family.soft.gz")
            }

            // Certain types (e.g., Series Matrix, Supplementary files) are directories, not single files.
            (_, GEOFTPFormat::Matrix | GEOFTPFormat::Suppl) => {
                return None;
            }
            _ => unreachable!(),
        };
        Some(fname)
    }
}

#[derive(Default)]
pub struct GEOFTPResolverBuilder {
    entity: Option<GEOEntity>,
    format: Option<GEOFTPFormat>,
    over_https: Option<bool>,
}

// Rust insists that all fields in a struct must be filled in when a new
// instance of that struct is created. This keeps the code safe by ensuring that
// there are never any uninitialized values but does lead to more verbose
// boilerplate code than is ideal.
impl GEOFTPResolverBuilder {
    #[inline]
    pub fn new() -> Self {
        Self::default()
    }

    #[inline]
    pub fn entity(&mut self, entity: GEOEntity) -> &mut Self {
        self.entity = Some(entity);
        self
    }

    // @section GEO FTP file format reference table:
    // |            type            | GDS | GSE | GPL | GSM |
    // | :------------------------: | :-: | :-: | :-: | :-: |
    // |        SOFT (soft)         |  o  |  o  |  o  |  x  |
    // |    SOFTFULL (soft_full)    |  o  |  x  |  x  |  x  |
    // |      MINiML (miniml)       |  x  |  o  |  o  |  x  |
    // |      Matrix (matrix)       |  x  |  o  |  x  |  x  |
    // |     Annotation (annot)     |  x  |  x  |  o  |  x  |
    // | Supplementaryfiles (suppl) |  x  |  o  |  o  |  o  |
    #[inline]
    pub fn format(&mut self, format: GEOFTPFormat) -> &mut Self {
        self.format = Some(format);
        self
    }

    #[inline]
    pub fn over_https(&mut self, over_https: bool) -> &mut Self {
        self.over_https = Some(over_https);
        self
    }

    pub fn build(&mut self) -> Result<GEOFTPResolver, GEOParseError> {
        // https://docs.rs/derive_builder/latest/derive_builder/
        // Luckily Rust is clever enough to optimize these clone-calls away in
        // release builds for your every-day use cases. Thats quite a safe bet -
        // we checked this for you. ;-) Switching to consuming signatures
        // (=self) is unlikely to give you any performance gain, but very likely
        // to restrict your API for non-chained use cases.
        let entity = self
            .entity
            .as_ref()
            .map_or_else(|| Err(GEOParseError::RequireEntity), |v| Ok(v.clone()))?;

        // Default to SOFT files for all GEO types except GSM, which only provides SUPPL files.
        let format = if let Some(ref f) = self.format {
            f.clone()
        } else {
            match entity.gtype() {
                GEOType::Samples => GEOFTPFormat::Suppl,
                _ => GEOFTPFormat::SOFT,
            }
        };

        // check format is valid
        match (entity.gtype(), &format) {
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
            | (GEOType::Samples, GEOFTPFormat::Suppl) => {}
            _ => {
                return Err(GEOParseError::UnavailableFTPFormat {
                    gtype: entity.gtype().clone(),
                    format,
                });
            }
        }
        // Note: Always connect to the GEO FTP site via HTTPS by default, since direct FTP often fails.
        let over_https = self.over_https.unwrap_or(true);
        Ok(GEOFTPResolver {
            entity,
            format,
            over_https,
        })
    }
}

#[derive(Debug, Clone)]
#[allow(clippy::upper_case_acronyms)]
pub enum GEOFTPFormat {
    SOFT,
    SOFTFull,
    Miniml,
    Matrix,
    Annot,
    Suppl,
}

impl GEOFTPFormat {
    #[inline]
    pub fn as_str(&self) -> &'static str {
        match self {
            GEOFTPFormat::SOFT => "soft",
            GEOFTPFormat::SOFTFull => "soft_full",
            GEOFTPFormat::Miniml => "miniml",
            GEOFTPFormat::Matrix => "matrix",
            GEOFTPFormat::Annot => "annot",
            GEOFTPFormat::Suppl => "suppl",
        }
    }
}

impl fmt::Display for GEOFTPFormat {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self.as_str())
    }
}
