use std::fmt;
use std::result::Result;

use crate::geo::entity::{GEOEntity, GEOType};
use crate::geo::error::GEOParseError;

pub struct GEOADBResolver {
    entity: GEOEntity,
    format: GEOADBFormat,
    scope: Option<GEOScope>,
    amount: Option<GEOAmount>,
}

impl GEOADBResolver {
    #[inline]
    pub fn new(entity: GEOEntity) -> Self {
        Self::builder().entity(entity).build().unwrap()
    }

    #[inline]
    pub fn builder() -> GEOADBResolverBuilder {
        GEOADBResolverBuilder::new()
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
    pub fn format(&self) -> &GEOADBFormat {
        &self.format
    }

    #[inline]
    pub fn scope(&self) -> Option<&GEOScope> {
        self.scope.as_ref()
    }

    #[inline]
    pub fn amount(&self) -> Option<&GEOAmount> {
        self.amount.as_ref()
    }

    #[inline]
    pub fn landing_page(&self) -> String {
        self.url_with_format(&GEOADBFormat::Html)
    }

    #[inline]
    pub fn url(&self) -> String {
        self.url_with_format(&self.format)
    }

    #[inline]
    fn url_with_format(&self, format: &GEOADBFormat) -> String {
        match self.gtype() {
            GEOType::Datasets => format!(
                "https://www.ncbi.nlm.nih.gov/sites/GDSbrowser?acc={}",
                self.accession()
            ),
            // SAFETY: At this point, `self.gtype()` is guaranteed to be a value other than `Datasets`.
            // The usage of `unsafe` here is safe because we have ensured that the scope and amount are not `None`.
            _ => unsafe {
                format!(
                    "https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc={}&targ={}&view={}&form={}",
                    self.accession(),
                    self.scope.as_ref().unwrap_unchecked(),
                    self.amount.as_ref().unwrap_unchecked(),
                    format
                )
            },
        }
    }

    #[inline]
    pub fn fname(&self) -> String {
        let mut fname = String::new();
        fname.push_str(self.accession());
        if let Some(amount) = self.amount() {
            fname.push('_');
            fname.push_str(amount.as_str());
        }
        if let Some(scope) = self.scope() {
            fname.push('_');
            fname.push_str(scope.as_str());
        }
        match self.format() {
            GEOADBFormat::Html => fname.push_str(".html"),
            GEOADBFormat::Text => fname.push_str(".txt"),
            GEOADBFormat::Xml => fname.push_str(".xml"),
        }
        fname
    }
}

pub struct GEOADBResolverBuilder {
    entity: Option<GEOEntity>,
    format: Option<GEOADBFormat>,
    scope: Option<GEOScope>,
    amount: Option<GEOAmount>,
}

impl Default for GEOADBResolverBuilder {
    fn default() -> Self {
        Self {
            entity: None,
            format: None,
            scope: None,
            amount: None,
        }
    }
}

// Rust insists that all fields in a struct must be filled in when a new
// instance of that struct is created. This keeps the code safe by ensuring that
// there are never any uninitialized values but does lead to more verbose
// boilerplate code than is ideal.
impl GEOADBResolverBuilder {
    #[inline]
    pub fn new() -> Self {
        Self::default()
    }

    #[inline]
    pub fn entity(&mut self, entity: GEOEntity) -> &mut Self {
        self.entity = Some(entity);
        self
    }

    // @section GEO Accession Display Bar file format reference table:
    // |            type            | GDS | GSE | GPL | GSM |
    // | :------------------------: | :-: | :-: | :-: | :-: |
    // |        Text (soft)         |  x  |  o  |  o  |  o  |
    // |         Xml (xml)          |  x  |  o  |  o  |  o  |
    // |        Html (html)         |  o  |  o  |  o  |  o  |
    #[inline]
    pub fn format(&mut self, format: GEOADBFormat) -> &mut Self {
        self.format = Some(format);
        self
    }

    #[inline]
    pub fn scope(&mut self, scope: GEOScope) -> &mut Self {
        self.scope = Some(scope);
        self
    }

