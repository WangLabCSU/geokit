# Get the metadata of multiple GEO identities

This is useful to combine with
[`geo_search()`](https://WangLabCSU.github.io/geokit/reference/geo_search.md)
and filter results since
[`geo_search()`](https://WangLabCSU.github.io/geokit/reference/geo_search.md)
cannot get all long metadata of GEO identities.

## Usage

``` r
geo_meta(
  accession,
  famount = NULL,
  scope = NULL,
  ftp_over_https = NULL,
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

- famount:

  A character string specifying either:

  - the file format on the GEO FTP server, or

  - the amount of data in the GEO Accession Display Bar.

  See
  [`geo_url()`](https://WangLabCSU.github.io/geokit/reference/geo_url.md)
  for details.

- scope:

  A character specifying which GEO accessions to include (Only
  applicable to Accession Display Bar access).

  - `"none"`: Applicable only to DataSets; for DataSets, this is also
    the sole valid option

  - `"self"`: the queried accession only.

  - `"gsm"`, `"gpl"`, `"gse"`: related samples, platforms, or series.

  - `"all"`: all accessions related to the query (family view).

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

A data frame contains metadata of all ids.
