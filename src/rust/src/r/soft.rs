use extendr_api::{list, Attributes, List, Robj};

use crate::geo::GEOSoftRecord;

use super::helper::robj_from_parsing_str;

pub struct RGEOSoftRecord(GEOSoftRecord);

impl From<GEOSoftRecord> for RGEOSoftRecord {
    fn from(value: GEOSoftRecord) -> Self {
        Self(value)
    }
}

impl TryFrom<&RGEOSoftRecord> for List {
    type Error = extendr_api::Error;

    fn try_from(value: &RGEOSoftRecord) -> std::result::Result<Self, Self::Error> {
        // A named list
        let metadata =
            List::from_names_and_values(value.0.metadata().keys(), value.0.metadata().values())?;

        // A named character
        let mut columns: Robj = value
            .0
            .columns()
            .iter()
            .map(|(_, values)| values.as_ref().map(|s| s.as_str()))
            .collect();
        let columns_names: Robj = value
            .0
            .columns()
            .iter()
            .map(|(names, _)| names.as_str())
            .collect();
        columns.set_attrib(extendr_api::symbol::names_symbol(), columns_names)?;

        // A data frame
        let datatable = value
            .0
            .datatable()
            .iter()
            .map(|vec| robj_from_parsing_str(vec))
            .collect::<List>();

        // Build the final list
        let record = list![
            rcd_type = Robj::from(value.0.rcd_type()),
            rcd_name = Robj::from(value.0.rcd_name()),
            metadata = metadata,
            columns = columns,
            header = Robj::from(value.0.header()),
            datatable = datatable
        ];
        Ok(record)
    }
}

impl TryFrom<&RGEOSoftRecord> for Robj {
    type Error = extendr_api::Error;

    fn try_from(value: &RGEOSoftRecord) -> std::result::Result<Self, Self::Error> {
        List::try_from(value).map(|ok| ok.into())
    }
}
