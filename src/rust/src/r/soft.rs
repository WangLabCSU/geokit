use std::fs::File;
use std::io::{self, BufRead, BufReader, Read};
use std::path::Path;

use anyhow::{Context, Result};
use extendr_api::{Attributes, List, Robj};
use hashbrown::HashSet;
use indexmap::IndexMap;
use memchr::memchr;

use super::vector::OpaqueVector;

/// A reader for parsing SOFT (Simple Omnibus Format in Text) files.
pub struct GEOSoftReader<R> {
    reader: R, // Underlying buffered reader
    format: GEOSoftFormat,
    use_lines: HashSet<GEOSoftLine>,
    parser: GEOSoftParser, // The parser that interprets the SOFT data
    leftover: Vec<u8>,
    /// The current position of the reader.
    ///
    /// Note that this position is only observable by callers at the start
    /// of a record. More granular positions are not supported.
    cur_pos: usize,
}

#[derive(Debug, Clone)]
pub enum GEOSoftFormat {
    Standard,
    Matrix,
}

#[derive(Eq, Hash, PartialEq, Debug, Clone)]
#[allow(dead_code)]
pub enum GEOSoftLine {
    Entity,
    Metadata,
    Datatable,
}

// Methods for all instances of GEOSoftReader<T>
impl<T> GEOSoftReader<T> {
    /// Create a new SOFT reader given a builder and a source of underlying
    /// bytes.
    pub fn new<R: Read>(builder: &GEOSoftReaderBuilder, reader: R) -> GEOSoftReader<BufReader<R>> {
        Self::from_bufreader_impl(
            builder,
            BufReader::with_capacity(builder.capacity.unwrap_or_else(|| 4 * (1 << 20)), reader),
        )
    }

    /// Creates a new `GEOSoftReader` given a reader and a default buffer capacity.
    ///
    /// # Arguments
    /// - `reader`: The reader that provides the input data for parsing.
    ///
    /// # Returns
    /// - A `GEOSoftReader` with the provided reader.
    pub fn from_reader<R: Read>(reader: R) -> GEOSoftReader<BufReader<R>> {
        Self::new(&GEOSoftReaderBuilder::new(), reader)
    }

    /// Creates a new `GEOSoftReader` with a specific buffer capacity.
    ///
    /// # Arguments
    /// - `capacity`: The size of the buffer for the underlying reader.
    /// - `reader`: The reader that provides the input data for parsing.
    ///
    /// # Returns
    /// - A `GEOSoftReader` with the given capacity and reader.
    pub fn with_capacity<R: Read>(capacity: usize, reader: R) -> GEOSoftReader<BufReader<R>> {
        Self::new(GEOSoftReaderBuilder::new().capacity(capacity), reader)
    }

    /// Create a new SOFT reader given a builder and a source of underlying
    /// bytes.
    pub fn from_bufreader<R: BufRead>(reader: R) -> GEOSoftReader<R> {
        Self::from_bufreader_impl(&GEOSoftReaderBuilder::new(), reader)
    }

    fn from_bufreader_impl<R: BufRead>(
        builder: &GEOSoftReaderBuilder,
        reader: R,
    ) -> GEOSoftReader<R> {
        GEOSoftReader {
            reader: reader,
            format: builder
                .format
                .as_ref()
                .map_or_else(|| GEOSoftFormat::Standard, |f| f.clone()),
            use_lines: builder.use_lines.as_ref().map_or_else(
                || {
                    let mut uses = HashSet::with_capacity(2);
                    uses.insert(GEOSoftLine::Metadata);
                    uses.insert(GEOSoftLine::Datatable);
                    uses
                },
                |u| u.clone(),
            ),
            parser: GEOSoftParser::new(),
            leftover: Vec::new(),
            cur_pos: 1,
        }
    }

    /// Creates a new `GEOSoftReader` with a default configuration for reading a file.
    ///
    /// # Arguments
    /// - `path`: The file path of the SOFT file to be parsed.
    ///
    /// # Returns
    /// - A `GEOSoftReader` that reads from the file at the given path.
    pub fn from_path<P: AsRef<Path>>(path: P) -> io::Result<GEOSoftReader<BufReader<File>>> {
        Ok(Self::from_reader(File::open(path)?))
    }
}

impl<R: io::Read> GEOSoftReader<BufReader<R>> {
    /// Returns a reference to the underlying reader.
    #[allow(dead_code)]
    pub fn capacity(&self) -> usize {
        self.reader.capacity()
    }

    /// Returns a reference to the underlying reader.
    #[allow(dead_code)]
    pub fn get_ref(&self) -> &R {
        self.reader.get_ref()
    }

    /// Returns a mutable reference to the underlying reader.
    #[allow(dead_code)]
    pub fn get_mut(&mut self) -> &mut R {
        self.reader.get_mut()
    }

