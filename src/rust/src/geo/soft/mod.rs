use std::fs::File;
use std::io::{self, BufRead, BufReader, Read};
use std::path::Path;

use anyhow::Result;
use memchr::memchr;

mod config;
mod record;

pub use config::{GEOSoftConfig, GEOSoftFormat, GEOSoftLine};
pub use record::GEOSoftRecord;

/// A reader for parsing SOFT (Simple Omnibus Format in Text) files.
#[derive(Debug, Clone)]
pub struct GEOSoftReader<R> {
    reader: R,             // Underlying buffered reader
    config: GEOSoftConfig, // The parser that interprets the SOFT data
    leftover: Vec<u8>,
    /// The current position of the reader.
    ///
    /// Note that this position is only observable by callers at the start
    /// of a record. More granular positions are not supported.
    cur_pos: usize,
}

// Methods for all instances of GEOSoftReader<T>
impl<T> GEOSoftReader<T> {
    /// Creates a new `GEOSoftReader` with a specified configuration and an underlying reader.
    ///
    /// This method initializes the reader with a default buffer capacity of 4MB.
    ///
    /// # Arguments
    /// - `config`: The configuration used for reading and parsing the SOFT data.
    /// - `reader`: The source of bytes for reading and parsing the SOFT data.
    ///
    /// # Returns
    /// - A `GEOSoftReader` with the specified configuration and reader.
    pub fn new<R: Read>(config: GEOSoftConfig, reader: R) -> GEOSoftReader<BufReader<R>> {
        let reader = BufReader::with_capacity(4 * (1 << 20), reader);
        Self::from_bufreader_impl(config, reader)
    }

    /// Creates a new `GEOSoftReader` with a default configuration and the provided reader.
    ///
    /// This method uses the default configuration (`GEOSoftConfig::new()`).
    ///
    /// # Arguments
    /// - `reader`: The reader that provides the input data for parsing.
    ///
    /// # Returns
    /// - A `GEOSoftReader` initialized with the provided reader and the default configuration.
    pub fn from_reader<R: Read>(reader: R) -> GEOSoftReader<BufReader<R>> {
        Self::new(GEOSoftConfig::new(), reader)
    }

    /// Creates a new `GEOSoftReader` that reads from a file at the specified path.
    ///
    /// # Arguments
    /// - `path`: The file path of the SOFT file to be parsed.
    ///
    /// # Returns
    /// - A `GEOSoftReader` that reads from the file at the given path.
    /// - Returns an `io::Result` to handle any potential I/O errors during file opening.
    pub fn from_path<P: AsRef<Path>>(path: P) -> io::Result<GEOSoftReader<BufReader<File>>> {
        Ok(Self::from_reader(File::open(path)?))
    }

    /// Creates a new `GEOSoftReader` with a specified underlying `BufRead` reader.
    ///
    /// # Arguments
    /// - `reader`: The `BufRead` reader used for parsing the SOFT data.
    ///
    /// # Returns
    /// - A `GEOSoftReader` with the specified `BufRead` reader.
    pub fn from_bufreader<R: BufRead>(reader: R) -> GEOSoftReader<R> {
        Self::from_bufreader_impl(GEOSoftConfig::new(), reader)
    }

    /// Creates a new `GEOSoftReader` with a specific buffer capacity.
    ///
    /// # Arguments
    /// - `capacity`: The size of the buffer for the underlying reader (in bytes).
    /// - `reader`: The reader that provides the input data for parsing.
    ///
    /// # Returns
    /// - A `GEOSoftReader` with the specified buffer capacity and reader.
    pub fn with_capacity<R: Read>(capacity: usize, reader: R) -> GEOSoftReader<BufReader<R>> {
        let reader = BufReader::with_capacity(capacity, reader);
        Self::from_bufreader_impl(GEOSoftConfig::new(), reader)
    }

    fn from_bufreader_impl<R: BufRead>(config: GEOSoftConfig, reader: R) -> GEOSoftReader<R> {
        GEOSoftReader {
            reader,
            config,
            leftover: Vec::new(),
            cur_pos: 1,
        }
    }

    /// Returns a reference to the underlying reader.
    #[allow(dead_code)]
    pub fn get_ref(&self) -> &T {
        &self.reader
    }

    /// Returns a mutable reference to the underlying reader.
    #[allow(dead_code)]
    pub fn get_mut(&mut self) -> &mut T {
        &mut self.reader
    }

    /// Unwraps this CSV reader, returning the underlying reader.
    #[allow(dead_code)]
    pub fn into_inner(self) -> T {
        self.reader
    }
}

impl<R: io::Read> GEOSoftReader<BufReader<R>> {
    /// Returns a reference to the underlying reader.
    #[allow(dead_code)]
    pub fn capacity(&self) -> usize {
        self.reader.capacity()
    }
}

impl<R: io::BufRead> GEOSoftReader<R> {
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
    pub fn read_record(&mut self, record: &mut GEOSoftRecord) -> Result<usize> {
        let mut num_reads = 0;
        loop {
            let input_bytes = self.reader.fill_buf()?;
            if input_bytes.is_empty() {
                if self.leftover.is_empty() {
                    return Ok(num_reads);
                } else {
                    let line = &self.leftover;
                    record.parse_line(line, &self.config);
                    self.cur_pos += 1;
                    num_reads += line.len();
                    self.leftover.clear();
                    return Ok(num_reads);
                }
            }

            // check if we need step into next record
            // SAFETY: input_bytes is not empty
            if unsafe { input_bytes.get_unchecked(0) } == &b'^' && !record.empty() {
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
                record.parse_line(line, &self.config);
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

    pub fn iter(self) -> GEOSoftRecordIter<R> {
        GEOSoftRecordIter::new(self)
    }
}

#[derive(Debug, Clone)]
pub struct GEOSoftRecordIter<R> {
    reader: GEOSoftReader<R>,
    record: GEOSoftRecord,
}

impl<R: io::BufRead> GEOSoftRecordIter<R> {
    pub fn new(rdr: GEOSoftReader<R>) -> GEOSoftRecordIter<R> {
        GEOSoftRecordIter {
            reader: rdr,
            record: GEOSoftRecord::new(),
        }
    }

    /// Return a reference to the underlying CSV reader.
    #[allow(dead_code)]
    pub fn reader(&self) -> &GEOSoftReader<R> {
        &self.reader
    }

    /// Return a mutable reference to the underlying CSV reader.
    #[allow(dead_code)]
    pub fn reader_mut(&mut self) -> &mut GEOSoftReader<R> {
        &mut self.reader
    }

    /// Drop this iterator and return the underlying CSV reader.
    #[allow(dead_code)]
    pub fn into_inner(self) -> GEOSoftReader<R> {
        self.reader
    }
}

impl<R: io::BufRead> Iterator for GEOSoftRecordIter<R> {
    type Item = Result<GEOSoftRecord>;

    fn next(&mut self) -> Option<Result<GEOSoftRecord>> {
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
