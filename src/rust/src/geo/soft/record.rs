use indexmap::IndexMap;
use memchr::memchr;

use super::{GEOSoftConfig, GEOSoftFormat, GEOSoftLine};

/// Represents a record in the SOFT (Simple Omnibus Format in Text) file.
///
/// This structure holds the parsed data for a single record. It includes:
/// - `rcd_type`: The type of the record (e.g., Platform, Sample, Series, Datasets).
/// - `rcd_name`: The name associated with the record (e.g., the GEO dataset name).
/// - `metadata`: A HashMap holding the attributes of the record (key-value pairs).
/// - `columns`: A Vector describing the columns of the data table (header name and description).
/// - `datatable`: A data frame (Vec of Vecs) holding the actual data for the record (rows and columns).
#[derive(Debug, Clone)]
pub struct GEOSoftRecord(pub(crate) Box<GEOSoftRecordInner>);

#[derive(Debug, Clone)]
pub(crate) struct GEOSoftRecordInner {
    pub(crate) rcd_type: String, // Type of the GEO record (e.g., Series, Platform)
    pub(crate) rcd_name: String, // Name of the record
    pub(crate) metadata: IndexMap<String, Vec<Option<String>>>, // Attributes of the record (key-value pairs)
    pub(crate) columns: Vec<(String, Option<String>)>,          // Header names and descriptions
    pub(crate) header: Vec<Option<String>>,                     // Header
    pub(crate) datatable: Vec<Vec<Option<String>>>,             // Data table (a data frame)
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
    pub fn new() -> Self {
        Self(Box::new(GEOSoftRecordInner {
            rcd_type: String::new(),
            rcd_name: String::new(),
            metadata: IndexMap::new(),
            columns: Vec::new(),
            header: Vec::new(),
            datatable: Vec::new(),
        }))
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
    pub fn empty(&self) -> bool {
        self.0.rcd_type.is_empty()
            && self.0.rcd_name.is_empty()
            && self.0.metadata.is_empty()
            && self.0.columns.is_empty()
            && self.0.header.is_empty()
            && self.0.datatable.is_empty()
    }

    #[inline]
    pub fn parse_line(&mut self, line: &[u8], config: &GEOSoftConfig) {
        // ignore empty lines
        if line.is_empty() || line.iter().all(|byte| byte.is_ascii_whitespace()) {
            return;
        }
        match unsafe { line.get_unchecked(0) } {
            b'^' => self.parse_caret(line),
            b'!' => {
                if config.use_lines().contains(&GEOSoftLine::Metadata) {
                    match config.format() {
                        GEOSoftFormat::Standard => self.parse_regular_bang(line),
                        GEOSoftFormat::Matrix => self.parse_matrix_bang(line),
                    };
                }
            }
            b'#' => {
                if config.use_lines().contains(&GEOSoftLine::Datatable) {
                    self.parse_hash(line);
                }
            }
            _ => {
                if config.use_lines().contains(&GEOSoftLine::Datatable) {
                    self.parse_data(line);
                }
            }
        }
    }

    #[inline]
    fn parse_caret(&mut self, line: &[u8]) {
        let prefix = if let Some(pos) = memchr(b'=', line) {
            // SAFETY: we have ensure the line starts with '^'
            let prefix = unsafe { line.get_unchecked(1..pos) };
            if pos + 1 < line.len() {
                let rcd_name =
                    bytes_to_string(unsafe { line.get_unchecked(pos + 1..) }.trim_ascii());
                self.0.rcd_name = rcd_name;
            }
            prefix
        } else {
            unsafe { line.get_unchecked(1..) }
        };
        self.0.rcd_type = bytes_to_string(prefix.trim_ascii_end());
    }

    #[inline]
    fn parse_regular_bang(&mut self, line: &[u8]) {
        // for normal SOFT file, the metadata is seprated with `=`
        if let Some(pos) = memchr(b'=', line) {
            if pos + 1 < line.len() {
                // SAFETY: we have ensure the line starts with '!'
                let label = bytes_to_string(unsafe { line.get_unchecked(1..pos) }.trim_ascii_end());
                // SAFETY: we have ensured 'pos + 1' doesn't span the ending
                let value = bytes_to_string(unsafe { line.get_unchecked(pos + 1..) }.trim_ascii());
                if let Some(metadata) = self.0.metadata.get_mut(&label) {
                    metadata.push(Some(value));
                } else {
                    self.0.metadata.insert(label, vec![Some(value)]);
                }
            }
        }
    }

    #[inline]
    fn parse_matrix_bang(&mut self, line: &[u8]) {
        // for GSE matrix, the metadata is seprated with `\t`
        if let Some(pos) = memchr(b'\t', line) {
            if pos + 1 < line.len() {
                // SAFETY: we have ensure the line starts with '!'
                let label = bytes_to_string(unsafe { line.get_unchecked(1..pos) }.trim_ascii_end());
                // SAFETY: we have ensured 'pos + 1' doesn't span the ending
                let fields = unsafe { line.get_unchecked(pos + 1..) }
                    .split(|byte| *byte == b'\t')
                    .map(|field| {
                        let field = strip_quotes(field.trim_ascii());
                        if field.is_empty()
                            || field.eq_ignore_ascii_case(b"null")
                            || field.eq_ignore_ascii_case(b"na")
                        {
                            None
                        } else {
                            Some(bytes_to_string(field))
                        }
                    })
                    .collect::<Vec<Option<String>>>();

                // Check if the label already exists and add a suffix to ensure uniqueness
                let mut suffix = 1;
                let mut label_check = label.clone();
                while self.0.metadata.contains_key(&label_check) {
                    label_check = format!("{}_{}", label, suffix);
                    suffix += 1;
                }
                self.0.metadata.insert(label_check, fields);
            }
        }
    }

    #[inline]
    fn parse_hash(&mut self, line: &[u8]) {
        // SAFETY: we have ensure the line starts with '#'
        if let Some(pos) = memchr(b'=', line) {
            let label = bytes_to_string(unsafe { line.get_unchecked(1..pos) }.trim_ascii_end());
            let value = if pos + 1 < line.len() {
                bytes_to_string(unsafe { line.get_unchecked(pos + 1..) }.trim_ascii())
            } else {
                String::new()
            };
            if value.is_empty() {
                self.0.columns.push((label, None));
            } else {
                self.0.columns.push((label, Some(value)));
            }
        }
    }

    #[inline]
    fn parse_data(&mut self, line: &[u8]) {
        // data table follows the csv file with a separater of '\t'
        let fields = line
            .split(|byte| *byte == b'\t')
            .map(|field| {
                let field = strip_quotes(field.trim_ascii());
                if field.is_empty()
                    || field.eq_ignore_ascii_case(b"null")
                    || field.eq_ignore_ascii_case(b"na")
                {
                    None
                } else {
                    // SOFT File may contain non-UTF8 character
                    Some(bytes_to_string(field))
                }
            })
            .collect::<Vec<Option<String>>>();

        // the first row is the data table header
        if self.0.header.is_empty() {
            self.0.header = fields;
            return;
        }

        // ensure `datatable` has the same length of `fields`
        if let Some(num_added) = fields.len().checked_sub(self.0.datatable.len()) {
            if num_added > 0 {
                let num_fill: usize = if self.0.datatable.len() > 0 {
                    unsafe { self.0.datatable.get_unchecked(0) }.len()
                } else {
                    0
                };
                self.0.datatable.reserve(num_added);
                if num_fill > 0 {
                    for _ in 0..num_added {
                        self.0.datatable.push(vec![None; num_fill]);
                    }
                } else {
                    for _ in 0..num_added {
                        self.0.datatable.push(Vec::with_capacity(4));
                    }
                }
            }
        }
        // SAFETY: we have ensured has the same length of fields
        for (i, field) in fields.into_iter().enumerate() {
            unsafe { self.0.datatable.get_unchecked_mut(i) }.push(field);
        }
    }
}

#[inline]
fn strip_quotes(bytes: &[u8]) -> &[u8] {
    // strip double quotes or single quotes
    bytes
        .strip_prefix(b"\"")
        .and_then(|f| f.strip_suffix(b"\""))
        .unwrap_or_else(|| {
            bytes
                .strip_prefix(b"'")
                .and_then(|f| f.strip_suffix(b"'"))
                .unwrap_or_else(|| bytes)
        })
}

// Try to produce a String from bytes cheaply for valid UTF-8, fall back to lossless conversion.
// This avoids the cost of allocating via from_utf8_lossy when bytes are already valid UTF-8.
#[inline]
fn bytes_to_string(bytes: &[u8]) -> String {
    match std::str::from_utf8(bytes) {
        Ok(s) => s.to_owned(),
        Err(_) => String::from_utf8_lossy(bytes).into_owned(),
    }
}
