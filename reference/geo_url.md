# GEO URL resolver

Construct and resolve URLs for GEO (Gene Expression Omnibus) resources.
This function provides a unified interface for accessing GEO data either
via Accession Display Bar of GEO database or directly from GEO FTP/HTTPS
servers. Depending on the accession type or requested `format` and
`amount`, it automatically generates the correct URL.

## Usage

``` r
geo_url(
  accession,
  format = NULL,
  amount = NULL,
  scope = NULL,
  ftp_over_https = NULL
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

- format:

  A character specifying file format type requested. GEO data can be
  accessed through two sites:

  - Direct FTP/HTTPS file retrieval from GEO FTP server (file type):

    - `"soft"`: SOFT (Simple Omnibus in Text Format) from GEO FTP site.
      When `accession` is `DataSets` or `Series`, this is the default.

    - `"soft_full"`: full SOFT (Simple Omnibus in Text Format) files
      from GEO FTP site by DataSet (GDS) containging additionally
      contains up-to-date gene annotation for the DataSet Platform.

    - `"miniml"`: MINiML (MIAME Notation in Markup Language, pronounced
      miniml) is an XML format that incorporates experimental data and
      metadata. MINiML is essentially an XML rendering of SOFT format.

    - `"matrix"`: Series matrix file.

    - `"annot"`: annotation files for Platforms.

    - `"suppl"`: supplementary files.

  - For file retrieval from Accession Display Bar of GEO database:

    - `"text"`: machine-readable SOFT format (Simple Omnibus Format in
      Text).

    - `"xml"`: XML format.

    - `"html"`: human-readable format with hyperlinks (no downloadable
      entry available).

    The following table summarizes the compatibility between GEO
    accession types and file format options:

    |                            |     |     |     |     |
    |----------------------------|-----|-----|-----|-----|
    | format                     | GDS | GSE | GPL | GSM |
    | SOFT (soft)                | o   | o   | o   | x   |
    | SOFTFULL (soft_full)       | o   | x   | x   | x   |
    | MINiML (miniml)            | x   | o   | o   | x   |
    | Matrix (matrix)            | x   | o   | x   | x   |
    | Annotation (annot)         | x   | x   | o   | x   |
    | Supplementaryfiles (suppl) | x   | o   | o   | o   |
    | Html (html)                | o   | o   | o   | o   |
    | Text (text)                | x   | o   | o   | o   |
    | Xml (xml)                  | x   | o   | o   | o   |

- amount:

  A character specifying the amount of data (Only applicable to
  Accession Display Bar access):

  - `"none"`: Applicable only to DataSets; for DataSets, this is also
    the sole valid option.

  - `"brief"`: accession attributes only.

  - `"quick"`: accession attributes + first **20** rows of the data
    table.

  - `"data"`: omits the accession's attributes, showing only links to
    other accessions and the full data table.

  - `"full"`: accession attributes + complete data table.

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

## Value

A character of GEO URL.

## References

- <https://www.ncbi.nlm.nih.gov/geo/info/download.html>

- <https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi>

- <https://www.ncbi.nlm.nih.gov/geo/info/soft.html#format>

- [Programmatic access to GEO FTP
  site](https://ftp.ncbi.nlm.nih.gov/geo/README.txt)

## Examples

``` r
geo_url("GSE10")
#> [1] "https://ftp.ncbi.nlm.nih.gov/geo/series/GSEnnn/GSE10/soft/GSE10_family.soft.gz"
geo_url("gpl98")
#> [1] "https://ftp.ncbi.nlm.nih.gov/geo/platforms/GPLnnn/GPL98/soft/GPL98_family.soft.gz"
geo_url("GSM1")
#> [1] "https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSM1&targ=self&view=data&form=text"
geo_url("GDS10")
#> [1] "https://ftp.ncbi.nlm.nih.gov/geo/datasets/GDSnnn/GDS10/soft/GDS10.soft.gz"
```