    #[inline]
    pub fn amount(&mut self, amount: GEOAmount) -> &mut Self {
        self.amount = Some(amount);
        self
    }

    #[inline]
    pub fn build(&mut self) -> Result<GEOADBResolver, GEOParseError> {
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
        let format = self
            .format
            .as_ref()
            .map(|f| f.clone())
            .unwrap_or_else(|| GEOADBFormat::default());

        // check format is valid
        if let (GEOType::Datasets, GEOADBFormat::Text | GEOADBFormat::Xml) =
            (entity.gtype(), &format)
        {
            return Err(GEOParseError::UnavailableADBFormat {
                gtype: entity.gtype().clone(),
                format,
            });
        }

        // check amount is valid
        let amount = match (entity.gtype(), &self.amount) {
            (gtype @ GEOType::Datasets, Some(_)) => {
                return Err(GEOParseError::DisallowedAmount {
                    gtype: gtype.clone(),
                });
            }
            (GEOType::Datasets, None) => None,
            (_, None) => Some(GEOAmount::default()),
            _ => self.amount.clone(),
        };

        // check scope is valid
        let scope = match (entity.gtype(), &self.scope) {
            (gtype @ GEOType::Datasets, Some(_)) => {
                return Err(GEOParseError::DisallowedScope {
                    gtype: gtype.clone(),
                });
            }
            (GEOType::Datasets, None) => None,
            (_, None) => Some(GEOScope::default()),
            _ => self.scope.clone(),
        };

        Ok(GEOADBResolver {
            entity,
            format,
            scope,
            amount,
        })
    }
}

// Accession Display Bar
// https://www.ncbi.nlm.nih.gov/geo/info/download.html
// @param format A character string in one of "text", "xml" or "html".
// Allows you to display the GEO accession in human readable, linked "HTML"
// form, or in machine readable, "text" format, which is the same with "soft"
// format. SOFT stands for "simple omnibus format in text".
#[derive(Debug, Clone, Default)]
pub enum GEOADBFormat {
    Text,
    Xml,
    #[default]
    Html,
}

impl GEOADBFormat {
    pub fn as_str(&self) -> &'static str {
        match self {
            GEOADBFormat::Text => "text",
            GEOADBFormat::Xml => "xml",
            GEOADBFormat::Html => "html",
        }
    }
}

impl fmt::Display for GEOADBFormat {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

// @param amount A character string in one of "brief", "quick", "data" or
// "full". Allows you to control the amount of data that you will see displayed.
// "Brief" displays the accession's attributes only. "Quick" displays the
// accession's attributes and the first twenty rows of its data table. "Full"
// displays the accessions's attributes and the full data table. "Data" omits
// the accession's attributes, showing only the links to other accessions as
// well as the full data table
#[derive(Debug, Clone, Default)]
pub enum GEOAmount {
    Brief,
    Quick,
    #[default]
    Data,
    Full,
}

impl GEOAmount {
    pub fn as_str(&self) -> &'static str {
        match self {
            GEOAmount::Brief => "brief",
            GEOAmount::Quick => "quick",
            GEOAmount::Data => "data",
            GEOAmount::Full => "full",
        }
    }
}

impl fmt::Display for GEOAmount {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

// @param scope A character string in one of "self", "gsm", "gpl", "gse" or
// "all". allows you to display the GEO accession(s) which you wish to target
// for display. You may display the GEO accession which is typed into the text
// box itself ("Self"), or any ("Platform", "Samples", or "Series") or all
// ("Family") of the accessions related to the accession number typed into the
// text box.
#[derive(Debug, Clone, Default)]
pub enum GEOScope {
    #[default]
    Itself,
    GSM,
    GPL,
    GSE,
    All,
}

impl GEOScope {
    pub fn as_str(&self) -> &'static str {
        match self {
            GEOScope::Itself => "self",
            GEOScope::GSM => "gsm",
            GEOScope::GPL => "gpl",
            GEOScope::GSE => "gse",
            GEOScope::All => "all",
        }
    }
}

impl fmt::Display for GEOScope {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self.as_str())
    }
}
