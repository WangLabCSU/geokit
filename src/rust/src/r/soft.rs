use extendr_api::{list, Attributes, List, Robj};
use indexmap::IndexMap;

use crate::geo::GEOSoftRecord;

use super::vector::OpaqueVector;

pub struct RGEOSoftRecord(Box<RGEOSoftRecordInner>);

struct RGEOSoftRecordInner {
    rcd_type: String, // Type of the GEO record (e.g., Series, Platform)
    rcd_name: String, // Name of the record
    metadata: IndexMap<String, Vec<Option<String>>>, // Attributes of the record (key-value pairs)
    columns: Vec<(String, Option<String>)>, // Header names and descriptions
    header: Vec<Option<String>>, // Header
    datatable: Vec<OpaqueVector>, // Data table (a data frame)
}

impl From<GEOSoftRecord> for RGEOSoftRecord {
    fn from(value: GEOSoftRecord) -> Self {
        Self(Box::new(RGEOSoftRecordInner {
            rcd_type: value.0.rcd_type,
            rcd_name: value.0.rcd_name,
            metadata: value.0.metadata,
            columns: value.0.columns,
            header: value.0.header,
            datatable: value
                .0
                .datatable
                .into_iter()
                .map(OpaqueVector::parse_string)
                .collect(),
        }))
    }
}

impl TryFrom<RGEOSoftRecord> for List {
    type Error = extendr_api::Error;

    fn try_from(value: RGEOSoftRecord) -> std::result::Result<Self, Self::Error> {
        // A named list
        let metadata =
            List::from_names_and_values(value.0.metadata.keys(), value.0.metadata.values())?;

        // A named character
        let (columns_names, columns_values): (Vec<String>, Vec<Option<String>>) =
            value.0.columns.into_iter().unzip();
        let mut columns = Robj::from(columns_values);
        columns.set_names(columns_names)?;

        // A character
        let header = Robj::from(value.0.header);

        // A data frame
        let datatable = value
            .0
            .datatable
            .into_iter()
            .map(Robj::from)
            .collect::<List>();

        // Build the final list
        let record = list![
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

impl TryFrom<RGEOSoftRecord> for Robj {
    type Error = extendr_api::Error;

    fn try_from(value: RGEOSoftRecord) -> std::result::Result<Self, Self::Error> {
        List::try_from(value).map(|ok| ok.into())
    }
}
