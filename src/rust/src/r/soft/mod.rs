use std::fs::File;
use std::io::{self, BufRead, BufReader, Read};
use std::path::Path;

use anyhow::Result;
use hashbrown::HashSet;
use memchr::memchr;

mod parser;

use parser::GEOSoftParser;
pub use parser::GEOSoftRecord;

/// A reader for parsing SOFT (Simple Omnibus Format in Text) files.
pub struct GEOSoftReader<R> {
    reader: R,             // Underlying buffered reader
    parser: GEOSoftParser, // The parser that interprets the SOFT data
    leftover: Vec<u8>,
    /// The current position of the reader.
    ///
    /// Note that this position is only observable by callers at the start
    /// of a record. More granular positions are not supported.
    cur_pos: usize,
}

// Methods for all instances of GEOSoftReader<T>
impl<T> GEOSoftReader<T> {
    /// Create a new SOFT reader given a builder and a source of underlying
    /// bytes.
    pub fn new<R: Read>(config: &GEOSoftConfig, reader: R) -> GEOSoftReader<BufReader<R>> {
        Self::from_bufreader_impl(config, BufReader::with_capacity(config.capacity(), reader))
    }

    /// Creates a new `GEOSoftReader` given a reader and a default buffer capacity.
    ///
    /// # Arguments
    /// - `reader`: The reader that provides the input data for parsing.
    ///
    /// # Returns
    /// - A `GEOSoftReader` with the provided reader.
    pub fn from_reader<R: Read>(reader: R) -> GEOSoftReader<BufReader<R>> {
        Self::new(&GEOSoftConfig::new(), reader)
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
        let mut config = GEOSoftConfig::new();
        config.set_capacity(capacity);
        Self::new(&config, reader)
    }

    /// Create a new SOFT reader given a builder and a source of underlying
    /// bytes.
    pub fn from_bufreader<R: BufRead>(reader: R) -> GEOSoftReader<R> {
        Self::from_bufreader_impl(&GEOSoftConfig::new(), reader)
    }

    fn from_bufreader_impl<R: BufRead>(config: &GEOSoftConfig, reader: R) -> GEOSoftReader<R> {
        GEOSoftReader {
            reader: reader,
            parser: GEOSoftParser::new(config),
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
                    return Ok(self.parser.take_record());
                } else {
                    let line = &self.leftover;
                    self.parser.parse_line(line);
                    self.cur_pos += 1;
                    self.leftover.clear();
                    return Ok(self.parser.take_record());
                }
            }

            // check if we need step into next record
            // SAFETY: input_bytes is not empty
            if unsafe { input_bytes.get_unchecked(0) } == &b'^' && !self.parser.empty() {
                return Ok(self.parser.take_record());
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
                self.parser.parse_line(line);
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

// Try to produce a String from bytes cheaply for valid UTF-8, fall back to lossless conversion.
// This avoids the cost of allocating via from_utf8_lossy when bytes are already valid UTF-8.
#[inline]
fn bytes_to_string(bytes: &[u8]) -> String {
    match std::str::from_utf8(bytes) {
        Ok(s) => s.to_owned(),
        Err(_) => String::from_utf8_lossy(bytes).into_owned(),
    }
}

impl<R: io::BufRead> Iterator for GEOSoftReader<R> {
    type Item = Result<GEOSoftRecord>;
    fn next(&mut self) -> Option<Self::Item> {
        self.read_record().transpose()
    }
}

pub struct GEOSoftConfig {
    capacity: Option<usize>,
    format: Option<GEOSoftFormat>,
    use_lines: Option<HashSet<GEOSoftLine>>,
}

impl GEOSoftConfig {
    pub fn new() -> Self {
        Self {
            capacity: None,
            format: None,
            use_lines: None,
        }
    }

    pub fn set_capacity(&mut self, capacity: usize) {
        self.capacity = Some(capacity);
    }

    pub fn set_format(&mut self, format: GEOSoftFormat) {
        self.format = Some(format);
    }

    pub fn set_lines(&mut self, lines: HashSet<GEOSoftLine>) {
        self.use_lines = Some(lines);
    }

    pub fn capacity(&self) -> usize {
        self.capacity.unwrap_or_else(|| 4 * (1 << 20))
    }

    pub fn format(&self) -> GEOSoftFormat {
        self.format
            .as_ref()
            .map_or_else(|| GEOSoftFormat::Standard, |f| f.clone())
    }

    pub fn use_lines(&self) -> HashSet<GEOSoftLine> {
        self.use_lines.as_ref().map_or_else(
            || {
                let mut uses = HashSet::with_capacity(2);
                uses.insert(GEOSoftLine::Metadata);
                uses.insert(GEOSoftLine::Datatable);
                uses
            },
            |u| u.clone(),
        )
    }
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
