# Open the GEO landing page in a browser

Construct a GEO landing page and open it directly in the system's
default web browser (or a user-specified browser).

## Usage

``` r
geo_show(
  accession,
  famount = NULL,
  scope = NULL,
  over_https = NULL,
  browser = getOption("browser")
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
  for details. For entries from the GEO Accession Display Bar, the
  format will always be `"html"`.

- scope:

  A character specifying which GEO accessions to include (Only
  applicable to Accession Display Bar access).

  - `"none"`: Applicable only to DataSets; for DataSets, this is also
    the sole valid option

  - `"self"`: the queried accession only.

  - `"gsm"`, `"gpl"`, `"gse"`: related samples, platforms, or series.

  - `"all"`: all accessions related to the query (family view).

- over_https:

  Logical scalar. If `TRUE`, connects to GEO FTP server via HTTPS
  (<https://ftp.ncbi.nlm.nih.gov/geo>); otherwise uses plain FTP
  (<ftp://ftp.ncbi.nlm.nih.gov/geo>). Only applicable to GEO FTP server
  access.

- browser:

  a non-empty character string giving the name of the program to be used
  as the HTML browser. It should be in the PATH, or a full path
  specified. Alternatively, an R function to be called to invoke the
  browser.

  Under Windows `NULL` is also allowed (and is the default), and implies
  that the file association mechanism will be used.

## Details

See [`utils::browseURL()`](https://rdrr.io/r/utils/browseURL.html)

## References

- <https://www.ncbi.nlm.nih.gov/geo/info/download.html>

- <https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi>

- <https://www.ncbi.nlm.nih.gov/geo/info/soft.html#format>

- [Programmatic access to GEO FTP
  site](https://ftp.ncbi.nlm.nih.gov/geo/README.txt)

## Examples

``` r
if (interactive()) {
    geo_show("gpl96")
}
```
