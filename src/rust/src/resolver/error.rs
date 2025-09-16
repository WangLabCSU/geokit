use thiserror::Error;

use super::identifier::GEOType;

#[derive(Debug, Error)]
pub(crate) enum GEOParseError {
    #[error("Expected one starting with GDS, GPL, GSM, or GSE.")]
    InvalidAccession,

    #[error("Expected one of 'brief', 'quick', 'data', or 'full'.")]
    InvalidAmount,

    #[error("Expected one of 'self', 'gsm', 'gpl', 'gse', or 'all'.")]
    InvalidScope,

    #[error("'scope' must be omitted (use `none` instead) for {gtype}")]
    AccScopeOmitted { gtype: GEOType },

    #[error("a valid 'scope' value is required for {gtype}")]
    AccScopeRequired { gtype: GEOType },

    #[error("'amount' must be omitted (use `none` instead) for {gtype}")]
    AccAmountOmitted { gtype: GEOType },

    #[error("a valid 'amount' value is required for {gtype}")]
    AccAmountRequired { gtype: GEOType },

    #[error("'format' must be omitted (use `none` instead) for {gtype}")]
    AccFormatOmitted { gtype: GEOType },

    #[error("a valid 'format' value is required for {gtype}")]
    AccFormatRequired { gtype: GEOType },

    #[error("Expected one of 'txt', 'text', 'xml', or 'html'.")]
    InvalidAccFormat,

    #[error("Expected one of 'soft', 'soft_full', 'miniml', 'matrix', 'annot', or 'suppl'.")]
    InvalidFTPFormat,

    #[error("{gtype} never own {ftype} file.")]
    UnavailableFTPFormat { gtype: GEOType, ftype: String },

    #[error("Expected one of 'none', 'brief', 'quick', 'data', 'full', 'soft', 'soft_full', 'miniml', 'matrix', 'annot', or 'suppl'.")]
    InvalidFamount,
}
