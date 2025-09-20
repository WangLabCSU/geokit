use thiserror::Error;

use super::identifier::GEOType;

#[derive(Debug, Error)]
pub(crate) enum GEOParseError {
    #[error("Expected one starting with 'GDS', 'GPL', 'GSM', or 'GSE', and followed by digits.")]
    InvalidAccession,

    #[error("Expected one of 'brief', 'quick', 'data', or 'full'.")]
    InvalidAmount,

    #[error("Expected one of 'self', 'gsm', 'gpl', 'gse', or 'all'.")]
    InvalidScope,

    #[error("Expected 'none' for {gtype}")]
    AccScopeOmitted { gtype: GEOType },

    #[error("Expected one of 'self', 'gsm', 'gpl', 'gse', or 'all' for {gtype}")]
    AccScopeRequired { gtype: GEOType },

    #[error("Expected 'none' for {gtype}")]
    AccAmountOmitted { gtype: GEOType },

    #[error("Expected one of 'brief', 'quick', 'data', or 'full' for {gtype}")]
    AccAmountRequired { gtype: GEOType },

    #[error("Expected one of 'text', 'xml', or 'html'.")]
    InvalidAccFormat,

    #[error("Expected one of 'soft', 'soft_full', 'miniml', 'matrix', 'annot', or 'suppl'.")]
    InvalidFTPFormat,

    #[error("{gtype} never own {ftype} file.")]
    // Use `String` instead, because `GEOFile` is private.
    UnavailableFormat { gtype: GEOType, ftype: String },

    #[error("Expected one of 'soft', 'soft_full', 'miniml', 'matrix', 'annot', 'suppl', 'text', 'xml', or 'html'.")]
    InvalidFormat,

    #[error("Expected one of 'none', 'brief', 'quick', 'data', 'full', 'soft', 'soft_full', 'miniml', 'matrix', 'annot', or 'suppl'.")]
    InvalidFamount,
}
