# Get the metadata of multiple GEO identities

This is useful to combine with
[`geo_search()`](https://WangLabCSU.github.io/geokit/reference/geo_search.md)
and filter results since
[`geo_search()`](https://WangLabCSU.github.io/geokit/reference/geo_search.md)
cannot get all long metadata of GEO identities.

## Usage

``` r
geo_meta(
  ids,
  amount = NULL,
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

- amount:

  A character string specifying the amount of data to retrieve. One of
  `"brief"`, `"quick"`, `"data"`, `"full"`, `"soft"`, or `"soft_full"`:

  - `"brief"`: shows only the accession's attributes.

  - `"quick"`: shows the accession's attributes and the first 20 rows of
    its data table.

  - `"full"`: shows the accession's attributes and the complete data
    table. This is the default when `ids` are not `DataSets` or
    `Series`.

  - `"data"`: omits the accession's attributes, showing only links to
    other accessions and the full data table.

  - `"soft"`: SOFT (Simple Omnibus in Text Format) from GEO FTP site.
    When `ids` is `DataSets` or `Series`, this is the default.

  - `"soft_full"`: full SOFT (Simple Omnibus in Text Format) files from
    GEO FTP site by DataSet (GDS) containging additionally contains
    up-to-date gene annotation for the DataSet Platform.

  For `DataSet`, `"data"` and `"full"` will be mapped to `"soft"` and
  `"soft_full"` respectively.

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

A
[data.table](https://rdatatable.gitlab.io/data.table/reference/data.table.html)
contains metadata of all ids.
