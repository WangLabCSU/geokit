use hashbrown::HashSet;
use memchr::memchr;

use super::record::GEOSoftRecord;

#[derive(Debug, Clone)]
pub struct GEOSoftParser {
    format: GEOSoftFormat,
    use_lines: HashSet<GEOSoftLine>,
}

impl Default for GEOSoftParser {
    fn default() -> Self {
        Self::new()
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
impl GEOSoftParser {
    #[inline]
    #[allow(dead_code)]
    pub fn new() -> Self {
        let builder = GEOSoftParserBuilder::new();
        builder.build()
    }

    #[inline]
    #[allow(dead_code)]
    pub fn builder() -> GEOSoftParserBuilder {
        GEOSoftParserBuilder::new()
    }

    #[inline]
    #[allow(dead_code)]
    pub fn format(&self) -> &GEOSoftFormat {
        &self.format
    }

    #[inline]
    #[allow(dead_code)]
    pub fn use_lines(&self) -> &HashSet<GEOSoftLine> {
        &self.use_lines
    }

    #[inline]
    #[allow(dead_code)]
    pub fn parse_line(&self, line: &[u8], record: &mut GEOSoftRecord) {
        // ignore empty lines
        if line.is_empty() || line.iter().all(|byte| byte.is_ascii_whitespace()) {
            return;
        }
        match unsafe { line.get_unchecked(0) } {
            b'^' => self.parse_caret(line, record),
            b'!' => {
                if self.use_lines.contains(&GEOSoftLine::Metadata) {
                    match self.format() {
                        GEOSoftFormat::Standard => self.parse_regular_bang(line, record),
                        GEOSoftFormat::Matrix => self.parse_matrix_bang(line, record),
                    };
                }
            }
            b'#' => {
                if self.use_lines.contains(&GEOSoftLine::Datatable) {
                    self.parse_hash(line, record);
                }
            }
            _ => {
                if self.use_lines.contains(&GEOSoftLine::Datatable) {
                    self.parse_data(line, record);
                }
            }
        }
    }

    fn parse_caret(&self, line: &[u8], record: &mut GEOSoftRecord) {
        let prefix = if let Some(pos) = memchr(b'=', line) {
            // SAFETY: we have ensure the line starts with '^' and has '='
            let prefix = unsafe { line.get_unchecked(1..pos) };
            if pos + 1 < line.len() {
                let rcd_name =
                    bytes_to_string(unsafe { line.get_unchecked(pos + 1..) }.trim_ascii());
                record.rcd_name = rcd_name;
            }
            prefix
        } else {
            unsafe { line.get_unchecked(1..) }
        };
        record.rcd_type = bytes_to_string(prefix.trim_ascii_end());
    }

    fn parse_regular_bang(&self, line: &[u8], record: &mut GEOSoftRecord) {
        // for normal SOFT file, the metadata is seprated with `=`
        if let Some(pos) = memchr(b'=', line) {
            if pos + 1 < line.len() {
                // SAFETY: we have ensure the line starts with '!'
                let label = bytes_to_string(unsafe { line.get_unchecked(1..pos) }.trim_ascii_end());
                // SAFETY: we have ensured 'pos + 1' doesn't span the ending
                let value = bytes_to_string(unsafe { line.get_unchecked(pos + 1..) }.trim_ascii());
                if let Some(metadata) = record.metadata.get_mut(&label) {
                    metadata.push(Some(value));
                } else {
                    record.metadata.insert(label, vec![Some(value)]);
                }
            }
        }
    }

    fn parse_matrix_bang(&self, line: &[u8], record: &mut GEOSoftRecord) {
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
                while record.metadata.contains_key(&label_check) {
                    label_check = format!("{}_{}", label, suffix);
                    suffix += 1;
                }
                record.metadata.insert(label_check, fields);
            }
        }
    }

    fn parse_hash(&self, line: &[u8], record: &mut GEOSoftRecord) {
        // SAFETY: we have ensure the line starts with '#'
        if let Some(pos) = memchr(b'=', line) {
            let label = bytes_to_string(unsafe { line.get_unchecked(1..pos) }.trim_ascii_end());
            let value = if pos + 1 < line.len() {
                bytes_to_string(unsafe { line.get_unchecked(pos + 1..) }.trim_ascii())
            } else {
                String::new()
            };
            if value.is_empty() {
                record.columns.push((label, None));
            } else {
                record.columns.push((label, Some(value)));
            }
        }
    }

    fn parse_data(&self, line: &[u8], record: &mut GEOSoftRecord) {
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
        if record.header.is_empty() {
            record.header = fields;
            return;
        }

        // ensure `datatable` has the same length of `fields`
        if let Some(num_added) = fields.len().checked_sub(record.datatable.len()) {
            if num_added > 0 {
                record.datatable.reserve(num_added);
                let num_fill: usize = record.datatable.get(0).map_or(0, |col| col.len());
                for _ in 0..num_added {
                    if num_fill > 0 {
                        // pre-fill with Nones so columns are aligned
                        record.datatable.push(vec![None; num_fill]);
                    } else {
                        record.datatable.push(Vec::new());
                    }
                }
            }
        }

        // SAFETY: we have ensured has the same length of fields
        for (i, field) in fields.into_iter().enumerate() {
            // SAFETY: datatable.len() >= fields.len()
            unsafe { record.datatable.get_unchecked_mut(i) }.push(field);
        }
    }
}

#[derive(Debug, Clone, Default)]
pub struct GEOSoftParserBuilder {
    format: Option<GEOSoftFormat>,
    use_lines: Option<HashSet<GEOSoftLine>>,
}

impl GEOSoftParserBuilder {
    #[inline]
    pub fn new() -> Self {
        Self {
            format: None,
            use_lines: None,
        }
    }

    #[inline]
    pub fn format(&mut self, format: GEOSoftFormat) -> &mut Self {
        self.format = Some(format);
        self
    }

    #[inline]
    pub fn use_lines(&mut self, lines: HashSet<GEOSoftLine>) -> &mut Self {
        self.use_lines = Some(lines);
        self
    }

    #[inline]
    pub fn build(&self) -> GEOSoftParser {
        let format = self
            .format
            .as_ref()
            .map_or_else(|| GEOSoftFormat::Standard, |f| f.clone());
        let use_lines = self.use_lines.as_ref().map_or_else(
            || {
                let mut uses = HashSet::with_capacity(2);
                uses.insert(GEOSoftLine::Metadata);
                uses.insert(GEOSoftLine::Datatable);
                uses
            },
            |u| u.clone(),
        );
        GEOSoftParser { format, use_lines }
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

fn strip_quotes(bytes: &[u8]) -> &[u8] {
    // strip double quotes or single quotes
    bytes
        .strip_prefix(b"\"")
        .and_then(|f| f.strip_suffix(b"\""))
        .unwrap_or_else(|| {
            bytes
                .strip_prefix(b"'")
                .and_then(|f| f.strip_suffix(b"'"))
                .unwrap_or(bytes)
        })
}

// Try to produce a String from bytes cheaply for valid UTF-8, fall back to lossless conversion.
// This avoids the cost of allocating via from_utf8_lossy when bytes are already valid UTF-8.
fn bytes_to_string(bytes: &[u8]) -> String {
    match std::str::from_utf8(bytes) {
        Ok(s) => s.to_owned(),
        Err(_) => String::from_utf8_lossy(bytes).into_owned(),
    }
}
