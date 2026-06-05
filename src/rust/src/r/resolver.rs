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
pub(super) enum GEOResolver {
    /// Resolver for Accession Display Bar (ADB).
    ADB(GEOADBResolver),

    /// Resolver for FTP/HTTPS-based requests.
    FTP(GEOFTPResolver),
}

impl GEOResolver {
    #[allow(dead_code)]
    pub(super) fn new(entity: GEOEntity) -> Self {
        Self::ADB(GEOADBResolver::new(entity))
    }

    #[allow(dead_code)]
    pub(super) fn builder() -> GEOResolverBuilder {
        GEOResolverBuilder::default()
    }

    /// Returns the GEO accession string (e.g., "GSE12345" or "GSM67890")
    /// associated with this resolver.
    #[allow(dead_code)]
    pub(super) fn accession(&self) -> &str {
        match self {
            Self::ADB(resolver) => resolver.accession(),
            Self::FTP(resolver) => resolver.accession(),
        }
    }

    /// Returns the [`GEOType`] (such as `Datasets`, `Series`, or `Samples`)
    /// associated with this resolver.
    #[allow(dead_code)]
    pub(super) fn gtype(&self) -> &GEOType {
        match self {
            Self::ADB(resolver) => resolver.gtype(),
            Self::FTP(resolver) => resolver.gtype(),
        }
    }

    /// Construct the full URL for GEO landing page.
    ///
    /// The returned URL points directly to the GEO record and is suitable
    /// for opening in a web browser.
    pub(super) fn landing_page(&self) -> String {
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
    pub(super) fn url(&self) -> String {
        match self {
            Self::ADB(resolver) => resolver.url(),
            Self::FTP(resolver) => resolver.url(),
        }
    }

    pub(super) fn fname(&self) -> Option<String> {
        match self {
            Self::ADB(resolver) => Some(resolver.fname()),
            Self::FTP(resolver) => resolver.fname(),
        }
    }
}

#[derive(Default)]
pub(super) struct GEOResolverBuilder {
    entity: Option<GEOEntity>,
    format: Option<GEOFormat>,
    scope: Option<GEOScope>,
    amount: Option<GEOAmount>,
    over_https: Option<bool>,
}

impl GEOResolverBuilder {
    pub(super) fn new() -> Self {
        Self::default()
    }

    pub(super) fn entity(&mut self, entity: GEOEntity) -> &mut Self {
        self.entity = Some(entity);
        self
    }

    pub(super) fn format(&mut self, format: GEOFormat) -> &mut Self {
        self.format = Some(format);
        self
    }

    pub(super) fn scope(&mut self, scope: GEOScope) -> &mut Self {
        self.scope = Some(scope);
        self
    }

    pub(super) fn amount(&mut self, amount: GEOAmount) -> &mut Self {
        self.amount = Some(amount);
        self
    }

    pub(super) fn over_https(&mut self, over_https: bool) -> &mut Self {
        self.over_https = Some(over_https);
        self
    }

    pub(super) fn build(&mut self) -> std::result::Result<GEOResolver, RGEOParseError> {
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
                builder.entity(entity);
                builder.format(format);
                if let Some(amount) = &self.amount {
                    builder.amount(amount.clone());
                }
                if let Some(scope) = &self.scope {
                    builder.scope(scope.clone());
                }
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
pub(super) fn resolvers_from_format<F: Fn(&GEOType) -> &str>(
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

pub(super) fn resolvers_from_famount<F: Fn(&GEOType) -> &str>(
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
    amount: Option<Vec<Option<GEOAmount>>>,
    scope: Option<Vec<Option<GEOScope>>>,
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
                .chain(std::iter::repeat(None)),
        )
        .zip(
            scope
                .unwrap_or_default()
                .into_iter()
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
        if let Some(a) = amount {
            builder.amount(a);
        }
        if let Some(s) = scope {
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

fn build_amount(amount: &[&str]) -> Result<Vec<Option<GEOAmount>>, RGEOParseError> {
    amount
        .iter()
        .map(|&s| {
            let amount = match s {
                "none" => None,
                "brief" => Some(GEOAmount::Brief),
                "quick" => Some(GEOAmount::Quick),
                "data" => Some(GEOAmount::Data),
                "full" => Some(GEOAmount::Full),
                _ => {
                    return Err(RGEOParseError::InvalidAmount);
                }
            };
            Ok(amount)
        })
        .collect()
}

fn build_scope(scope: &[&str]) -> Result<Vec<Option<GEOScope>>, RGEOParseError> {
    scope
        .iter()
        .map(|&s| {
            let scope = match s {
                "none" => None,
                "self" => Some(GEOScope::Itself),
                "gsm" => Some(GEOScope::GSM),
                "gpl" => Some(GEOScope::GPL),
                "gse" => Some(GEOScope::GSE),
                "all" => Some(GEOScope::All),
                _ => {
                    return Err(RGEOParseError::InvalidScope);
                }
            };
            Ok(scope)
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
pub(super) enum GEOFormat {
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
