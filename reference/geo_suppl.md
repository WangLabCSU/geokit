# Get Supplemental Files from GEO

NCBI GEO allows supplemental files to be attached to GEO Series (GSE),
GEO platforms (GPL), and GEO samples (GSM). This function 'knows' how to
get these files based on the GEO accession. No parsing of the downloaded
files is attempted, since the file format is not generally knowable by
the computer.

## Usage

``` r
geo_suppl(
  ids,
  pattern = NULL,
  ftp_over_https = TRUE,
  handle_opts = list(),
  odir = getwd()
)
```

## Arguments

- ids:

  Character vector of GEO accession IDs to download and parse. All IDs
  must belong to the same GEO entity type. Examples:

  - DataSets: `c("GDS505", "GDS606")`

  - Series: `c("GSE2", "GSE22")`

- pattern:

  character string containing a [regular
  expression](https://rdrr.io/r/base/regex.html) to be matched in the
  supplementary file names.

- ftp_over_https:

  Logical scalar. If `TRUE`, connects to GEO FTP via HTTPS
  (`https://ftp.ncbi.nlm.nih.gov/geo`); otherwise, uses plain FTP.

- handle_opts:

  A list of named options / headers to be set in the
  [`multi_download`](https://jeroen.r-universe.dev/curl/reference/multi_download.html).

- odir:

  Destination directory for downloads. Defaults to the current working
  directory.

## Value

A list (or a character atomic verctor if only one `id` is provided) of
the full file paths of the resulting downloaded files.

## Examples

``` r
geo_suppl("GSM1137", odir = tempdir())
#> Downloading 1 GSM suppl file from FTP site
#> [1] "/tmp/Rtmpv8F4G6/GSM1137.CEL.gz"
```
