use std::{fmt::Display, str::FromStr};

use anyhow::{anyhow, Context, Result};
use extendr_api::Robj;

use crate::geo::{
    GEOADBFormat, GEOADBResolver, GEOADBResolverBuilder, GEOAmount, GEOEntity, GEOFTPFormat,
    GEOFTPResolver, GEOFTPResolverBuilder, GEOScope, GEOType,
};

use super::error::RGEOParseError;
use super::helper::*;

// Resolver for GEO (Gene Expression Omnibus) resources.
//
// A `GEOResolver` encapsulates the logic needed to construct URLs and
// determine whether the target resource is a directory or a file,
// depending on the type of identifier and resolution strategy.
//
// Currently, two resolver backends are supported:
// - [`FTP`](GEOResolver::FTP): For direct FTP/HTTPS file retrieval from GEO FTP servers.
// - [`ADB`](GEOResolver::ADB): For file retrieval from Accession Display Bar of GEO database.
#[allow(clippy::upper_case_acronyms)]
pub(crate) enum GEOResolver {
    /// Resolver for Accession Display Bar (ADB).
    ADB(GEOADBResolver),

    /// Resolver for FTP/HTTPS-based requests.
    FTP(GEOFTPResolver),
}

impl GEOResolver {
    #[allow(dead_code)]
    pub(crate) fn new(entity: GEOEntity) -> Self {
        Self::ADB(GEOADBResolver::new(entity))
    }

    #[allow(dead_code)]
    pub(crate) fn builder() -> GEOResolverBuilder {
        GEOResolverBuilder::default()
    }

    /// Returns the GEO accession string (e.g., "GSE12345" or "GSM67890")
    /// associated with this resolver.
    #[allow(dead_code)]
    pub(crate) fn accession(&self) -> &str {
        match self {
            Self::ADB(resolver) => resolver.accession(),
            Self::FTP(resolver) => resolver.accession(),
        }
    }

    /// Returns the [`GEOType`] (such as `Datasets`, `Series`, or `Samples`)
    /// associated with this resolver.
    #[allow(dead_code)]
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

    pub(crate) fn fname(&self) -> Option<String> {
        match self {
            Self::ADB(resolver) => Some(resolver.fname()),
            Self::FTP(resolver) => resolver.fname(),
        }
    }
}

#[derive(Default)]
pub(crate) struct GEOResolverBuilder {
    entity: Option<GEOEntity>,
    format: Option<GEOFormat>,
    scope: Option<GEOScope>,
    amount: Option<GEOAmount>,
    over_https: Option<bool>,
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

    pub(crate) fn build(&mut self) -> std::result::Result<GEOResolver, RGEOParseError> {
        // since all entity have the `GEOADBFormat::Html` format, we use it as the default
        let entity = self
            .entity
            .as_ref()
            .map_or_else(|| Err(RGEOParseError::RequireEntity), |v| Ok(v.clone()))?;
        let format = self
            .format
            .as_ref()
            .map_or_else(GEOFormat::default, |v| v.clone());
        match format {
            GEOFormat::ADB(format) => {
                let mut builder = GEOADBResolverBuilder::new();
                match entity.gtype() {
                    GEOType::Datasets => {}
                    _ => {
                        if let Some(amount) = &self.amount {
                            builder.amount(amount.clone());
                        }
                        if let Some(scope) = &self.scope {
                            builder.scope(scope.clone());
                        }
                    }
                }
                builder.entity(entity);
                builder.format(format);
                builder
                    .build()
                    .map(GEOResolver::ADB)
                    .map_err(RGEOParseError::GEOError)
            }
            GEOFormat::FTP(format) => {
                let mut builder = GEOFTPResolverBuilder::new();
                if let Some(over_https) = self.over_https {
                    builder.over_https(over_https);
                }
                builder.entity(entity);
                builder.format(format);
                builder
                    .build()
                    .map(GEOResolver::FTP)
                    .map_err(RGEOParseError::GEOError)
            }
        }
    }
}

/// Build a list of `GEOResolver`s from R objects passed via extendr.
/// Each parameter is an R object (character/logical vector) that may be
/// scalar-recycled or NULL (optional). Lengths must match `accession`
/// unless recycling is possible.
pub(crate) fn resolvers_from_format<F: Fn(&GEOType) -> &str>(
    accession: &Robj,
    format: &Robj,
    amount: &Robj,
    scope: &Robj,
    ftp_over_https: &Robj,
    default_format: F,
) -> Result<Vec<GEOResolver>> {
    // Parse accession string into a GEOEntity
    // entity is required
    let entity_vec = build_entity(accession)?;

    // Optional arguments: may be NULL -> None, or character/logical vectors, recycled if necessary
    let format = robj_to_option_vec_str(format, entity_vec.len())
        .with_context(|| "Invalid 'format'".to_string())?
        .unwrap_or_else(|| {
            entity_vec
                .iter()
                .map(|entity| default_format(entity.gtype()))
                .collect()
        });
    let format = build_format(&format)?;
    let amount = robj_to_option_vec_str(amount, entity_vec.len())
        .with_context(|| "Invalid 'amount'".to_string())?
        .map(|vec| build_amount(&vec))
        .transpose()?;
    let scope = robj_to_option_vec_str(scope, entity_vec.len())
        .with_context(|| "Invalid 'scope'".to_string())?
        .map(|vec| build_scope(&vec))
        .transpose()?;
    let ftp_over_https = robj_to_option_vec_bool(ftp_over_https, entity_vec.len())
        .with_context(|| "Invalid 'ftp_over_https'".to_string())?;
    build_resolvers(entity_vec, format, amount, scope, ftp_over_https)
}

