use extendr_api::{Attributes, List, Robj};
use indexmap::IndexMap;

use crate::geo::GEOSoftRecord;

use super::vector::OpaqueVector;

pub struct RGEOSoftRecord(Box<RGEOSoftRecordInner>);

pub struct RGEOSoftRecordInner {
    rcd_type: String, // Type of the GEO record (e.g., Series, Platform)
    rcd_name: String, // Name of the record
    metadata: IndexMap<String, Vec<Option<String>>>, // Attributes of the record (key-value pairs)
    columns: Vec<(String, Option<String>)>, // Header names and descriptions
    header: Vec<Option<String>>, // Header
    datatable: Vec<OpaqueVector>, // Data table (a data frame)
}

impl From<GEOSoftRecord> for RGEOSoftRecord {
    fn from(value: GEOSoftRecord) -> Self {
        let record = *value.0;
        Self(Box::new(RGEOSoftRecordInner {
            rcd_type: record.rcd_type,
            rcd_name: record.rcd_name,
            metadata: record.metadata,
            columns: record.columns,
            header: record.header,
            datatable: record
                .datatable
                .into_iter()
                .map(OpaqueVector::parse_string)
                .collect(),
        }))
    }
}

impl TryFrom<RGEOSoftRecord> for extendr_api::List {
    type Error = extendr_api::Error;

    fn try_from(value: RGEOSoftRecord) -> std::result::Result<Self, Self::Error> {
        // A named list
        let (metadata_keys, metadata_values): (Vec<_>, Vec<_>) =
            value.0.metadata.into_iter().unzip();
        let mut metadata = extendr_api::List::from_values(metadata_values);
        metadata.set_names(metadata_keys)?;

        // A named character
        let (columns_names, columns_values): (Vec<String>, Vec<Option<String>>) =
            value.0.columns.into_iter().unzip();
        let mut columns = extendr_api::Robj::from(columns_values);
        columns.set_names(columns_names)?;

        // A character
        let header = extendr_api::Robj::from(value.0.header);

        // A data frame
        let datatable = value
            .0
            .datatable
            .into_iter()
            .map(|v| Robj::from(v))
            .collect::<List>();

        // Build the final list
        let record = extendr_api::list![
            rcd_type = value.0.rcd_type,
            rcd_name = value.0.rcd_name,
            metadata = metadata,
            columns = columns,
            header = header,
            datatable = datatable
        ];
        Ok(record)
    }
}

impl TryFrom<RGEOSoftRecord> for extendr_api::Robj {
    type Error = extendr_api::Error;

    fn try_from(value: RGEOSoftRecord) -> std::result::Result<Self, Self::Error> {
        extendr_api::List::try_from(value).map(|ok| ok.into())
    }
}
