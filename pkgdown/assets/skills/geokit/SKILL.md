---
name: geokit
description: >
  Use the R package geokit to search, download, parse, and analyze NCBI Gene
  Expression Omnibus (GEO) resources. Prefer this skill when working with GSE,
  GSM, GPL, or GDS accessions; GEO SOFT/MINiML/matrix/supplementary files;
  ExpressionSet construction; GEOmetadb-style metadata databases; or natural-
  language exploration of GEO metadata via geo_chat/geo_shiny/geo_console.
license: MIT
compatibility: >
  Requires R >= 3.5 with package geokit. Network access to NCBI GEO/Entrez is
  required for live queries and downloads. Biobase is required for geo_matrix()
  ExpressionSet output. querychat and duckdb are required for geo_chat family.
  Optional NCBI ENTREZ_KEY improves search rate limits.
metadata:
  author: WangLabCSU
  package: geokit
  version: "0.0.2"
  homepage: https://WangLabCSU.github.io/geokit/
  repository: https://github.com/WangLabCSU/geokit
  skill-url: https://WangLabCSU.github.io/geokit/skills/geokit/SKILL.md
  skill-raw: https://WangLabCSU.github.io/geokit/SKILL.md
  docs: https://WangLabCSU.github.io/geokit/reference/
---

# geokit — NCBI GEO toolkit for R

## Purpose