    /// Unwraps this CSV reader, returning the underlying reader.
    ///
    /// Note that any leftover data inside this reader's internal buffer is
    /// lost.
    #[allow(dead_code)]
    pub fn into_inner(self) -> R {
        self.reader.into_inner()
    }
}

impl<R: io::BufRead> GEOSoftReader<R> {
    /// Reads and parses the record from the underlying reader.
    ///
    /// # Returns
    /// - `Some(GEOSoftRecord)` if a record is parsed.
    /// - `None` if the end of the file is reached.
    pub fn read_record(&mut self) -> Result<Option<GEOSoftRecord>> {
        loop {
            let input_bytes = self.reader.fill_buf()?;
            if input_bytes.is_empty() {
                if self.leftover.is_empty() {
                    let record = self.parser.record();
                    self.parser.clear();
                    return Ok(record);
                } else {
                    let line = &self.leftover;
                    self.parser
                        .parse_line(line, &self.format, &self.use_lines)
                        .with_context(|| {
                            format!(
                                "Error parsing line ({}): '{}'.",
                                self.cur_pos,
                                String::from_utf8_lossy(line)
                            )
                        })?;
                    self.cur_pos += 1;
                    self.leftover.clear();
                    let record = self.parser.record();
                    self.parser.clear();
                    return Ok(record);
                }
            }

            // check if we need step into next record
            // SAFETY: input_bytes is not empty
            if unsafe { input_bytes.get_unchecked(0) } == &b'^' && !self.parser.empty() {
                let record = self.parser.record();
                self.parser.clear();
                return Ok(record);
            }

            // get a single line and parse it
            if let Some(pos) = memchr(b'\n', input_bytes) {
                let end = if let Some(r) = pos.checked_sub(1) {
                    // SAFETY: r < pos
                    if unsafe { *input_bytes.get_unchecked(r) } == b'\r' {
                        r // Handle CRLF line endings
                    } else {
                        pos
                    }
                } else {
                    pos
                };
                let line = if self.leftover.is_empty() {
                    &input_bytes[..end]
                } else {
                    self.leftover.extend_from_slice(&input_bytes[..end]);
                    &self.leftover
                };
                self.parser
                    .parse_line(line, &self.format, &self.use_lines)
                    .with_context(|| {
                        format!(
                            "Error parsing line ({}): '{}'.",
                            self.cur_pos,
                            String::from_utf8_lossy(line)
                        )
                    })?;
                self.cur_pos += 1;
                self.leftover.clear();
                self.reader.consume(pos + 1); // Don't include the final '\n'
            } else {
                self.leftover.extend_from_slice(input_bytes);
                let consume = input_bytes.len();
                self.reader.consume(consume);
            };
        }
    }
}

impl<R: io::BufRead> Iterator for GEOSoftReader<R> {
    type Item = Result<GEOSoftRecord>;
    fn next(&mut self) -> Option<Self::Item> {
        self.read_record().transpose()
    }
}

pub struct GEOSoftReaderBuilder {
    capacity: Option<usize>,
    format: Option<GEOSoftFormat>,
    use_lines: Option<HashSet<GEOSoftLine>>,
}

impl GEOSoftReaderBuilder {
    pub fn new() -> Self {
        Self {
            capacity: None,
            format: None,
            use_lines: None,
        }
    }

    pub fn capacity(&mut self, capacity: usize) -> &mut Self {
        self.capacity = Some(capacity);
        self
    }

    pub fn format(&mut self, format: GEOSoftFormat) -> &mut Self {
        self.format = Some(format);
        self
    }

    pub fn use_lines(&mut self, lines: HashSet<GEOSoftLine>) -> &mut Self {
        self.use_lines = Some(lines);
        self
    }
}

/// Represents a record in the SOFT (Simple Omnibus Format in Text) file.
///
/// This structure holds the parsed data for a single record. It includes:
/// - `rcd_type`: The type of the record (e.g., Platform, Sample, Series, Datasets).
/// - `rcd_name`: The name associated with the record (e.g., the GEO dataset name).
/// - `metadata`: A HashMap holding the attributes of the record (key-value pairs).
/// - `columns`: A Vector describing the columns of the data table (header name and description).
/// - `datatable`: A data frame (Vec of Vecs) holding the actual data for the record (rows and columns).
#[derive(Debug, Clone)]
struct GEOSoftParser {
    rcd_type: String, // Type of the GEO record (e.g., Series, Platform)
    rcd_name: String, // Name of the record
    metadata: IndexMap<String, Vec<Option<String>>>, // Attributes of the record (key-value pairs)
    columns: Vec<(String, Option<String>)>, // Header names and descriptions
    header: Vec<Option<String>>, // Header
    datatable: Vec<Vec<Option<String>>>, // Data table (a data frame)
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
impl GEOSoftParser {
    #[inline]
    fn new() -> Self {
        Self {
            rcd_type: String::new(),
            rcd_name: String::new(),
            metadata: IndexMap::new(),
            columns: Vec::new(),
            header: Vec::new(),
            datatable: Vec::new(),
        }
    }

