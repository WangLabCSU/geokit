use anyhow::{Context, Result};

// Accession Display Bar
mod adb;
mod error;
// FTP site
mod ftp;
mod identifier;

pub(crate) use error::GEOParseError;
use identifier::GEOIdentifier;
pub(crate) use identifier::GEOType;

/// Resolver for GEO (Gene Expression Omnibus) resources.
///
/// A `GEOResolver` encapsulates the logic needed to construct URLs and
/// determine whether the target resource is a directory or a file,
/// depending on the type of identifier and resolution strategy.
///
/// Currently, two resolver backends are supported:
/// - [`FTP`](GEOResolver::FTP): For direct FTP/HTTPS file retrieval from GEO FTP servers.
/// - [`ADB`](GEOResolver::ADB): For file retrieval from Accession Display Bar of GEO database.
pub(crate) struct GEOResolver(GEOResolverInner);

enum GEOResolverInner {
    /// Resolver for Accession Display Bar (ADB).
    ADB(adb::GEOAccResolver),

    /// Resolver for FTP/HTTPS-based requests.
    FTP(ftp::GEOFTPResolver),
}

/// The terminal entry of a GEO URL, which may be a file or directory.
///
/// This represents the “leaf” of the resolved URL path:
/// - [`File`](GEOEntry::File): A concrete filename within the URL.
/// - [`Dir`](GEOEntry::Dir): A directory endpoint.
pub(crate) enum GEOEntry {
    /// A file entry (holds the filename).
    File(String),

    /// A directory entry.
    Dir,
}

impl GEOResolver {
    /// Build a GEOResolver from an identifier and options.
    ///
    /// # Parameters
    /// - `id`: GEO identifier (GSE, GSM, etc.)
    /// - `famount`: Optional "file/amount type":
    ///     - FTP types: "soft", "soft_full", "miniml", "matrix", "annot", "suppl"
    ///     - ADB types: "none", "brief", "quick", "data", "full"
    /// - `scope`: ADB-only option (e.g., "self", "all").
    /// - `format`: ADB-only option (e.g., "text", "xml").
    /// - `over_https`: FTP-only option (default: true).
    ///
    /// # Returns
    /// - `Ok(GEOResolver::ADB(..))` if an ADB `famount` is selected or defaulted.
    /// - `Ok(GEOResolver::FTP(..))` if an FTP `famount` is selected.
    /// - `Err(String)` if `famount` or other arguments are invalid or incompatible.
    pub(crate) fn new(
        accession: &str,
        famount: Option<&str>, // file/amount type requested ("soft", "brief", etc.)
        format: Option<&str>,  // optional format (only used for ADB famount)
        scope: Option<&str>,   // optional scope (only used for ADB famount)
        over_https: Option<bool>, // optional FTP protocol flag (only used for FTP famount)
    ) -> Result<Self> {
        let id = GEOIdentifier::try_from(accession)
            .with_context(|| format!("Invalid 'accession': {}", accession))?;
        // Determine the `famount`, providing defaults based on GEO type
        match famount {
            // Default case: if `famount` is `None`, resolve using ACC endpoint
            // ---------- ACC endpoint ----------
            // famount: "none" | "brief" | "quick" | "data" | "full"
            // - Explicit "none": resolve with ACC, but set amount = `None`
            // - `scope` and `format` are optional (resolver applies defaults if missing).
            // - `over_https` is always ignored.
            None | Some("none") | Some("brief") | Some("quick") | Some("data") | Some("full") => {
                // Build the ACC resolver
                let mut acc = adb::GEOAccResolver::new(id);

                // Parse famount into ACC amount enum (if provided)
                if let Some(amount) = famount {
                    // Parse `famount` into an ACC amount enum
                    let value = match amount {
                        "none" => None,
                        _ => Some(
                            amount
                                .try_into()
                                .with_context(|| format!("Invalid 'famount': {}", amount))?,
                        ),
                    };
                    acc.set_amount(value)
                        .with_context(|| format!("Invalid 'famount': {}", amount))?;
                };

                // Parse optional scope (default handled by resolver if None)
                if let Some(scope) = scope {
                    let value = match scope {
                        "none" => None,
                        _ => Some(
                            scope
                                .try_into()
                                .with_context(|| format!("Invalid 'scope': {}", scope))?,
                        ),
                    };
                    acc.set_scope(value)
                        .with_context(|| format!("Invalid 'scope': {}", scope))?;
                }

                // Parse optional format (default handled by resolver if None)
                if let Some(format) = format {
                    let value = match format {
                        "none" => None,
                        _ => Some(
                            format
                                .try_into()
                                .with_context(|| format!("Invalid 'format': {}", format))?,
                        ),
                    };
                    acc.set_format(value)
                        .with_context(|| format!("Invalid 'format': {}", format))?;
                }

                // over_https has no effect for ACC
                if let Some(_) = over_https {
                    eprintln!(
                        "Warning: 'over_https' will be ignored for {} famount",
                        acc.amount
                            .as_ref()
                            .map_or_else(|| "none".to_string(), |a| a.to_string())
                    )
                }
                return Ok(GEOResolver(GEOResolverInner::ADB(acc)));
            }

            // ---------- FTP endpoint ----------
            // famounts: "soft" | "soft_full" | "miniml" | "matrix" | "annot" | "suppl"
            // - Resolved through FTP resolver.
            // - Uses only file type + optional over_https flag (defaults to true).
            // - scope and format are always ignored.
            Some("soft") | Some("soft_full") | Some("miniml") | Some("matrix") | Some("annot")
            | Some("suppl") => {
                let mut ftp = ftp::GEOFTPResolver::new(id);

                // safe unwrap (famount is Some here)
                let famount = unsafe { famount.unwrap_unchecked() };

                // Parse `famount` into an FTP file enum
                let file = famount
                    .try_into()
                    .with_context(|| format!("Invalid 'famount': {}", famount))?;
                ftp.set_file(file)
                    .with_context(|| format!("Invalid 'famount': {}", famount))?;

                // Apply HTTPS preference (default true if not set)
                if let Some(over_https) = over_https {
                    ftp.over_https(over_https);
                }

                // Warn about ignored parameters
                if let Some(_) = scope {
                    eprintln!("Warning: 'scope' will be ignored for {} 'famount'", famount)
                }
                if let Some(_) = format {
                    eprintln!(
                        "Warning: 'format' will be ignored for {} 'famount'",
                        famount
                    )
                }
                return Ok(GEOResolver(GEOResolverInner::FTP(ftp)));
            }

            // ---------- Invalid famount ----------
            // If famount is not in ACC or FTP categories, return error.
            _ => {
                return Err(GEOParseError::InvalidFamount).with_context(|| {
                    // Safe unwrap (famount is Some in this branch)
                    format!("Invalid 'famount': {}", unsafe {
                        famount.unwrap_unchecked()
                    })
                });
            }
        }
    }