`geokit` is a tidy, fast R interface to the NCBI [Gene Expression Omnibus (GEO)](https://www.ncbi.nlm.nih.gov/geo/). It unifies:

- Entrez/GDS search (`geo_search`)
- Metadata bulk fetch for custom offline databases (`geo_meta`)
- SOFT download + parse into S4 objects (`geo_soft`)
- Series Matrix → Bioconductor `ExpressionSet` (`geo_matrix`)
- Supplementary file download (`geo_suppl`)
- URL resolution and browser landing pages (`geo_url`, `geo_show`, `geo_gtype`)
- Phenotype cleaning and log2 transform helpers (`parse_sample_data`, `log_trans`)
- LLM-assisted metadata exploration (`geo_chat`, `geo_shiny`, `geo_console`)

Core URL resolution and SOFT parsing use a Rust backend for speed.

## When to use this skill

Use this skill when the user needs to:

- Find GEO studies by disease, organism, technology, or keywords
- Download/parse GSE/GSM/GPL/GDS SOFT or matrix files
- Build ExpressionSet objects for Bioconductor workflows
- Retrieve raw or processed supplementary files (counts, FASTQ links metadata, etc.)
- Build a research-area-specific offline GEO metadata table (GEOmetadb-style)
- Chat/filter GEO metadata with natural language

Do **not** invent GEO accessions or pretend downloads succeeded without network results. Prefer real `geokit` APIs over ad-hoc FTP scraping or the older `GEOquery` patterns unless the user explicitly asks for comparison.

## Remote skill access

Agents and users can fetch this skill directly:

```bash
# Canonical skill path (Agent Skills layout)
curl -fsSL https://WangLabCSU.github.io/geokit/skills/geokit/SKILL.md -o SKILL.md

# Short alias at site root
curl -fsSL https://WangLabCSU.github.io/geokit/SKILL.md -o SKILL.md
```

Package documentation site: <https://WangLabCSU.github.io/geokit/>

## Installation

**Recommended (binary/prebuilt via R-universe):**

```r
install.packages(
  "geokit",
  repos = c(
    "https://wanglabcsu.r-universe.dev",
    "https://cloud.r-project.org"
  )
)
```

**From GitHub (requires Rust: `cargo` + `rustc >= 1.87.0`):**

```r
if (!requireNamespace("pak", quietly = TRUE)) {
  install.packages(
    "pak",
    repos = sprintf(
      "https://r-lib.github.io/p/pak/devel/%s/%s/%s",
      .Platform$pkgType, R.Version()$os, R.Version()$arch
    )
  )
}
pak::pak("WangLabCSU/geokit")
```

```r
library(geokit)
```

### Optional dependencies

| Need | Packages |
|------|----------|
| `geo_matrix()` / ExpressionSet | `Biobase` (Bioconductor) |
| Search result wrangling vignettes | `dplyr`, `stringr` |
| Compressed downloads | `R.utils` |
| `geo_chat` / `geo_shiny` / `geo_console` | `querychat` (>= 0.3.0), `duckdb` |
| Faster Entrez search | NCBI API key via `rentrez::set_entrez_key()` or env `ENTREZ_KEY` |

```r
# Bioconductor ExpressionSet support
if (!requireNamespace("Biobase", quietly = TRUE)) {
  if (!requireNamespace("BiocManager", quietly = TRUE)) {
    install.packages("BiocManager")
  }
  BiocManager::install("Biobase")
}

# Optional LLM chat stack
# install.packages(c("duckdb"))  # plus querychat per its docs
```

## GEO domain model (must know)

| Prefix | Entity | Meaning |
|--------|--------|---------|
| **GSE** | Series | Experiment / study grouping related samples |
| **GSM** | Sample | One biological/technical sample measurement |
| **GPL** | Platform | Array/probe or detectable element definition |
| **GDS** | DataSet | NCBI-curated, cross-comparable sample collection |

Relationships:

- A **Series (GSE)** references many **Samples (GSM)** and one or more **Platforms (GPL)**.
- A **Sample** references exactly one **Platform**.
- A **Platform** may be reused across many samples/series/submitters.
- A **DataSet (GDS)** is curated; samples share a platform and comparable processing.

### File formats geokit understands

| Format key | Typical use | GDS | GSE | GPL | GSM |
|------------|-------------|:---:|:---:|:---:|:---:|
| `soft` | SOFT text (FTP) | o | o | o | x |
| `soft_full` | GDS SOFT + up-to-date platform annotation | o | x | x | x |
| `miniml` | XML rendering of SOFT | x | o | o | x |
| `matrix` | Series matrix (expression + phenotype) | x | o | x | x |
| `annot` | Platform annotation | x | x | o | x |
| `suppl` | Supplementary files directory | x | o | o | o |
| `text` / `xml` / `html` | Accession Display Bar views | see docs | o* | o | o |

\*GDS Accession Display Bar amount/scope are restricted (`none` only for amount/scope in several paths). Defaults in high-level helpers:

- `geo_soft()` / `geo_meta()`: GDS & GSE → FTP `soft`; GPL & GSM → Accession Display `text` with `full` amount.
- `geo_matrix()`: GSE-only, FTP `matrix`.
- `geo_suppl()`: FTP/HTTPS supplementary directory listing + download.

Accession IDs are case-insensitive in helpers (`"gpl98"` works).

## Decision guide: which function?

```
Need study discovery by keywords?
  → geo_search(query)

Need full SOFT-derived metadata table for many IDs?
  → geo_meta(accessions, odir = ...)

Need structured SOFT object (metadata + table + related entities)?
  → geo_soft(accession, odir = ...)

Need ExpressionSet for differential expression / Bioconductor?
  → geo_matrix(GSE, odir = ...)   # requires Biobase

Need counts/raw/other attachments, not series matrix?
  → geo_suppl(accession, pattern = "...", odir = ...)

Need only the URL or to open NCBI page?
  → geo_url() / geo_show() / geo_gtype()

Need NL filtering of a metadata data.frame?
  → geo_chat() / geo_shiny() / geo_console()
```

**RNA-seq reality check:** many modern GSE records have **empty or absent series matrices**. Prefer `geo_suppl()` (often `*counts*`, `*tpm*`, `*fpkm*`) or sample-level supplements; do not assume `geo_matrix()` always yields usable assays.

## API reference (authoritative signatures)

### `geo_gtype(accession, abbre = FALSE)`

Return GEO entity type string(s). `abbre = TRUE` → `"GSE"|"GSM"|"GPL"|"GDS"`.

```r
geo_gtype("GSE10")
geo_gtype(c("gpl98", "GSM1"), abbre = TRUE)
```

### `geo_url(accession, format = NULL, amount = NULL, scope = NULL, ftp_over_https = NULL)`

Build GEO FTP/HTTPS or Accession Display URLs. See format/amount/scope tables above.

- `amount`: `none` | `brief` | `quick` | `data` | `full` (Display Bar)
- `scope`: `none` | `self` | `gsm` | `gpl` | `gse` | `all` (Display Bar)
- `ftp_over_https`: `TRUE` → `https://ftp.ncbi.nlm.nih.gov/geo/...` (preferred)

### `geo_show(accession, famount = NULL, scope = NULL, ftp_over_https = NULL, browser = getOption("browser"))`

Open GEO landing page in a browser (interactive).

### `geo_search(query, step = 500L, interval = NULL)`

Search NCBI **gds** database via `rentrez`; returns a **data.frame** of parsed summary records.

- Use NCBI fielded syntax: `"diabetes[ALL] AND Homo sapiens[ORGN] AND GSE[ETYP]"`
- Fields reference: <https://www.ncbi.nlm.nih.gov/geo/info/qqtutorial.html>
- List fields: `rentrez::entrez_db_searchable("gds")`
- Set API key for higher rate limits (10 req/s):

```r
rentrez::set_entrez_key("YOUR_KEY")
# or Sys.setenv(ENTREZ_KEY = "YOUR_KEY")
```

- `step`: page size per Entrez fetch (lower if failures)
- `interval`: seconds between pages (increase under rate limits)
- Errors with “No items found.” when count is 0

Typical columns include Title, Summary, Type, Organism, Contains, accession fields (exact set depends on NCBI summary text).

```r
hits <- geo_search("diabetes[ALL] AND Homo sapiens[ORGN] AND GSE[ETYP]")
```

Post-filter example (requires `dplyr`/`stringr`):

```r
library(dplyr)
library(stringr)

filtered <- hits |>
  mutate(
    number_of_samples = as.integer(
      str_match(Contains, "(\\d+) Samples?")[, 2]
    )
  ) |>
  filter(
    if_any(c(Title, Summary), ~ str_detect(.x, regex("nephropathy", TRUE))),
    str_detect(Type, regex("expression profiling", TRUE)),
    number_of_samples >= 6L
  )
```

### `geo_meta(accession, famount = NULL, scope = NULL, ftp_over_https = NULL, handle_opts = list(), odir = getwd())`

Download SOFT-like content for one or many accessions and return a **data.frame** of collapsed metadata (list-columns joined with `"; "`). Ideal after `geo_search()` for building a local GEOmetadb-style table.

```r
meta <- geo_meta(filtered[["Series Accession"]], odir = "gse_meta_cache")
```

### `geo_soft(accession, famount = NULL, scope = NULL, ftp_over_https = NULL, handle_opts = list(), odir = getwd())`

Download and parse SOFT into S4 objects:

| Input | Return class | Extra slots |
|-------|--------------|-------------|
| GSM / GDS | `GEOSoft` | — |
| GPL | `GEOPlatform` | `gsm`, `gse` (lists of `GEOSoft`) |
| GSE | `GEOSeries` | `gsm`, `gpl` (lists of `GEOSoft`) |

Vectorized: multiple accessions → list (or single object if length 1 via internal helper).

**Accessors** (generics): `accession()`, `rcd_type()`, `rcd_name()`, `metadata()`, `datatable()`, `columns()`, plus `gsm()`, `gse()`, `gpl()` where applicable. Replacement forms exist (`accession<-`, etc.).

```r
gsm <- geo_soft("GSM1", odir = tempdir())
metadata(gsm)
head(datatable(gsm))
head(columns(gsm))

gse <- geo_soft("GSE10", odir = tempdir())
names(gsm(gse))
names(gpl(gse))
```

`columns` is a data.frame of column descriptions aligned to `datatable` colnames.

### `geo_matrix(accession, add_gpl = NULL, pdata_from_soft = FALSE, ftp_over_https = NULL, handle_opts = list(), odir = getwd())`

**GSE only.** Returns `ExpressionSet` (or list if multiple matrix files / accessions).

- Parses series matrix assay + phenotype
- Auto-expands `characteristics_ch*` into trait columns via `parse_sample_data()`
- `add_gpl`:
  - `NULL` (default): try map GPL → Bioconductor annotation package (`inst/extdata/gpl2bioc.rds`); if none, fall back to downloading platform annotation into `featureData`
  - `TRUE`: force GEO platform annotation into `featureData`
  - `FALSE`: skip feature table; may still set `annotation()` to Bioc package name when mappable
- `pdata_from_soft = TRUE`: build phenoData from GSE SOFT GSM metadata if matrix characteristics parsing is problematic

```r
library(Biobase)
eset <- geo_matrix("GSE180383", odir = tempdir())
exprs(eset)[1:5, 1:5]
head(pData(eset))
annotation(eset)
```

### `geo_suppl(accession, pattern = NULL, ftp_over_https = TRUE, handle_opts = list(), odir = getwd())`

List and download supplementary files for GSE/GPL/GSM. Returns local file path(s). `pattern` is a regex on file names. **No parsing** — format is opaque; use `data.table::fread()`, `readr`, etc. afterward.

```r
paths <- geo_suppl("GSE160724", pattern = "counts_anno", odir = tempdir())
counts <- data.table::fread(paths)
```

### `parse_sample_data(x, ..., fields = NULL, sep = ":")`

Methods for `GEOSeries`, list of GSM `GEOSoft`, or `data.frame`. Expands GEO `characteristics_ch*` key-value pairs into columns named like `ch1_<key>`.

### `log_trans(data, pseudo = 1, ...)`

Methods for `matrix` and `ExpressionSet`. GEO2R-style heuristic detects prior log-scale; otherwise applies `log2(data + pseudo)`.

```r
eset2 <- log_trans(eset)
mat2 <- log_trans(as.matrix(exprs(eset)), pseudo = 1)
```

### Chat family

```r
geo_chat(client, data_source, table_name = NULL, ...)
geo_shiny(...)    # geo_chat(...) then Shiny app
geo_console(...)  # geo_chat(...) then console chat
```

- `data_source`: data.frame or DB connection (typically `geo_search()` / `geo_meta()` output)
- Uses package prompt `inst/prompts/prompt.md` tailored to GEO metadata SQL exploration
- Requires `querychat`; does not dump entire tables into the LLM prompt — schema + SQL tools instead

```r
# Pseudocode — supply a real querychat-compatible client
# chat <- geo_chat(client, meta, cleanup = TRUE)
# geo_shiny(client, meta)
```

### Shared download parameters

Most download helpers accept:

- `odir`: destination directory (created if needed). **Always set explicitly in scripts** (`tempdir()` or project cache) to avoid cluttering the working directory.
- `handle_opts`: list passed through to `curl::multi_download` (timeouts, headers, etc.)
- `ftp_over_https`: prefer `TRUE`/default HTTPS fronting of GEO FTP

Downloads are multi-file aware with progress messaging.

## Recommended workflows

### 1. Discover → filter → metadata DB

```r
library(geokit)
library(dplyr)
library(stringr)

q <- "urothelial cancer[ALL] AND Homo sapiens[ORGN] AND GSE[ETYP]"
hits <- geo_search(q)

hits <- hits |>
  mutate(
    n_samples = as.integer(str_match(Contains, "(\\d+) Samples?")[, 2])
  )

# Pull full series metadata for candidates (disk cache in odir)
meta <- geo_meta(hits[["Series Accession"]], odir = "cache/uc_gse")

# Regex filter for single-cell studies
sc <- meta |>
  filter(if_any(
    any_of(c("Series_summary", "Series_title", "Series_overall_design")),
    ~ str_detect(.x, regex("single[- ]cell|scRNA", TRUE))
  ))
```

### 2. Microarray / classic expression series

```r
eset <- geo_matrix("GSE10", odir = "cache/GSE10")
eset <- log_trans(eset)
# Continue with limma/DESeq2-style design from pData(eset)
```

### 3. RNA-seq counts from supplements

```r
files <- geo_suppl("GSE160724", pattern = "counts", odir = "cache/GSE160724")
# Inspect basenames(files); read the appropriate table
```

### 4. Deep sample/platform inspection via SOFT

```r
gse <- geo_soft("GSE10", odir = "cache/soft")
pd <- parse_sample_data(gse)
plat <- gpl(gse)[[1]]
head(datatable(plat))
```

### 5. Reproducible project layout

```text
project/
  cache/geo/          # odir targets (gitignore large files)
  scripts/01_search.R
  scripts/02_download.R
  data_derived/
```

Always parameterize `odir`, record accessions + date + geokit version in analysis metadata (`packageVersion("geokit")`, `sessionInfo()`).

## Reliability and safety rules for agents

1. **Validate accessions** with `geo_gtype()` before bulk download.
2. **Prefer HTTPS FTP** (`ftp_over_https = TRUE`) unless the environment forbids it.
3. **Cache on disk** (`odir`); re-running should reuse local files when present (download layer writes under `odir`).
4. **Respect NCBI rate limits**; set `ENTREZ_KEY` for `geo_search`; use `interval`/`step` if requests fail.
5. **Do not claim ExpressionSet gene symbols** without checking `featureData` / annotation package mapping.
6. **Treat supplementary file schemas as unknown** until inspected.
7. **Multi-platform GSE** may yield multiple series matrix files → list of ExpressionSets.
8. **Never hardcode secrets**; API keys via env vars only.
9. When code fails, surface the geokit/NCBI error; do not silently switch to fabricated data.
10. For large accession vectors, batch `geo_meta`/`geo_soft` and keep progress visible.

## Comparison notes

| Tool | Role vs geokit |
|------|----------------|
| GEOquery | Classic Bioconductor GEO client; geokit aims for faster Rust parsing, unified URL layer, vectorized downloads, modern chat helpers |
| GEOmetadb | Static SQLite snapshot; geokit builds **dynamic, query-specific** metadata tables via `geo_search` + `geo_meta` |
| rentrez | Low-level Entrez; geokit wraps it inside `geo_search` |
| GEO2R | Web DE tool; `log_trans()` mirrors its log-detection heuristic |

## Documentation map

| Resource | URL |
|----------|-----|
| Home | https://WangLabCSU.github.io/geokit/ |
| This skill | https://WangLabCSU.github.io/geokit/skills/geokit/SKILL.md |
| Skill alias | https://WangLabCSU.github.io/geokit/SKILL.md |
| Reference | https://WangLabCSU.github.io/geokit/reference/ |
| Search vignette | https://WangLabCSU.github.io/geokit/articles/geo-search.html |
| Metadata DB vignette | https://WangLabCSU.github.io/geokit/articles/geometadb.html |
| SOFT vignette | https://WangLabCSU.github.io/geokit/articles/geo-soft.html |
| Matrix vignette | https://WangLabCSU.github.io/geokit/articles/geo-matrix.html |
| Suppl vignette | https://WangLabCSU.github.io/geokit/articles/geo-suppl.html |
| Source | https://github.com/WangLabCSU/geokit |
| Issues | https://github.com/WangLabCSU/geokit/issues |
| GEO query tutorial | https://www.ncbi.nlm.nih.gov/geo/info/qqtutorial.html |
| GEO download info | https://www.ncbi.nlm.nih.gov/geo/info/download.html |

## Quick command card

```r
library(geokit)

geo_gtype("GSE12345")
geo_url("GSE12345", format = "matrix")
hits  <- geo_search("breast cancer[ALL] AND Homo sapiens[ORGN] AND GSE[ETYP]")
meta  <- geo_meta(hits[["Series Accession"]][1:5], odir = tempdir())
soft  <- geo_soft("GSM1", odir = tempdir())
eset  <- geo_matrix("GSE180383", odir = tempdir())  # needs Biobase
supp  <- geo_suppl("GSE160724", pattern = "counts", odir = tempdir())
eset  <- log_trans(eset)
```

## Skill maintenance

- Package version in frontmatter should track `DESCRIPTION` `Version`.
- After API changes, update signatures and decision guide in this file and redeploy pkgdown (GitHub Pages).
- Keep examples runnable with public accessions and `odir = tempdir()` in docs; use project caches in production scripts.
