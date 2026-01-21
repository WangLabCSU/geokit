use std::fs::File;
use std::io::{self, BufRead, Read};
use std::path::Path;

use hashbrown::HashSet;
use memchr::memchr;

mod parser;
mod record;

pub use parser::{GEOSoftFormat, GEOSoftLine};
pub use record::GEOSoftRecord;

use parser::{GEOSoftParser, GEOSoftParserBuilder};

#[derive(Debug, Clone, Default)]
pub struct GEOSoftReaderBuilder {
    capacity: Option<usize>,
    parser: GEOSoftParserBuilder,
}

impl GEOSoftReaderBuilder {
    #[inline]
    pub fn new() -> Self {
        Self::default()
    }

    #[inline]
    pub fn capacity(&mut self, capacity: usize) -> &mut Self {
        self.capacity = Some(capacity);
        self
    }

    #[inline]
    pub fn format(&mut self, format: GEOSoftFormat) -> &mut Self {
        self.parser.format(format);
        self
    }

    #[inline]
    pub fn use_lines(&mut self, lines: HashSet<GEOSoftLine>) -> &mut Self {
        self.parser.use_lines(lines);
        self
    }

    /// Creates a new `GEOSoftReader` with a default configuration and the provided reader.
    ///
    /// This method uses the default configuration (`GEOSoftParser::new()`).
    ///
    /// # Arguments
    /// - `reader`: The reader that provides the input data for parsing.
    ///
    /// # Returns
    /// - A `GEOSoftReader` initialized with the provided reader and the default configuration.
    #[inline]
    #[allow(dead_code)]
    pub fn build_from_reader<R: Read>(&self, reader: R) -> GEOSoftReader<R> {
        let capacity = self.capacity.unwrap_or(4 * (1 << 20));
        let parser = self.parser.build();
        GEOSoftReader {
            reader: io::BufReader::with_capacity(capacity, reader),
            parser,
            leftover: Vec::new(),
            cur_pos: 1,
        }
    }

    /// Creates a new `GEOSoftReader` that reads from a file at the specified path.
    ///
    /// # Arguments
    /// - `path`: The file path of the SOFT file to be parsed.
    ///
    /// # Returns
    /// - A `GEOSoftReader` that reads from the file at the given path.
    /// - Returns an `io::Result` to handle any potential I/O errors during file opening.
    #[inline]
    #[allow(dead_code)]
    pub fn build_from_path<P: AsRef<Path>>(&self, path: P) -> io::Result<GEOSoftReader<File>> {
        Ok(self.build_from_reader(File::open(path)?))
    }
}

/// A reader for parsing SOFT (Simple Omnibus Format in Text) files.
#[derive(Debug)]
pub struct GEOSoftReader<R: ?Sized> {
    parser: GEOSoftParser, // The parser that interprets the SOFT data
    leftover: Vec<u8>,
    /// The current position of the reader.
    ///
    /// Note that this position is only observable by callers at the start
    /// of a record. More granular positions are not supported.
    cur_pos: usize,
    reader: io::BufReader<R>, // Underlying buffered reader
}

// Methods for all instances of GEOSoftReader<T>
impl<T> GEOSoftReader<T> {
    #[inline]
    pub fn builder() -> GEOSoftReaderBuilder {
        GEOSoftReaderBuilder::new()
    }

    /// Creates a new `GEOSoftReader` with a specified configuration and an underlying reader.
    ///
    /// This method initializes the reader with a default buffer capacity of 4MB.
    ///
    /// # Arguments
    /// - `reader`: The source of bytes for reading and parsing the SOFT data.
    ///
    /// # Returns
    /// - A `GEOSoftReader` with the specified configuration and reader.
    #[inline]
    #[allow(dead_code)]
    pub fn new<R: Read>(reader: R) -> GEOSoftReader<R> {
        let builder = Self::builder();
        builder.build_from_reader(reader)
    }

    /// Creates a new `GEOSoftReader` with a specific buffer capacity.
    ///
    /// # Arguments
    /// - `capacity`: The size of the buffer for the underlying reader (in bytes).
    /// - `reader`: The reader that provides the input data for parsing.
    ///
    /// # Returns
    /// - A `GEOSoftReader` with the specified buffer capacity and reader.
    #[inline]
    #[allow(dead_code)]
    pub fn with_capacity<R: Read>(capacity: usize, reader: R) -> GEOSoftReader<R> {
        let mut builder = Self::builder();
        builder.capacity(capacity).build_from_reader(reader)
    }

    /// Returns a reference to the underlying reader.
    #[inline]
    #[allow(dead_code)]
    pub fn get_ref(&self) -> &T {
        self.reader.get_ref()
    }

    /// Returns a mutable reference to the underlying reader.
    #[inline]
    #[allow(dead_code)]
    pub fn get_mut(&mut self) -> &mut T {
        self.reader.get_mut()
    }

    /// Unwraps this CSV reader, returning the underlying reader.
    #[inline]
    #[allow(dead_code)]
    pub fn into_inner(self) -> T {
        self.reader.into_inner()
    }

    /// Returns a reference to the underlying reader.
    #[inline]
    #[allow(dead_code)]
    pub fn capacity(&self) -> usize {
        self.reader.capacity()
    }
}