    #[inline]
    fn clear(&mut self) {
        self.rcd_type.clear();
        self.rcd_name.clear();
        self.metadata.clear();
        self.columns.clear();
        self.header.clear();
        self.datatable.clear();
    }

    #[inline]
    fn empty(&self) -> bool {
        self.rcd_type.is_empty()
            && self.rcd_name.is_empty()
            && self.metadata.is_empty()
            && self.columns.is_empty()
            && self.header.is_empty()
            && self.datatable.is_empty()
    }

    #[inline]
    fn record(&self) -> Option<GEOSoftRecord> {
        if self.empty() {
            return None;
        }
        let mut datatable = Vec::with_capacity(self.datatable.len());
        for field in self.datatable.iter() {
            datatable.push(OpaqueVector::parse_string(field.clone()));
        }
        Some(GEOSoftRecord {
            rcd_type: self.rcd_type.clone(),
            rcd_name: self.rcd_name.clone(),
            metadata: self.metadata.clone(),
            columns: self.columns.clone(),
            header: self.header.clone(),
            datatable: datatable,
        })
    }

    #[inline]
    fn parse_line(
        &mut self,
        line: &[u8],
        format: &GEOSoftFormat,
        uses: &HashSet<GEOSoftLine>,
    ) -> Result<()> {
        // ignore empty lines
        if line.is_empty() || line.iter().all(|byte| byte.is_ascii_whitespace()) {
            return Ok(());
        }
        match unsafe { line.get_unchecked(0) } {
            b'^' => self
                .parse_caret(line)
                .with_context(|| format!("Invalid caret line"))?,
            b'!' => {
                if uses.contains(&GEOSoftLine::Metadata) {
                    let result = match format {
                        GEOSoftFormat::Standard => self.parse_regular_bang(line),
                        GEOSoftFormat::Matrix => self.parse_matrix_bang(line),
                    };
                    result.with_context(|| format!("Invalid bang line"))?;
                }
            }
            b'#' => {
                if uses.contains(&GEOSoftLine::Datatable) {
                    self.parse_hash(line)
                        .with_context(|| format!("Invalid hash line"))?
                }
            }
            _ => {
                if uses.contains(&GEOSoftLine::Datatable) {
                    self.parse_data(line)
                        .with_context(|| format!("Invalid data table line"))?
                }
            }
        }
        Ok(())
    }

    #[inline]
    fn parse_caret(&mut self, line: &[u8]) -> Result<()> {
        let prefix = if let Some(pos) = memchr(b'=', line) {
            // SAFETY: we have ensure the line starts with '^'
            let prefix = unsafe { line.get_unchecked(1..pos) };
            if pos + 1 < line.len() {
                let rcd_name =
                    String::from_utf8_lossy(unsafe { line.get_unchecked(pos + 1..) }.trim_ascii())
                        .to_string();
                self.rcd_name = rcd_name;
            }
            prefix
        } else {
            unsafe { line.get_unchecked(1..) }
        };
        self.rcd_type = String::from_utf8_lossy(prefix.trim_ascii_end()).to_string();
        Ok(())
    }

    #[inline]
    fn parse_regular_bang(&mut self, line: &[u8]) -> Result<()> {
        // for normal SOFT file, the metadata is seprated with `=`
        if let Some(pos) = memchr(b'=', line) {
            if pos + 1 < line.len() {
                // SAFETY: we have ensure the line starts with '!'
                let label =
                    String::from_utf8_lossy(unsafe { line.get_unchecked(1..pos) }.trim_ascii_end())
                        .to_string();
                // SAFETY: we have ensured 'pos + 1' doesn't span the ending
                let value =
                    String::from_utf8_lossy(unsafe { line.get_unchecked(pos + 1..) }.trim_ascii())
                        .to_string();
                if let Some(metadata) = self.metadata.get_mut(&label) {
                    metadata.push(Some(value));
                } else {
                    self.metadata.insert(label.to_owned(), vec![Some(value)]);
                }
            }
        }
        Ok(())
    }

