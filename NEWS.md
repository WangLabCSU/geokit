# geokit (development version)

* Added a public Agent Skills file for AI agents, published once with the
  pkgdown site at
  <https://WangLabCSU.github.io/geokit/skills/geokit/SKILL.md>.

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
