use hashbrown::HashSet;

#[derive(Debug, Clone)]
pub struct GEOSoftConfig {
    format: GEOSoftFormat,
    use_lines: HashSet<GEOSoftLine>,
}

impl GEOSoftConfig {
    pub fn new() -> Self {
        let builder = GEOSoftConfigBuilder::new();
        builder.build()
    }

    #[inline]
    pub fn builder() -> GEOSoftConfigBuilder {
        GEOSoftConfigBuilder::new()
    }

    #[inline]
    pub fn format(&self) -> &GEOSoftFormat {
        &self.format
    }

    #[inline]
    pub fn use_lines(&self) -> &HashSet<GEOSoftLine> {
        &self.use_lines
    }
}

#[derive(Debug, Clone)]
pub struct GEOSoftConfigBuilder {
    format: Option<GEOSoftFormat>,
    use_lines: Option<HashSet<GEOSoftLine>>,
}

impl GEOSoftConfigBuilder {
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
    pub fn build(&self) -> GEOSoftConfig {
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
        GEOSoftConfig {
            format,
            use_lines,
        }
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
