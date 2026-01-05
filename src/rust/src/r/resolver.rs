use std::str::FromStr;

use anyhow::{anyhow, Context};
use extendr_api::Robj;

use super::error::RGEOParseError;
use super::helper::*;
use crate::geo::{
    GEOADBFormat, GEOADBResolver, GEOADBResolverBuilder, GEOAmount, GEOEntity, GEOFTPFormat,
    GEOFTPResolver, GEOFTPResolverBuilder, GEOScope, GEOType,
};

// Resolver for GEO (Gene Expression Omnibus) resources.
//
// A `GEOResolver` encapsulates the logic needed to construct URLs and
// determine whether the target resource is a directory or a file,
// depending on the type of identifier and resolution strategy.
//
// Currently, two resolver backends are supported:
// - [`FTP`](GEOResolver::FTP): For direct FTP/HTTPS file retrieval from GEO FTP servers.
// - [`ADB`](GEOResolver::ADB): For file retrieval from Accession Display Bar of GEO database.
pub(crate) enum GEOResolver {
    /// Resolver for Accession Display Bar (ADB).
    ADB(GEOADBResolver),

    /// Resolver for FTP/HTTPS-based requests.
    FTP(GEOFTPResolver),
}

#[derive(Default)]
pub(crate) struct GEOResolverBuilder {
    entity: Option<GEOEntity>,
    format: Option<GEOFormat>,
    scope: Option<GEOScope>,
    amount: Option<GEOAmount>,
    over_https: Option<bool>,
}

impl GEOResolver {
    pub(crate) fn new(entity: GEOEntity) -> Self {
        Self::ADB(GEOADBResolver::new(entity))
    }

    pub(crate) fn builder() -> GEOResolverBuilder {
        GEOResolverBuilder::default()
    }

    /// Returns the GEO accession string (e.g., "GSE12345" or "GSM67890")
    /// associated with this resolver.
    #[inline]
    pub(crate) fn accession(&self) -> &str {
        match self {
            Self::ADB(resolver) => resolver.accession(),
            Self::FTP(resolver) => resolver.accession(),
        }
    }

    /// Returns the [`GEOType`] (such as `Datasets`, `Series`, or `Samples`)
    /// associated with this resolver.
    #[inline]
    pub(crate) fn gtype(&self) -> &GEOType {
        match self {
            Self::ADB(resolver) => resolver.gtype(),
            Self::FTP(resolver) => resolver.gtype(),
        }
    }

    /// Construct the full URL for GEO landing page.
    ///
    /// The returned URL points directly to the GEO record and is suitable
    /// for opening in a web browser.
    pub(crate) fn landing_page(&self) -> String {
        match self {
            Self::ADB(resolver) => resolver.landing_page(),
            Self::FTP(resolver) => resolver.landing_page(),
        }
    }

    /// Construct the full URL for this GEO resource.
    ///
    /// The returned string is the complete download or access URL,
    /// built according to the resolver type (`ADB` or `FTP`) and
    /// associated options.
    pub(crate) fn url(&self) -> String {
        match self {
            Self::ADB(resolver) => resolver.url(),
            Self::FTP(resolver) => resolver.url(),
        }
    }
}

impl GEOResolverBuilder {
    pub(crate) fn new() -> Self {
        Self::default()
    }
    pub(crate) fn entity(&mut self, entity: GEOEntity) -> &mut Self {
        self.entity = Some(entity);
        self
    }
    pub(crate) fn format(&mut self, format: GEOFormat) -> &mut Self {
        self.format = Some(format);
        self
    }

    pub(crate) fn scope(&mut self, scope: GEOScope) -> &mut Self {
        self.scope = Some(scope);
        self
    }

    pub(crate) fn amount(&mut self, amount: GEOAmount) -> &mut Self {
        self.amount = Some(amount);
        self
    }

    pub(crate) fn over_https(&mut self, over_https: bool) -> &mut Self {
        self.over_https = Some(over_https);
        self
    }

