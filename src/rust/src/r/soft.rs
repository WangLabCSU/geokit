use std::fs::File;
use std::io::{self, BufRead, BufReader};
use std::path::Path;

use anyhow::{Context, Result};
use extendr_api::{Attributes, Length};

#[cfg(feature = "flate2")]
use flate2::bufread::GzDecoder as GzipDecoder;

#[cfg(not(feature = "flate2"))]
use isal::read::GzipDecoder;

use indexmap::IndexMap;
use memchr::memchr;

/// Represents a record in the SOFT (Simple Omnibus Format in Text) file.
///
/// This structure holds the parsed data for a single record. It includes:
/// - `rcd_type`: The type of the record (e.g., Platform, Sample, Series, Datasets).
/// - `rcd_name`: The name associated with the record (e.g., the GEO dataset name).
/// - `metadata`: A HashMap holding the attributes of the record (key-value pairs).
/// - `columns`: A Vector describing the columns of the data table (header name and description).
/// - `datatable`: A data frame (Vec of Vecs) holding the actual data for the record (rows and columns).
#[derive(Debug, Clone)]
pub struct GEOSoftRecord {
    rcd_type: String, // Type of the GEO record (e.g., Series, Platform)
    rcd_name: String, // Name of the record
    metadata: IndexMap<String, Vec<Option<String>>>, // Attributes of the record (key-value pairs)
    columns: Vec<(String, Option<String>)>, // Header names and descriptions
    header: Vec<Option<String>>, // Header
    datatable: Vec<Vec<Option<String>>>, // Data table (a data frame)
}

pub enum GEOSoftFormat {
    Standard,
    Matrix,
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
    fn parse_line(&mut self, line: &[u8], format: &GEOSoftFormat) -> Result<()> {
        // ignore empty lines
        if line.is_empty() || line.iter().all(|byte| byte.is_ascii_whitespace()) {
            return Ok(());
        }
        match unsafe { line.get_unchecked(0) } {
            b'^' => self
                .parse_caret(line)
                .with_context(|| format!("Invalid caret line"))?,
            b'!' => {
                let result = match format {
                    GEOSoftFormat::Standard => self.parse_regular_bang(line),
                    GEOSoftFormat::Matrix => self.parse_matrix_bang(line),
                };
                result.with_context(|| format!("Invalid bang line"))?;
            }
            b'#' => self
                .parse_hash(line)
                .with_context(|| format!("Invalid hash line"))?,
            _ => self
                .parse_data(line)
                .with_context(|| format!("Invalid data table line"))?,
        }
        Ok(())
    }

    #[inline]
    fn parse_caret(&mut self, line: &[u8]) -> Result<()> {
        let prefix = if let Some(pos) = memchr(b'=', line) {
            let prefix = unsafe { line.get_unchecked(1..pos) };
            if pos + 1 < line.len() {
                let rcd_name =
                    str::from_utf8(unsafe { line.get_unchecked(pos + 1..) }.trim_ascii())?;
                self.rcd_name.push_str(rcd_name);
            }
            prefix
        } else {
            unsafe { line.get_unchecked(1..) }
        };
        self.rcd_type = String::from_utf8(prefix.trim_ascii_end().to_vec())?;
        Ok(())
    }