impl<R: Read> GEOSoftReader<R> {
    /// Reads and parses a record from the underlying reader.
    ///
    /// This method reads data from the underlying reader (`R`), processing it into a single `GEOSoftRecord`.
    /// The reader continues until a full record is parsed, returning the number of bytes read.
    ///
    /// If the reader reaches the end of input (`EOF`), it will check if any leftover data is still available
    /// and attempt to parse it as a complete record.
    ///
    /// # Arguments
    /// * `record` - A mutable reference to a `GEOSoftRecord` that will hold the parsed data.
    ///
    /// # Returns
    /// Returns a `Result<usize>`, where `usize` is the number of bytes read. If the reader encounters an
    /// error while reading, the result will be an `Err`.
    pub fn read_record(&mut self, record: &mut GEOSoftRecord) -> io::Result<usize> {
        let mut num_reads = 0;
        loop {
            let input_bytes = self.reader.fill_buf()?;
            if input_bytes.is_empty() {
                if self.leftover.is_empty() {
                    return Ok(num_reads);
                } else {
                    let line = &self.leftover;
                    self.parser.parse_line(line, record);
                    self.cur_pos += 1;
                    num_reads += line.len();
                    self.leftover.clear();
                    return Ok(num_reads);
                }
            }

            // check if we need step into next record
            // SAFETY: input_bytes is not empty
            if unsafe { input_bytes.get_unchecked(0) } == &b'^' && !record.is_empty() {
                return Ok(num_reads);
            }

            // get a single line and parse it
            if let Some(pos) = memchr(b'\n', input_bytes) {
                // Don't include the final '\n'
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
                self.parser.parse_line(line, record);
                self.cur_pos += 1;
                num_reads += pos + 1;
                self.leftover.clear();
                self.reader.consume(pos + 1);
            } else {
                self.leftover.extend_from_slice(input_bytes);
                let consume = input_bytes.len();
                self.reader.consume(consume);
            };
        }
    }

    #[inline]
    #[allow(dead_code)]
    pub fn records(&mut self) -> GEOSoftRecordsIter<'_, R> {
        GEOSoftRecordsIter::new(self)
    }

    #[inline]
    #[allow(dead_code)]
    pub fn into_records(self) -> GEOSoftRecords<R> {
        GEOSoftRecords::new(self)
    }
}

/// A borrowed iterator over records.
///
/// The lifetime parameter `'r` refers to the lifetime of the underlying `GEOSoftReader`.
#[derive(Debug)]
pub struct GEOSoftRecordsIter<'r, R: 'r> {
    reader: &'r mut GEOSoftReader<R>,
    record: Box<GEOSoftRecord>,
}

impl<'r, R> GEOSoftRecordsIter<'r, R> {
    fn new(rdr: &'r mut GEOSoftReader<R>) -> GEOSoftRecordsIter<'r, R> {
        GEOSoftRecordsIter {
            reader: rdr,
            record: Box::new(GEOSoftRecord::new()),
        }
    }

    /// Return a reference to the underlying GEOSoftReader.
    #[inline]
    #[allow(dead_code)]
    pub fn get_ref(&self) -> &GEOSoftReader<R> {
        self.reader
    }

    #[inline]
    #[allow(dead_code)]
    /// Return a mutable reference to the underlying GEOSoftReader.
    pub fn get_mut(&mut self) -> &mut GEOSoftReader<R> {
        self.reader
    }
}

impl<'r, R: Read> Iterator for GEOSoftRecordsIter<'r, R> {
    type Item = io::Result<Box<GEOSoftRecord>>;

    fn next(&mut self) -> Option<io::Result<Box<GEOSoftRecord>>> {
        match self.reader.read_record(&mut self.record) {
            Err(err) => Some(Err(err)),
            Ok(0) => None,
            Ok(_) => {
                let record = std::mem::take(&mut self.record);
                Some(Ok(record))
            }
        }
    }
}

/// An owned iterator over records.
#[derive(Debug)]
pub struct GEOSoftRecords<R> {
    reader: GEOSoftReader<R>,
    record: GEOSoftRecord,
}

impl<R> GEOSoftRecords<R> {
    fn new(rdr: GEOSoftReader<R>) -> GEOSoftRecords<R> {
        GEOSoftRecords {
            reader: rdr,
            record: GEOSoftRecord::new(),
        }
    }

    /// Return a reference to the underlying CSV reader.
    #[inline]
    #[allow(dead_code)]
    pub fn get_ref(&self) -> &GEOSoftReader<R> {
        &self.reader
    }

    /// Return a mutable reference to the underlying CSV reader.
    #[inline]
    #[allow(dead_code)]
    pub fn get_mut(&mut self) -> &mut GEOSoftReader<R> {
        &mut self.reader
    }

    /// Drop this iterator and return the underlying CSV reader.
    #[inline]
    #[allow(dead_code)]
    pub fn into_inner(self) -> GEOSoftReader<R> {
        self.reader
    }
}

impl<R: Read> Iterator for GEOSoftRecords<R> {
    type Item = io::Result<GEOSoftRecord>;

    fn next(&mut self) -> Option<io::Result<GEOSoftRecord>> {
        match self.reader.read_record(&mut self.record) {
            Err(err) => Some(Err(err)),
            Ok(0) => None,
            Ok(_) => {
                let record = std::mem::take(&mut self.record);
                Some(Ok(record))
            }
        }
    }
}