    pub(crate) fn build(&mut self) -> Result<GEOResolver, RGEOParseError> {
        let format = self
            .format
            .as_ref()
            .map_or_else(|| Err(RGEOParseError::RequireFormat), |v| Ok(v.clone()))?;
        match format {
            GEOFormat::ADB(format) => {
                let mut builder = GEOADBResolverBuilder::new();
                if let Some(entity) = &self.entity {
                    builder.entity(entity.clone());
                }
                builder.format(format);
                if let Some(amount) = &self.amount {
                    builder.amount(amount.clone());
                }
                if let Some(scope) = &self.scope {
                    builder.scope(scope.clone());
                }
                builder
                    .build()
                    .map(|solver| GEOResolver::ADB(solver))
                    .map_err(|e| RGEOParseError::GEOError(e))
            }
            GEOFormat::FTP(format) => {
                let mut builder = GEOFTPResolverBuilder::new();
                if let Some(entity) = &self.entity {
                    builder.entity(entity.clone());
                }
                builder.format(format);
                if let Some(over_https) = self.over_https {
                    builder.over_https(over_https);
                }
                builder
                    .build()
                    .map(|solver| GEOResolver::FTP(solver))
                    .map_err(|e| RGEOParseError::GEOError(e))
            }
        }
    }
}

/// Build a list of `GEOResolver`s from R objects passed via extendr.
/// Each parameter is an R object (character/logical vector) that may be
/// scalar-recycled or NULL (optional). Lengths must match `accession`
/// unless recycling is possible.
pub(crate) fn resolvers_from_format(
    accession: &Robj,
    format: &Robj,
    amount: &Robj,
    scope: &Robj,
    ftp_over_https: &Robj,
) -> Result<Vec<GEOResolver>, String> {
    let accession = accession
        .as_str_vector()
        .ok_or_else(|| anyhow!("Expected a character vector"))
        .with_context(|| format!("Invalid 'accession'"))
        .map_err(|e| format!("{:?}", e))?;

    // Optional arguments: may be NULL -> None, or character/logical vectors, recycled if necessary
    let format = robj_to_option_vec_str(format, accession.len())
        .with_context(|| format!("Invalid 'format'"))
        .map_err(|e| format!("{:?}", e))?;
    let amount = robj_to_option_vec_str(amount, accession.len())
        .with_context(|| format!("Invalid 'amount'"))
        .map_err(|e| format!("{:?}", e))?;
    let scope = robj_to_option_vec_str(scope, accession.len())
        .with_context(|| format!("Invalid 'scope'"))
        .map_err(|e| format!("{:?}", e))?;
    let ftp_over_https = robj_to_option_vec_bool(&ftp_over_https, accession.len())
        .with_context(|| format!("Invalid 'ftp_over_https'"))
        .map_err(|e| format!("{:?}", e))?;

    // Construct a resolver per accession
    accession
        .into_iter()
        .enumerate()
        .map(|(i, acc)| {
            // Parse accession string into a GEOIdentifier
            let entity = GEOEntity::try_from(acc)
                .with_context(|| format!("Invalid 'accession': {}", acc))
                .map_err(|e| format!("{:?}", e))?;
            let mut builder = GEOResolverBuilder::new();
            builder.entity(entity);

            // SAFETY: lengths were validated/recycled earlier
            let format = format.as_ref().map(|v| unsafe { *v.get_unchecked(i) });
            let amount = amount.as_ref().map(|v| unsafe { *v.get_unchecked(i) });
            let scope = scope.as_ref().map(|v| unsafe { *v.get_unchecked(i) });
            let ftp_over_https = ftp_over_https
                .as_ref()
                .map(|v| unsafe { *v.get_unchecked(i) });

            // Conditionally set optional parameters
            if let Some(format) = format {
                let format: GEOFormat = format
                    .try_into()
                    .with_context(|| format!("Invalid 'format': {}", format))
                    .map_err(|e| format!("{:?}", e))?;
                builder.format(format);
            }

            if let Some(amount) = amount {
                let amount: RGEOAmount = amount
                    .try_into()
                    .with_context(|| format!("Invalid 'amount': {}", amount))
                    .map_err(|e| format!("{:?}", e))?;
                if let RGEOAmount::Amount(a) = amount {
                    builder.amount(a);
                }
            }

            if let Some(scope) = scope {
                let rscope: RGEOScope = scope
                    .try_into()
                    .with_context(|| format!("Invalid 'scope': {}", scope))
                    .map_err(|e| format!("{:?}", e))?;
                if let RGEOScope::Scope(s) = rscope {
                    builder.scope(s);
                }
            }

            if let Some(over_https) = ftp_over_https {
                builder.over_https(over_https);
            }
            builder
                .build()
                .map_err(|e| format!("Failed to create GEOResolver: {}", e))
        })
        .collect()
}

