use thiserror::Error;

use crate::geo::GEOParseError;

#[derive(Debug, Error)]
pub enum RGEOParseError {
    #[error("{0}")]
    GEOError(#[from] GEOParseError),

    #[error("Expected one of 'none', 'brief', 'quick', 'data', or 'full'.")]
    InvalidAmount,

    #[error("Expected one of 'none', 'self', 'gsm', 'gpl', 'gse', or 'all'.")]
    InvalidScope,

    #[error("Expected one of 'soft', 'soft_full', 'miniml', 'matrix', 'annot', 'suppl', 'text', 'xml', or 'html'.")]
    InvalidFormat,

    #[error("(Landing page) Expected one of 'brief', 'quick', 'data', 'full', 'soft', 'soft_full', 'miniml', 'matrix', 'annot', or 'suppl'.")]
    InvalidFamountLanding,

    #[error("(SOFT) Expected one of 'brief', 'quick', 'data', 'full', 'soft', or 'soft_full'.")]
    InvalidFamountSoft,
}
