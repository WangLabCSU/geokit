# Get Supplemental Files from GEO

NCBI GEO allows supplemental files to be attached to GEO Series (GSE),
GEO platforms (GPL), and GEO samples (GSM). This function 'knows' how to
get these files based on the GEO accession. No parsing of the downloaded
files is attempted, since the file format is not generally knowable.

## Usage

``` r
geo_suppl(
  accession,
  pattern = NULL,
  ftp_over_https = TRUE,
  handle_opts = list(),
  odir = getwd()
)
```

## Arguments

- accession:

  A character of GEO accession IDs. Examples:

  - DataSets (GDS): `"GDS505"`, `"GDS606"`, `"GDS1234"`, `"GDS9999"`,
    etc.

  - Series (GSE): `"GSE2"`, `"GSE22"`, `"GSE100"`, `"GSE2000"`, etc.

  - Platforms (GPL): `"GPL96"`, `"GPL570"`, `"GPL10558"`, etc.

  - Samples (GSM): `"GSM12345"`, `"GSM67890"`, `"GSM112233"`, etc.

- pattern:

  character string containing a [regular
  expression](https://rdrr.io/r/base/regex.html) to be matched in the
  supplementary file names.

- ftp_over_https:

  Logical scalar. If `TRUE`, connects to GEO FTP server via HTTPS
  (<https://ftp.ncbi.nlm.nih.gov/geo>); otherwise uses plain FTP
  (<ftp://ftp.ncbi.nlm.nih.gov/geo>). Only applicable to GEO FTP server
  access.

- handle_opts:

  A list of named options / headers to be set in the
  [`multi_download`](https://jeroen.r-universe.dev/curl/reference/multi_download.html).

- odir:

  Destination directory for downloads. Defaults to the current working
  directory.

## Value

A list (or a character atomic verctor if only one `accession` is
provided) of the full file paths of the resulting downloaded files.

## Examples

``` r
# \donttest{
geo_suppl("GSM1137", odir = tempdir())
#> Downloading 1 file
#> [1] "/tmp/Rtmp8HnVhs/GSM1137.CEL.gz"
# }
```