    #[inline]
    fn parse_regular_bang(&mut self, line: &[u8]) -> Result<()> {
        // for normal SOFT file, the metadata is seprated with `=`
        if let Some(pos) = memchr(b'=', line) {
            if pos + 1 < line.len() {
                let label = str::from_utf8(unsafe { line.get_unchecked(1..pos) }.trim_ascii_end())?;
                let value = str::from_utf8(unsafe { line.get_unchecked(pos + 1..) }.trim_ascii())?;
                if let Some(metadata) = self.metadata.get_mut(label) {
                    metadata.push(Some(value.to_string()));
                } else {
                    self.metadata
                        .insert(label.to_owned(), vec![Some(value.to_string())]);
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
                let label = str::from_utf8(unsafe { line.get_unchecked(1..pos) }.trim_ascii_end())?;
                let fields = unsafe { line.get_unchecked(pos + 1..)}
                    .split(|byte| *byte == b'\t')
                    .map(|field| {
                        let field = strip_quotes(field.trim_ascii());
                        if field.is_empty()
                            || matches!(field.to_ascii_lowercase().as_slice(), b"null" | b"na")
                        {
                            Ok(None)
                        } else {
                            String::from_utf8(field.to_vec()).map(|s| Some(s))
                        }
                    })
                    .collect::<std::result::Result<Vec<Option<String>>, std::string::FromUtf8Error>>()?;
                // Check if the label already exists and add a suffix to ensure uniqueness
                let mut owned_label = label.to_owned();
                let mut suffix = 1;
                while self.metadata.contains_key(&owned_label) {
                    owned_label = format!("{}_{}", label, suffix);
                    suffix += 1;
                }
                self.metadata.insert(owned_label, fields);
            }
        }
        Ok(())
    }

    #[inline]
    fn parse_hash(&mut self, line: &[u8]) -> Result<()> {
        if let Some(pos) = memchr(b'=', line) {
            let label = str::from_utf8(unsafe { line.get_unchecked(1..pos) }.trim_ascii_end())?;
            let value = if pos + 1 < line.len() {
                str::from_utf8(unsafe { line.get_unchecked(pos + 1..) }.trim_ascii())?
            } else {
                ""
            };
            if value.is_empty() {
                self.columns.push((label.to_owned(), None));
            } else {
                self.columns
                    .push((label.to_owned(), Some(value.to_owned())));
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
                    || matches!(field.to_ascii_lowercase().as_slice(), b"null" | b"na")
                {
                    Ok(None)
                } else {
                    String::from_utf8(field.to_vec()).map(|s| Some(s))
                }
            })
            .collect::<std::result::Result<Vec<Option<String>>, std::string::FromUtf8Error>>()?;

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

impl TryFrom<GEOSoftRecord> for extendr_api::List {
    type Error = extendr_api::Error;

    fn try_from(value: GEOSoftRecord) -> std::result::Result<Self, Self::Error> {
        let (metadata_keys, metadata_values): (Vec<_>, Vec<_>) = value
            .metadata
            .into_iter()
            .map(|(key, value)| (key, extendr_api::Robj::from(value)))
            .unzip();
        let mut metadata = extendr_api::List::from_values(metadata_values);
        metadata.set_names(metadata_keys)?;

        let (columns_names, columns_values): (Vec<String>, Vec<Option<String>>) =
            value.columns.into_iter().unzip();
        let mut columns = extendr_api::Robj::from(columns_values);
        columns.set_names(columns_names)?;

        let header = extendr_api::Robj::from(value.header);
        let mut datatable = Vec::with_capacity(header.len());
        for field in value.datatable.into_iter() {
            datatable.push(super::helper::parse_string(field));
        }
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

/// A reader for parsing SOFT (Simple Omnibus Format in Text) files.
pub struct GEOSoftReader<R> {
    reader: BufReader<R>, // Underlying buffered reader
    format: GEOSoftFormat,
    record: GEOSoftRecord, // The parser that interprets the SOFT data
    reuse_buffer: bool,    // Flag to indicate whether to reuse the parser
    leftover: Vec<u8>,
    /// The current position of the reader.
    ///
    /// Note that this position is only observable by callers at the start
    /// of a record. More granular positions are not supported.
    cur_pos: usize,
}

impl GEOSoftReader<File> {
    /// Creates a new `GEOSoftReader` with a default configuration for reading a file.
    ///
    /// # Arguments
    /// - `path`: The file path of the SOFT file to be parsed.
    ///
    /// # Returns
    /// - A `GEOSoftReader` that reads from the file at the given path.
    pub fn from_path<P: AsRef<Path>>(path: P) -> io::Result<GEOSoftReader<File>> {
        let file = File::open(path)?;
        Ok(Self::new(file))
    }
}

impl<R: io::Read> GEOSoftReader<R> {
    /// Creates a new `GEOSoftReader` given a reader and a default buffer capacity.
    ///
    /// # Arguments
    /// - `reader`: The reader that provides the input data for parsing.
    ///
    /// # Returns
    /// - A `GEOSoftReader` with the provided reader.
    pub fn new(reader: R) -> GEOSoftReader<R> {
        Self::with_capacity(4 * (1 << 20), reader)
    }

    /// Consumes the current `GEOSoftReader` and creates a new one that reads from a gzip-compressed stream.
    ///
    /// # Returns
    /// - A `GEOSoftReader` that reads from a gzip-compressed input stream.
    pub fn into_gzip_reader(self) -> GEOSoftReader<GzipDecoder<BufReader<R>>> {
        let buffer_size = self.reader.capacity();
        self.into_gzip_reader_with_buffer_size(buffer_size)
    }

    /// Consumes the current `GEOSoftReader` and creates a new one that reads from a gzip-compressed stream.
    ///
    /// # Arguments
    /// - `buffer_size`: The size of the buffer for reading the compressed stream.
    ///
    /// # Returns
    /// - A `GEOSoftReader` that reads from a gzip-compressed input stream with the given buffer size.
    pub fn into_gzip_reader_with_buffer_size(
        self,
        buffer_size: usize,
    ) -> GEOSoftReader<GzipDecoder<BufReader<R>>> {
        GEOSoftReader {
            reader: BufReader::with_capacity(buffer_size, GzipDecoder::new(self.reader)),
            format: self.format,
            record: self.record,
            reuse_buffer: self.reuse_buffer,
            leftover: self.leftover,
            cur_pos: self.cur_pos,
        }
    }

    /// Creates a new `GEOSoftReader` with a specific buffer capacity.
    ///
    /// # Arguments
    /// - `capacity`: The size of the buffer for the underlying reader.
    /// - `reader`: The reader that provides the input data for parsing.
    ///
    /// # Returns
    /// - A `GEOSoftReader` with the given capacity and reader.
    pub fn with_capacity(capacity: usize, reader: R) -> GEOSoftReader<R> {
        Self {
            reader: BufReader::with_capacity(capacity, reader),
            format: GEOSoftFormat::Standard,
            record: GEOSoftRecord::new(),
            reuse_buffer: false,
            leftover: Vec::new(),
            cur_pos: 1,
        }
    }

    pub fn format(&mut self, format: GEOSoftFormat) {
        self.format = format;
    }

    /// Sets whether the parser state should be reused when reading new records.
    ///
    /// # Arguments
    /// - `reuse`: If `false`, a new parser will be created for each new record.
    pub fn reuse_buffer(&mut self, reuse: bool) {
        self.reuse_buffer = reuse;
    }

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
                    return Ok(self.build_record());
                } else {
                    let line = &self.leftover;
                    self.record
                        .parse_line(line, &self.format)
                        .with_context(|| {
                            format!(
                                "Error parsing line ({}): '{}'.",
                                self.cur_pos,
                                String::from_utf8_lossy(line)
                            )
                        })?;
                    self.cur_pos += 1;
                    self.leftover.clear();
                    return Ok(self.build_record());
                }
            }

            // check if we need step into next record
            // SAFETY: input_bytes is not empty
            if unsafe { input_bytes.get_unchecked(0) } == &b'^' && !self.record.empty() {
                return Ok(self.build_record());
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
                self.record
                    .parse_line(line, &self.format)
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

    fn build_record(&mut self) -> Option<GEOSoftRecord> {
        if self.record.empty() {
            return None;
        }
        if self.reuse_buffer {
            let record = self.record.clone();
            self.record.clear();
            Some(record)
        } else {
            Some(std::mem::replace(&mut self.record, GEOSoftRecord::new()))
        }
    }

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

impl<R: io::Read> Iterator for GEOSoftReader<R> {
    type Item = Result<GEOSoftRecord>;
    fn next(&mut self) -> Option<Self::Item> {
        self.read_record().transpose()
    }
}