pub(crate) fn resolvers_from_famount<F: Fn(&GEOType) -> &str>(
    accession: &Robj,
    famount: &Robj,
    scope: &Robj,
    ftp_over_https: &Robj,
    default_famount: F,
    default_format: &str,
) -> Result<Vec<GEOResolver>> {
    // Parse accession string into a GEOEntity
    // entity is required
    let entity_vec = build_entity(accession)?;

    // Optional arguments: may be NULL -> None, or character/logical vectors, recycled if necessary
    let famount = robj_to_option_vec_str(famount, entity_vec.len())
        .with_context(|| "Invalid 'famount'".to_string())?
        .unwrap_or_else(|| {
            entity_vec
                .iter()
                .map(|entity| default_famount(entity.gtype()))
                .collect()
        });
    let mut format = Vec::with_capacity(entity_vec.len());
    let mut amount = Vec::with_capacity(entity_vec.len());
    for s in famount.into_iter() {
        match s {
            "none" | "brief" | "quick" | "data" | "full" => {
                format.push(default_format);
                amount.push(s);
            }
            "soft" | "soft_full" | "miniml" | "matrix" | "annot" | "suppl" => {
                format.push(s);
                amount.push("none");
            }
            _ => {
                return Err(RGEOParseError::InvalidFamount)
                    .with_context(|| format!("Invalid 'famount': {}", s))
            }
        }
    }
    let format = build_format(&format)?;
    let amount = build_amount(&amount)?;

    let scope = robj_to_option_vec_str(scope, entity_vec.len())
        .with_context(|| "Invalid 'scope'".to_string())?
        .map(|vec| build_scope(&vec))
        .transpose()?;
    let ftp_over_https = robj_to_option_vec_bool(ftp_over_https, entity_vec.len())
        .with_context(|| "Invalid 'ftp_over_https'".to_string())?;

    build_resolvers(entity_vec, format, Some(amount), scope, ftp_over_https)
}

fn build_resolvers(
    entity: Vec<GEOEntity>,
    format: Vec<GEOFormat>,
    amount: Option<Vec<RGEOAmount>>,
    scope: Option<Vec<RGEOScope>>,
    ftp_over_https: Option<Vec<bool>>,
) -> Result<Vec<GEOResolver>> {
    let mut resolvers = Vec::with_capacity(entity.len());
    let mut builder = GEOResolverBuilder::new();
    for ((((entity, format), amount), scope), over_https) in entity
        .into_iter()
        .zip(format.into_iter())
        .zip(
            amount
                .unwrap_or_default()
                .into_iter()
                .map(Some)
                .chain(std::iter::repeat(None)),
        )
        .zip(
            scope
                .unwrap_or_default()
                .into_iter()
                .map(Some)
                .chain(std::iter::repeat(None)),
        )
        .zip(
            ftp_over_https
                .unwrap_or_default()
                .into_iter()
                .map(Some)
                .chain(std::iter::repeat(None)),
        )
    {
        builder.entity(entity);
        builder.format(format);

        // amount and scope are optional
        if let Some(RGEOAmount::Amount(a)) = amount {
            builder.amount(a);
        }
        if let Some(RGEOScope::Scope(s)) = scope {
            builder.scope(s);
        }
        if let Some(o) = over_https {
            builder.over_https(o);
        }
        let resolver = builder.build()?;
        resolvers.push(resolver);
    }
    // Construct a resolver per accession
    Ok(resolvers)
}

fn build_entity(accession: &Robj) -> Result<Vec<GEOEntity>> {
    accession
        .as_str_vector()
        .ok_or_else(|| anyhow!("Expected a character vector"))
        .with_context(|| "Invalid 'accession'".to_string())?
        .into_iter()
        .map(GEOEntity::try_from)
        .collect::<Result<Vec<_>, _>>()
        .with_context(|| "Invalid 'accession'".to_string())
}

fn build_format(format: &[&str]) -> Result<Vec<GEOFormat>> {
    format
        .iter()
        .map(|&s| {
            s.try_into()
                .with_context(|| format!("Invalid 'format': {}", s))
        })
        .collect()
}

fn build_amount(amount: &[&str]) -> Result<Vec<RGEOAmount>> {
    amount
        .iter()
        .map(|&s| {
            s.try_into()
                .with_context(|| format!("Invalid 'amount': {}", s))
        })
        .collect()
}

fn build_scope(scope: &[&str]) -> Result<Vec<RGEOScope>> {
    scope
        .iter()
        .map(|&s| {
            s.try_into()
                .with_context(|| format!("Invalid 'scope': {}", s))
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
#[allow(clippy::upper_case_acronyms)]
pub(crate) enum GEOFormat {
    // Accession Display Bar
    ADB(GEOADBFormat),

    // GEO FTP server
    FTP(GEOFTPFormat),
}

impl Default for GEOFormat {
    fn default() -> Self {
        Self::ADB(GEOADBFormat::Html)
    }
}

impl Display for GEOFormat {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::ADB(format) => format.fmt(f),
            Self::FTP(format) => format.fmt(f),
        }
    }
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
    /// Some value of type `GEOAmount`.
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