    /// Returns the GEO accession string (e.g., "GSE12345" or "GSM67890")
    /// associated with this resolver.
    #[allow(dead_code)]
    pub(crate) fn accession(&self) -> &str {
        match &self.0 {
            GEOResolverInner::ADB(resolver) => &resolver.id.accession,
            GEOResolverInner::FTP(resolver) => &resolver.id.accession,
        }
    }

    /// Returns the [`GEOType`] (such as `Datasets`, `Series`, or `Samples`)
    /// associated with this resolver.
    #[allow(dead_code)]
    pub(crate) fn gtype(&self) -> &GEOType {
        match &self.0 {
            GEOResolverInner::ADB(resolver) => &resolver.id.gtype,
            GEOResolverInner::FTP(resolver) => &resolver.id.gtype,
        }
    }

    /// Construct the full URL for this GEO resource.
    ///
    /// The returned string is the complete download or access URL,
    /// built according to the resolver type (`ADB` or `FTP`) and
    /// associated options.
    pub(crate) fn url(&self) -> String {
        match &self.0 {
            GEOResolverInner::ADB(resolver) => resolver.url(),
            GEOResolverInner::FTP(resolver) => resolver.url(),
        }
    }

    /// Return the entry type (file or directory) for this GEO resource.
    ///
    /// - For `ADB` resolvers, the entry depends on the requested format/scope.
    /// - For `FTP` resolvers, the entry is always known (`File` or `Dir`).
    ///
    /// Returns [`Some(GEOEntry)`] if the resolver produces a file or directory,
    /// or [`None`] if the resolver does not correspond to any concrete entry.
    pub(crate) fn entry(&self) -> Option<GEOEntry> {
        match &self.0 {
            GEOResolverInner::ADB(resolver) => resolver.entry(),
            GEOResolverInner::FTP(resolver) => Some(resolver.entry()),
        }
    }
}