pub(crate) fn resolvers_from_famount(
    accession: &Robj,
    famount: &Robj,
    scope: &Robj,
    ftp_over_https: &Robj,
    adb_format: &GEOADBFormat,
) -> Result<Vec<GEOResolver>, String> {
    let accession = accession
        .as_str_vector()
        .ok_or_else(|| anyhow!("Expected a character vector"))
        .with_context(|| format!("Invalid 'accession'"))
        .map_err(|e| format!("{:?}", e))?;

    // Optional arguments: may be NULL -> None, or character/logical vectors, recycled if necessary
    let famount = robj_to_option_vec_str(famount, accession.len())
        .with_context(|| format!("Invalid 'famount'"))
        .map_err(|e| format!("{:?}", e))?;
    let scope = robj_to_option_vec_str(scope, accession.len())
        .with_context(|| format!("Invalid 'scope'"))
        .map_err(|e| format!("{:?}", e))?;
    let ftp_over_https = robj_to_option_vec_bool(&ftp_over_https, accession.len())
        .with_context(|| format!("Invalid 'ftp_over_https'"))
        .map_err(|e| format!("{:?}", e))?;

    // Construct a resolver per accession
    accession
        .into_iter()
        .enumerate()
        .map(|(i, acc)| {
            // Parse accession string into a GEOIdentifier
            let entity = GEOEntity::try_from(acc)
                .with_context(|| format!("Invalid 'accession': {}", acc))
                .map_err(|e| format!("{:?}", e))?;
            let mut builder = GEOResolverBuilder::new();
            builder.entity(entity);

            // SAFETY: lengths were validated/recycled earlier
            let famount = famount.as_ref().map(|v| unsafe { *v.get_unchecked(i) });
            let format;
            let ramount;
            match famount {
                Some(s) => {
                    match s {
                        "none" | "brief" | "quick" | "data" | "full" => {
                            format = GEOFormat::ADB(adb_format.clone());
                            // SAFETY: `famount` is guaranteed to be one of the expected values for RGEOAmount
                            ramount = Some(unsafe { RGEOAmount::try_from(s).unwrap_unchecked() });
                        }
                        "soft" | "soft_full" | "miniml" | "matrix" | "annot" | "suppl" => {
                            // SAFETY: `famount` is guaranteed to be one of the expected values for GEOFormat
                            format = unsafe { GEOFormat::try_from(s).unwrap_unchecked() };
                            ramount = None;
                        }
                        _ => {
                            return Err(RGEOParseError::InvalidFamount)
                                .with_context(|| format!("Invalid 'format': {}", s))
                                .map_err(|e| format!("{:?}", e))
                        }
                    }
                }
                None => {
                    format = GEOFormat::ADB(adb_format.clone());
                    ramount = None;
                }
            }

            // SAFETY: lengths were validated/recycled earlier
            let scope = scope.as_ref().map(|v| unsafe { *v.get_unchecked(i) });
            let ftp_over_https = ftp_over_https
                .as_ref()
                .map(|v| unsafe { *v.get_unchecked(i) });
            builder.format(format);

            // Conditionally set optional parameters
            if let Some(amount) = ramount {
                if let RGEOAmount::Amount(a) = amount {
                    builder.amount(a);
                }
            }
            if let Some(scope) = scope {
                let rscope: RGEOScope = scope
                    .try_into()
                    .with_context(|| format!("Invalid 'scope': {}", scope))
                    .map_err(|e| format!("{:?}", e))?;
                if let RGEOScope::Scope(s) = rscope {
                    builder.scope(s);
                }
            }

            if let Some(over_https) = ftp_over_https {
                builder.over_https(over_https);
            }
            builder
                .build()
                .map_err(|e| format!("Failed to create GEOResolver: {}", e))
        })
        .collect()
}

