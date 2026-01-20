use indexmap::IndexMap;

/// Represents a record in the SOFT (Simple Omnibus Format in Text) file.
///
/// This structure holds the parsed data for a single record. It includes:
/// - `rcd_type`: The type of the record (e.g., Platform, Sample, Series, Datasets).
/// - `rcd_name`: The name associated with the record (e.g., the GEO dataset name).
/// - `metadata`: A HashMap holding the attributes of the record (key-value pairs).
/// - `columns`: A Vector describing the columns of the data table (header name and description).
/// - `datatable`: A data frame (Vec of Vecs) holding the actual data for the record (rows and columns).
#[derive(Debug, Clone)]
pub struct GEOSoftRecord(pub(super) Box<GEOSoftRecordInner>);

#[derive(Debug, Clone)]
pub(super) struct GEOSoftRecordInner {
    pub(super) rcd_type: String, // Type of the GEO record (e.g., Series, Platform)
    pub(super) rcd_name: String, // Name of the record
    pub(super) metadata: IndexMap<String, Vec<Option<String>>>, // Attributes of the record (key-value pairs)
    pub(super) columns: Vec<(String, Option<String>)>,          // Header names and descriptions
    pub(super) header: Vec<Option<String>>,                     // Header
    pub(super) datatable: Vec<Vec<Option<String>>>,             // Data table (a data frame)
}

impl Default for GEOSoftRecord {
    fn default() -> Self {
        Self(Box::new(GEOSoftRecordInner {
            rcd_type: String::new(),
            rcd_name: String::new(),
            metadata: IndexMap::new(),
            columns: Vec::new(),
            header: Vec::new(),
            datatable: Vec::new(),
        }))
    }
}

// Simple Omnibus Format in Text (SOFT) File
// https://www.ncbi.nlm.nih.gov/geo/info/soft.html#format
// There are four different types of line that are recognized in SOFT. The
// presence of any one of three characters in the first character position in
// the line indicates three of the line types, and the absence of any of these
// indicates the fourth line type. The four line-type characters and
// descriptions of what they indicate are:
// | Symbol | Description |             Line type              |
// | :----: | :---------: | :--------------------------------: |
// |   ^    | caret lines |       entity indicator line        |
// |   !    | bang lines  |       entity attribute line        |
// |   #    | hash lines  | data table header description line |
// |  n/a   | data lines  |           data table row           |
impl GEOSoftRecord {
    #[inline]
    pub fn new() -> Self {
        Self::default()
    }

    #[inline]
    pub fn rcd_type(&self) -> &str {
        &self.0.rcd_type
    }

    #[inline]
    pub fn rcd_name(&self) -> &str {
        &self.0.rcd_name
    }

    #[inline]
    pub fn metadata(&self) -> &IndexMap<String, Vec<Option<String>>> {
        &self.0.metadata
    }

    #[inline]
    pub fn columns(&self) -> &Vec<(String, Option<String>)> {
        &self.0.columns
    }

    #[inline]
    pub fn header(&self) -> &Vec<Option<String>> {
        &self.0.header
    }

    #[inline]
    pub fn datatable(&self) -> &Vec<Vec<Option<String>>> {
        &self.0.datatable
    }

    #[inline]
    pub fn is_empty(&self) -> bool {
        self.0.rcd_type.is_empty()
            && self.0.rcd_name.is_empty()
            && self.0.metadata.is_empty()
            && self.0.columns.is_empty()
            && self.0.header.is_empty()
            && self.0.datatable.is_empty()
    }

    #[inline]
    pub fn clear(&mut self) {
        self.0.rcd_type.clear();
        self.0.rcd_name.clear();
        self.0.metadata.clear();
        self.0.columns.clear();
        self.0.header.clear();
        self.0.datatable.clear();
    }
}
