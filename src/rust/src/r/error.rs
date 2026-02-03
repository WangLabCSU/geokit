use thiserror::Error;

use crate::geo::GEOParseError;

#[derive(Debug, Error)]
pub enum RGEOParseError {
    #[error("{0}")]
    GEOError(#[from] GEOParseError),

    #[error("'entity' must be provided before building")]
    RequireEntity,

    #[error("Expected one of 'none', 'brief', 'quick', 'data', or 'full'.")]
    InvalidAmount,

    #[error("Expected one of 'none', 'self', 'gsm', 'gpl', 'gse', or 'all'.")]
    InvalidScope,

    #[error("Expected one of 'soft', 'soft_full', 'miniml', 'matrix', 'annot', 'suppl', 'text', 'xml', or 'html'.")]
    InvalidFormat,

    #[error("Expected one of 'standard', or 'matrix'.")]
    InvalidSoftFormat,

    #[error("Expected 'metadata' or 'datatable'.")]
    InvalidSoftLines,

    #[error("Expected one of 'brief', 'quick', 'data', 'full', 'soft', 'soft_full', 'miniml', 'matrix', 'annot', or 'suppl'.")]
    InvalidFamount,
}