// Accession Display Bar
// https://www.ncbi.nlm.nih.gov/geo/info/download.html
// @param format A character string in one of "text", "xml" or "html".
// Allows you to display the GEO accession in human readable, linked "HTML"
// form, or in machine readable, "text" format, which is the same with "soft"
// format. SOFT stands for "simple omnibus format in text".
#[derive(Debug, Clone)]
pub(crate) enum GEOFormat {
    // Accession Display Bar
    ADB(GEOADBFormat),

    // GEO FTP server
    FTP(GEOFTPFormat),
}

impl From<GEOADBFormat> for GEOFormat {
    fn from(value: GEOADBFormat) -> Self {
        Self::ADB(value)
    }
}

impl From<GEOFTPFormat> for GEOFormat {
    fn from(value: GEOFTPFormat) -> Self {
        Self::FTP(value)
    }
}

impl FromStr for GEOFormat {
    type Err = RGEOParseError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "soft" => Ok(GEOFTPFormat::SOFT.into()),
            "soft_full" => Ok(GEOFTPFormat::SOFTFull.into()),
            "miniml" => Ok(GEOFTPFormat::Miniml.into()),
            "matrix" => Ok(GEOFTPFormat::Matrix.into()),
            "annot" => Ok(GEOFTPFormat::Annot.into()),
            "suppl" => Ok(GEOFTPFormat::Suppl.into()),
            "text" => Ok(GEOADBFormat::Text.into()),
            "xml" => Ok(GEOADBFormat::Xml.into()),
            "html" => Ok(GEOADBFormat::Html.into()),
            _ => Err(RGEOParseError::InvalidFormat),
        }
    }
}

impl TryFrom<&str> for GEOFormat {
    type Error = RGEOParseError;
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
#[derive(Debug, Clone)]
pub(crate) enum RGEOScope {
    /// No value.
    None,
    /// Some value of type `T`.
    Scope(GEOScope),
}

impl FromStr for RGEOScope {
    type Err = RGEOParseError;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let scope = match s {
            "none" => RGEOScope::None,
            "self" => RGEOScope::Scope(GEOScope::Itself),
            "gsm" => RGEOScope::Scope(GEOScope::GSM),
            "gpl" => RGEOScope::Scope(GEOScope::GPL),
            "gse" => RGEOScope::Scope(GEOScope::GSE),
            "all" => RGEOScope::Scope(GEOScope::All),
            _ => {
                return Err(RGEOParseError::InvalidScope);
            }
        };
        Ok(scope)
    }
}

impl TryFrom<&str> for RGEOScope {
    type Error = RGEOParseError;
    fn try_from(value: &str) -> Result<Self, Self::Error> {
        Self::from_str(value)
    }
}

// @param amount A character string in one of "brief", "quick", "data" or
// "full". Allows you to control the amount of data that you will see displayed.
// "Brief" displays the accession's attributes only. "Quick" displays the
// accession's attributes and the first twenty rows of its data table. "Full"
// displays the accessions's attributes and the full data table. "Data" omits
// the accession's attributes, showing only the links to other accessions as
// well as the full data table
#[derive(Debug, Clone)]
pub(crate) enum RGEOAmount {
    /// No value.
    None,
    /// Some value of type `T`.
    Amount(GEOAmount),
}

impl FromStr for RGEOAmount {
    type Err = RGEOParseError;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let amount = match s {
            "none" => RGEOAmount::None,
            "brief" => RGEOAmount::Amount(GEOAmount::Brief),
            "quick" => RGEOAmount::Amount(GEOAmount::Quick),
            "data" => RGEOAmount::Amount(GEOAmount::Data),
            "full" => RGEOAmount::Amount(GEOAmount::Full),
            _ => {
                return Err(RGEOParseError::InvalidAmount);
            }
        };
        Ok(amount)
    }
}

impl TryFrom<&str> for RGEOAmount {
    type Error = RGEOParseError;
    fn try_from(value: &str) -> Result<Self, Self::Error> {
        Self::from_str(value)
    }
}