    #[inline]
    fn parse_matrix_bang(&mut self, line: &[u8]) -> Result<()> {
        // for GSE matrix, the metadata is seprated with `\t`
        if let Some(pos) = memchr(b'\t', line) {
            if pos + 1 < line.len() {
                // SAFETY: we have ensure the line starts with '!'
                let label =
                    String::from_utf8_lossy(unsafe { line.get_unchecked(1..pos) }.trim_ascii_end())
                        .to_string();
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
                            Some(String::from_utf8_lossy(field).to_string())
                        }
                    })
                    .collect::<Vec<Option<String>>>();
                // Check if the label already exists and add a suffix to ensure uniqueness
                let mut suffix = 1;
                let mut label_check = label.clone();
                while self.metadata.contains_key(&label_check) {
                    label_check = format!("{}_{}", label, suffix);
                    suffix += 1;
                }
                self.metadata.insert(label_check, fields);
            }
        }
        Ok(())
    }

    #[inline]
    fn parse_hash(&mut self, line: &[u8]) -> Result<()> {
        // SAFETY: we have ensure the line starts with '#'
        if let Some(pos) = memchr(b'=', line) {
            let label =
                String::from_utf8_lossy(unsafe { line.get_unchecked(1..pos) }.trim_ascii_end())
                    .to_string();
            let value = if pos + 1 < line.len() {
                String::from_utf8_lossy(unsafe { line.get_unchecked(pos + 1..) }.trim_ascii())
                    .to_string()
            } else {
                String::new()
            };
            if value.is_empty() {
                self.columns.push((label, None));
            } else {
                self.columns.push((label, Some(value)));
            }
        }
        Ok(())
    }

    #[inline]
    fn parse_data(&mut self, line: &[u8]) -> Result<()> {
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
                    Some(String::from_utf8_lossy(field).to_string())
                }
            })
            .collect::<Vec<Option<String>>>();

        // the first row is the header
        if self.header.is_empty() {
            self.header = fields;
            return Ok(());
        }

        // ensure `datatable` has the same length of `fields`
        if let Some(num_added) = fields.len().checked_sub(self.datatable.len()) {
            if num_added > 0 {
                let num_fill: usize = if self.datatable.len() > 0 {
                    unsafe { self.datatable.get_unchecked(0) }.len()
                } else {
                    0
                };
                self.datatable.reserve(num_added);
                if num_fill > 0 {
                    for _ in 0..num_added {
                        self.datatable.push(vec![None; num_fill]);
                    }
                } else {
                    for _ in 0..num_added {
                        self.datatable.push(Vec::with_capacity(4));
                    }
                }
            }
        }
        // SAFETY: we have ensured has the same length of fields
        for (i, field) in fields.into_iter().enumerate() {
            unsafe { self.datatable.get_unchecked_mut(i) }.push(field);
        }
        Ok(())
    }
}

fn strip_quotes(bytes: &[u8]) -> &[u8] {
    if let Some(bytes) = bytes
        .strip_prefix(b"\"")
        .and_then(|f| f.strip_suffix(b"\""))
    {
        bytes
    } else {
        bytes
            .strip_prefix(b"'")
            .and_then(|f| f.strip_suffix(b"'"))
            .unwrap_or(bytes)
    }
}

pub struct GEOSoftRecord {
    rcd_type: String, // Type of the GEO record (e.g., Series, Platform)
    rcd_name: String, // Name of the record
    metadata: IndexMap<String, Vec<Option<String>>>, // Attributes of the record (key-value pairs)
    columns: Vec<(String, Option<String>)>, // Header names and descriptions
    header: Vec<Option<String>>, // Header
    datatable: Vec<OpaqueVector>, // Data table (a data frame)
}

impl TryFrom<GEOSoftRecord> for extendr_api::List {
    type Error = extendr_api::Error;

    fn try_from(value: GEOSoftRecord) -> std::result::Result<Self, Self::Error> {
        let (metadata_keys, metadata_values): (Vec<_>, Vec<_>) = value.metadata.into_iter().unzip();
        let mut metadata = extendr_api::List::from_values(metadata_values);
        metadata.set_names(metadata_keys)?;

        let (columns_names, columns_values): (Vec<String>, Vec<Option<String>>) =
            value.columns.into_iter().unzip();
        let mut columns = extendr_api::Robj::from(columns_values);
        columns.set_names(columns_names)?;

        let header = extendr_api::Robj::from(value.header);
        let datatable = value
            .datatable
            .into_iter()
            .map(|v| Robj::from(v))
            .collect::<List>();
        let record = extendr_api::list![
            rcd_type = value.rcd_type,
            rcd_name = value.rcd_name,
            metadata = metadata,
            columns = columns,
            header = header,
            datatable = datatable
        ];
        Ok(record)
    }
}

impl TryFrom<GEOSoftRecord> for extendr_api::Robj {
    type Error = extendr_api::Error;

    fn try_from(value: GEOSoftRecord) -> std::result::Result<Self, Self::Error> {
        extendr_api::List::try_from(value).map(|ok| ok.into())
    }
}
