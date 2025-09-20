use std::fmt;
use std::result::Result;
use std::str::FromStr;

use super::error::GEOParseError;
use super::identifier::{GEOIdentifier, GEOType};
use super::GEOEntry;

// @param amount A character string in one of "brief", "quick", "data" or
// "full". Allows you to control the amount of data that you will see displayed.
// "Brief" displays the accession's attributes only. "Quick" displays the
// accession's attributes and the first twenty rows of its data table. "Full"
// displays the accessions's attributes and the full data table. "Data" omits
// the accession's attributes, showing only the links to other accessions as
// well as the full data table
#[derive(Default, Debug)]
pub(super) enum GEOAmount {
    Brief,
    Quick,
    #[default]
    Data,
    Full,
}

impl fmt::Display for GEOAmount {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", match self {
            GEOAmount::Brief => "brief",
            GEOAmount::Quick => "quick",
            GEOAmount::Data => "data",
            GEOAmount::Full => "full",
        })
    }
}

impl FromStr for GEOAmount {
    type Err = GEOParseError;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let amount = match s {
            "brief" => GEOAmount::Brief,
            "quick" => GEOAmount::Quick,
            "data" => GEOAmount::Data,
            "full" => GEOAmount::Full,
            _ => {
                return Err(GEOParseError::InvalidAmount);
            }
        };
        Ok(amount)
    }
}

impl TryFrom<&str> for GEOAmount {
    type Error = GEOParseError;
    fn try_from(value: &str) -> Result<Self, Self::Error> {
        Self::from_str(value)
    }
}

// @param scope A character string in one of "self", "gsm", "gpl", "gse" or
// "all". allows you to display the GEO accession(s) which you wish to target
// for display. You may display the GEO accession which is typed into the text
// box itself ("Self"), or any ("Platform", "Samples", or "Series") or all
// ("Family") of the accessions related to the accession number typed into the
// text box.
#[derive(Default)]
pub(super) enum GEOScope {
    #[default]
    Itself,
    GSM,
    GPL,
    GSE,
    All,
}

impl fmt::Display for GEOScope {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", match self {
            GEOScope::Itself => "self",
            GEOScope::GSM => "gsm",
            GEOScope::GPL => "gpl",
            GEOScope::GSE => "gse",
            GEOScope::All => "all",
        })
    }
}

impl FromStr for GEOScope {
    type Err = GEOParseError;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let scope = match s {
            "self" => GEOScope::Itself,
            "gsm" => GEOScope::GSM,
            "gpl" => GEOScope::GPL,
            "gse" => GEOScope::GSE,
            "all" => GEOScope::All,
            _ => {
                return Err(GEOParseError::InvalidScope);
            }
        };
        Ok(scope)
    }
}

impl TryFrom<&str> for GEOScope {
    type Error = GEOParseError;
    fn try_from(value: &str) -> Result<Self, Self::Error> {
        Self::from_str(value)
    }
}

// Accession Display Bar
// https://www.ncbi.nlm.nih.gov/geo/info/download.html
// @param format A character string in one of "text", "xml" or "html".
// Allows you to display the GEO accession in human readable, linked "HTML"
// form, or in machine readable, "text" format, which is the same with "soft"
// format. SOFT stands for "simple omnibus format in text".
pub(super) enum GEOADBFormat {
    Text,
    Xml,
    Html,
}

impl GEOADBFormat {
    fn ext(&self) -> &'static str {
        match self {
            GEOADBFormat::Text => "soft",
            GEOADBFormat::Xml => "xml",
            GEOADBFormat::Html => "html",
        }
    }
}

impl fmt::Display for GEOADBFormat {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", match self {
            GEOADBFormat::Text => "text",
            GEOADBFormat::Xml => "xml",
            GEOADBFormat::Html => "html",
        })
    }
}

impl FromStr for GEOADBFormat {
    type Err = GEOParseError;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let format = match s {
            "text" => GEOADBFormat::Text,
            "xml" => GEOADBFormat::Xml,
            "html" => GEOADBFormat::Html,
            _ => {
                return Err(GEOParseError::InvalidAccFormat);
            }
        };
        Ok(format)
    }
}

