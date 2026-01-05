use thiserror::Error;

use super::entity::GEOType;
use super::resolver::adb::GEOADBFormat;
use super::resolver::ftp::GEOFTPFormat;

#[derive(Debug, Error)]
pub enum GEOParseError {
    #[error("Expected one starting with 'GDS', 'GPL', 'GSM', or 'GSE', and followed by digits.")]
    InvalidAccession,

    #[error("'entity' must be provided before building")]
    RequireEntity,

    #[error("{gtype} never own {format} file.")]
    UnavailableFTPFormat {
        gtype: GEOType,
        format: GEOFTPFormat,
    },

    #[error("{gtype} never own {format} file.")]
    UnavailableADBFormat {
        gtype: GEOType,
        format: GEOADBFormat,
    },

    #[error("The 'amount' field cannot be set for {gtype}.")]
    DisallowedAmount { gtype: GEOType },

    #[error("The 'scope' field cannot be set for {gtype}.")]
    DisallowedScope { gtype: GEOType },
}
