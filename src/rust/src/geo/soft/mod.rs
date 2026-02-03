use std::fs::File;
use std::io::{self, BufRead, BufReader, Read};
use std::path::Path;

use hashbrown::HashSet;

mod parser;
mod record;

pub use parser::{GEOSoftFormat, GEOSoftLine};
pub use record::GEOSoftRecord;

use parser::{GEOSoftParser, RecordParseState};

#[derive(Debug, Clone, Default)]
pub struct GEOSoftReaderBuilder {
    capacity: Option<usize>,
    format: Option<GEOSoftFormat>,
    lines: Option<HashSet<GEOSoftLine>>,
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
        self.format = Some(format);
        self
    }

    #[inline]
    pub fn line(&mut self, line: GEOSoftLine) -> &mut Self {
        let set = self.lines.get_or_insert_with(HashSet::new);
        set.insert(line);
        self
    }

    #[inline]
    #[allow(dead_code)]
    pub fn lines<I: IntoIterator<Item = GEOSoftLine>>(&mut self, lines: I) -> &mut Self {
        let mut uses = HashSet::with_capacity(2);
        for line in lines {
            uses.insert(line);
        }
        uses.shrink_to_fit();
        self.lines = Some(uses);
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
        let format = self
            .format
            .as_ref()
            .map_or_else(|| GEOSoftFormat::Standard, |f| f.clone());
        let lines = self.lines.as_ref().map_or_else(
            || {
                let mut uses = HashSet::with_capacity(2);
                uses.insert(GEOSoftLine::Metadata);
                uses.insert(GEOSoftLine::Datatable);
                uses
            },
            |u| u.clone(),
        );
        let parser = GEOSoftParser::new(format, lines);
        let capacity = self.capacity.unwrap_or(4 * (1 << 20));
        GEOSoftReader {
            reader: BufReader::with_capacity(capacity, reader),
            parser,
            line: 1,
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
    line: usize,           // The current line number.
    parser: GEOSoftParser, // The parser that interprets the SOFT data
    reader: BufReader<R>,  // Underlying buffered reader
}

// Methods for all instances of GEOSoftReader<T>
impl<T> GEOSoftReader<T> {
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

    #[inline]
    pub fn builder() -> GEOSoftReaderBuilder {
        GEOSoftReaderBuilder::new()
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

    #[inline]
    #[allow(dead_code)]
    pub fn format(&self) -> &GEOSoftFormat {
        self.parser.format()
    }

    #[inline]
    #[allow(dead_code)]
    pub fn lines(&self) -> &HashSet<GEOSoftLine> {
        self.parser.lines()
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
            let (state, nin, nline) = self.parser.read_record(input_bytes, record);
            self.reader.consume(nin);
            num_reads += nin;
            self.line += nline;
            match state {
                RecordParseState::Record | RecordParseState::End => {
                    return Ok(num_reads);
                }
                RecordParseState::InputEmpty => {
                    continue;
                }
            }
        }
    }

    #[inline]
    #[allow(dead_code)]
    pub fn records(&mut self) -> GEOSoftRecords<'_, R> {
        GEOSoftRecords::new(self)
    }

    #[inline]
    #[allow(dead_code)]
    pub fn into_records(self) -> GEOSoftIntoRecords<R> {
        GEOSoftIntoRecords::new(self)
    }
}

/// A borrowed iterator over records.
///
/// The lifetime parameter `'r` refers to the lifetime of the underlying `GEOSoftReader`.
#[derive(Debug)]
pub struct GEOSoftRecords<'r, R: 'r> {
    reader: &'r mut GEOSoftReader<R>,
    record: GEOSoftRecord,
}

impl<'r, R> GEOSoftRecords<'r, R> {
    fn new(reader: &'r mut GEOSoftReader<R>) -> GEOSoftRecords<'r, R> {
        GEOSoftRecords {
            reader,
            record: GEOSoftRecord::new(),
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

impl<'r, R: Read> Iterator for GEOSoftRecords<'r, R> {
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

/// An owned iterator over records.
#[derive(Debug)]
pub struct GEOSoftIntoRecords<R> {
    reader: GEOSoftReader<R>,
    record: GEOSoftRecord,
}

impl<R> GEOSoftIntoRecords<R> {
    fn new(reader: GEOSoftReader<R>) -> GEOSoftIntoRecords<R> {
        GEOSoftIntoRecords {
            reader,
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

impl<R: Read> Iterator for GEOSoftIntoRecords<R> {
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