impl TryFrom<&str> for GEOADBFormat {
    type Error = GEOParseError;
    fn try_from(value: &str) -> Result<Self, Self::Error> {
        Self::from_str(value)
    }
}

pub(super) struct GEOADBResolver {
    id: GEOIdentifier,
    scope: Option<GEOScope>,
    amount: Option<GEOAmount>,
    format: GEOADBFormat,
}

impl GEOADBResolver {
    pub(super) fn new(id: GEOIdentifier) -> Self {
        match id.gtype {
            GEOType::Datasets => Self {
                id,
                scope: None,
                amount: None,
                format: GEOADBFormat::Html,
            },
            _ => Self {
                id,
                scope: Some(GEOScope::default()),
                amount: Some(GEOAmount::default()),
                format: GEOADBFormat::Html,
            },
        }
    }

    pub(super) fn set_format(&mut self, format: GEOADBFormat) -> Result<(), GEOParseError> {
        if let (GEOType::Datasets, GEOADBFormat::Text | GEOADBFormat::Xml) =
            (&self.id.gtype, &format)
        {
            return Err(GEOParseError::UnavailableFormat {
                gtype: self.id.gtype.clone(),
                ftype: format.to_string(),
            });
        }
        self.format = format;
        Ok(())
    }

    pub(super) fn set_scope(&mut self, scope: Option<GEOScope>) -> Result<(), GEOParseError> {
        match self.id.gtype {
            GEOType::Datasets => {
                if scope.is_some() {
                    return Err(GEOParseError::AccScopeOmitted {
                        gtype: self.id.gtype.clone(),
                    });
                }
            }
            _ => {
                if scope.is_none() {
                    return Err(GEOParseError::AccScopeRequired {
                        gtype: self.id.gtype.clone(),
                    });
                }
            }
        }
        self.scope = scope;
        Ok(())
    }

    pub(super) fn set_amount(&mut self, amount: Option<GEOAmount>) -> Result<(), GEOParseError> {
        match self.id.gtype {
            GEOType::Datasets => {
                if amount.is_some() {
                    return Err(GEOParseError::AccAmountOmitted {
                        gtype: self.id.gtype.clone(),
                    });
                }
            }
            _ => {
                if amount.is_none() {
                    return Err(GEOParseError::AccAmountRequired {
                        gtype: self.id.gtype.clone(),
                    });
                }
            }
        }
        self.amount = amount;
        Ok(())
    }

    pub(super) fn accession(&self) -> &str {
        self.id.accession.as_str()
    }

    pub(super) fn gtype(&self) -> &GEOType {
        &self.id.gtype
    }

    pub(super) fn landing_page(&self) -> String {
        match (&self.scope, &self.amount, &self.format) {
            (Some(s), Some(a), _) => acc_url(self.id.accession.as_str(), s, a, &GEOADBFormat::Html),
            (None, None, GEOADBFormat::Html) => gds_url(self.id.accession.as_str()),
            _ => unreachable!(),
        }
    }

    pub(super) fn url(&self) -> String {
        match (&self.scope, &self.amount, &self.format) {
            (Some(s), Some(a), f) => acc_url(self.id.accession.as_str(), s, a, f),
            (None, None, GEOADBFormat::Html) => gds_url(self.id.accession.as_str()),
            _ => unreachable!(),
        }
    }

    pub(super) fn entry(&self) -> Option<GEOEntry> {
        match (&self.scope, &self.amount, &self.format) {
            (Some(s), Some(a), f) => Some(GEOEntry::File {
                url: acc_url(self.id.accession.as_str(), s, a, f),
                fname: format!("{}_{}.{}", self.id.accession, a, f.ext()),
            }),
            (None, None, GEOADBFormat::Html) => None,
            _ => unreachable!(),
        }
    }
}

fn acc_url(accession: &str, scope: &GEOScope, amount: &GEOAmount, format: &GEOADBFormat) -> String {
    format!(
        "https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc={}&targ={}&view={}&form={}",
        accession, scope, amount, format
    )
}

fn gds_url(accession: &str) -> String {
    format!(
        "https://www.ncbi.nlm.nih.gov/sites/GDSbrowser?acc={}",
        accession
    )
}
