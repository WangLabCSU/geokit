# geokit (development version)

* Added three vignettes: case studies for diabetic nephropathy and
  urothelial cancer meta-analysis workflows, and a `geo_chat()` guide for
  LLM-assisted exploration of GEO metadata.
* Added a public Agent Skills file for AI agents, published with the pkgdown
  site at <https://wanglabcsu.github.io/geokit/skills/geokit/SKILL.md>.
* Fixed `parse_sample_data()` ignoring its `sep` argument when parsing
  characteristic key-value pairs, silently skipping non-contiguous
  `characteristics_ch` columns, and crashing on custom `fields` names
  without a `ch<N>` suffix (they now prefix parsed columns with the field
  name).
* Fixed plain-FTP downloads (`ftp_over_https = FALSE`) being deleted and
  reported as failures after a success-detection regression.
* Fixed a guaranteed crash in `geo_matrix()` when a platform annotation
  download fails, and clarified the error when sample metadata lacks
  `platform_id`.
* CI resolves `querychat` from the posit-dev R-universe after its CRAN
  archive; workflows and the skill file keep working unchanged.

# geokit 0.0.2

This is the first release of geokit on CRAN.

* Added a unified interface for resolving, downloading, and parsing NCBI GEO
  resources, including SOFT files, Series Matrix files, supplementary files,
  and metadata.
* Added vectorized GEO accession handling and parallel downloads with progress
  reporting.
* Added `geo_search()` for searching GEO records through NCBI Entrez.
* Added S4 classes and accessors for working with GEO DataSets, Series,
  Samples, and Platforms.
* Added `geo_chat()`, `geo_console()`, and `geo_shiny()` for exploring GEO
  metadata with natural-language queries.
* Added a Rust-based backend for fast GEO URL resolution and SOFT parsing.
