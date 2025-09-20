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
    ADB(adb::GEOADBResolver),

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
    File { url: String, fname: String },

    /// A directory entry.
    Dir { url: String },
}

impl GEOResolver {
    /// Build a GEOResolver from an identifier and options.
    ///
    /// # Parameters
    /// - `id`: GEO identifier (GSE, GSM, etc.)
    /// - `format`: Optional "file/amount type":
    ///     - **FTP**: "soft", "soft_full", "miniml", "matrix", "annot", or "suppl"
    ///     - **ADB** (Accession Display Bar): "text", "xml", "html"
    /// - `amount`: "none", "brief", "quick", "data", "full" (ADB-only option).
    /// - `scope`: "none", "self", "gsm", "gpl", "gse", or "all" (ADB-only option).
    /// - `over_https`: FTP-only option (default: true).
    ///
    /// # Returns
    /// - `Ok(GEOResolver::ADB(..))` if an ADB `format` is selected or defaulted.
    /// - `Ok(GEOResolver::FTP(..))` if an FTP `format` is selected.
    /// - `Err(String)` if `format` or other arguments are invalid or incompatible.
    pub(crate) fn new(
        accession: &str,
        format: &str,             // file/amount type requested ("soft", "brief", etc.)
        amount: Option<&str>,     // optional format (only used for ADB famount)
        scope: Option<&str>,      // optional scope (only used for ADB famount)
        over_https: Option<bool>, // optional FTP protocol flag (only used for FTP famount)
    ) -> Result<Self> {
        let id = GEOIdentifier::try_from(accession)
            .with_context(|| format!("Invalid 'accession': {}", accession))?;
        // Determine the `format`, providing defaults based on GEO type
        match format {
            // ---------- ACC endpoint ----------
            // - `format`: "text" | "xml" | "html"
            // - `amount` and `scope` are optional (resolver applies defaults if missing).
            // - `over_https` is always ignored.
            "text" | "xml" | "html" => {
                // Build the ACC resolver
                let mut solver = adb::GEOADBResolver::new(id);

                // Parse famount into ACC amount enum (if provided)
                // Parse `famount` into an ACC amount enum
                let adb_format = format
                    .try_into()
                    .with_context(|| format!("Invalid 'format': {}", format))?;
                solver.set_format(adb_format)
                    .with_context(|| format!("Invalid 'format': {}", format))?;

                // Parse optional format (default handled by resolver if None)
                if let Some(amount) = amount {
                    let value = match amount {
                        "none" => None,
                        _ => Some(
                            amount
                                .try_into()
                                .with_context(|| format!("Invalid 'amount': {}", amount))?,
                        ),
                    };
                    solver.set_amount(value)
                        .with_context(|| format!("Invalid 'amount': {}", amount))?;
                }

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
                    solver.set_scope(value)
                        .with_context(|| format!("Invalid 'scope': {}", scope))?;
                }

                // over_https has no effect for ADB
                if let Some(_) = over_https {
                    eprintln!(
                        "Warning: 'over_https' will be ignored for {} 'format'",
                        format
                    )
                }
                return Ok(GEOResolver(GEOResolverInner::ADB(solver)));
            }

            // ---------- FTP endpoint ----------
            // format: "soft" | "soft_full" | "miniml" | "matrix" | "annot" | "suppl"
            // - Resolved through FTP resolver.
            // - Uses only file type + optional over_https flag (defaults to true).
            // - scope and format are always ignored.
            "soft" | "soft_full" | "miniml" | "matrix" | "annot" | "suppl" => {
                let mut solver = ftp::GEOFTPResolver::new(id);

                // Parse `format` into an FTP file enum
                let ftp_format = format
                    .try_into()
                    .with_context(|| format!("Invalid 'format': {}", format))?;
                solver.set_format(ftp_format)
                    .with_context(|| format!("Invalid 'format': {}", format))?;

                // Apply HTTPS preference (default true if not set)
                if let Some(over_https) = over_https {
                    solver.over_https(over_https);
                }

                // Warn about ignored parameters
                if let Some(_) = amount {
                    eprintln!("Warning: 'amount' will be ignored for {} 'format'", format)
                }
                if let Some(_) = scope {
                    eprintln!("Warning: 'scope' will be ignored for {} 'format'", format)
                }
                return Ok(GEOResolver(GEOResolverInner::FTP(solver)));
            }

            // ---------- Invalid famount ----------
            // If famount is not in ACC or FTP categories, return error.
            _ => {
                return Err(GEOParseError::InvalidFormat).with_context(|| {
                    // Safe unwrap (famount is Some in this branch)
                    format!("Invalid 'format': {}", format)
                });
            }
        }
    }

    /// Returns the GEO accession string (e.g., "GSE12345" or "GSM67890")
    /// associated with this resolver.
    #[allow(dead_code)]
    pub(crate) fn accession(&self) -> &str {
        match &self.0 {
            GEOResolverInner::ADB(resolver) => resolver.accession(),
            GEOResolverInner::FTP(resolver) => resolver.accession(),
        }
    }

    /// Returns the [`GEOType`] (such as `Datasets`, `Series`, or `Samples`)
    /// associated with this resolver.
    #[allow(dead_code)]
    pub(crate) fn gtype(&self) -> &GEOType {
        match &self.0 {
            GEOResolverInner::ADB(resolver) => resolver.gtype(),
            GEOResolverInner::FTP(resolver) => resolver.gtype(),
        }
    }

    /// Construct the full URL for GEO landing page.
    ///
    /// The returned URL points directly to the GEO record and is suitable
    /// for opening in a web browser.
    pub(crate) fn landing_page(&self) -> String {
        match &self.0 {
            GEOResolverInner::ADB(resolver) => resolver.landing_page(),
            GEOResolverInner::FTP(resolver) => resolver.landing_page(),
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
