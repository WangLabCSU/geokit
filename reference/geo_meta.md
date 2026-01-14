# Get the metadata of multiple GEO identities

This function is useful for combining with
[`geo_search()`](https://WangLabCSU.github.io/geokit/reference/geo_search.md)
to filter results, as
[`geo_search()`](https://WangLabCSU.github.io/geokit/reference/geo_search.md)
cannot retrieve the full metadata for all GEO identifiers. By default,
this function uses the `soft` format for GDS and GSE entities, and the
`full` amount of `text` format data for GPL and GSM entities.

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

  A character specifying either:

  - the file `format` on the GEO FTP server, or

  - the `amount` of data in the GEO Accession Display Bar.

  See
  [`geo_url()`](https://WangLabCSU.github.io/geokit/reference/geo_url.md)
  for details on the `format` and `amount` arguments.

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

## Examples

``` r
geo_meta("GSE10", odir = tempdir())
#> Found 1 file already downloaded
#>                   Database_name Database_institute
#> 1 Gene Expression Omnibus (GEO)       NCBI NLM NIH
#>                 Database_web_link       Database_email Series_title
#> 1 http://www.ncbi.nlm.nih.gov/geo geo@ncbi.nlm.nih.gov     eye-SAGE
#>   Series_geo_accession         Series_status Series_submission_date
#> 1                GSE10 Public on Oct 03 2001            Oct 03 2001
#>   Series_last_update_date Series_pubmed_id
#> 1             Apr 18 2012         11756676
#>                                                                                                                                                                                                                Series_summary
#> 1 Human retinal and RPE SAGE libraries.; Profile of the genes expressed in the human peripheral retina, macula, and retinal pigment epithelium determined through serial analysis of gene expression (SAGE).; Keywords: other
#>                    Series_type
#> 1 Expression profiling by SAGE
#>                                                   Series_contributor
#> 1 Dror,,Sharon; Seth,,Blackshaw; Constance,L,Cepko; Thaddeus,P,Dryja
#>                 Series_sample_id Series_contact_name
#> 1 GSM571; GSM572; GSM573; GSM574        Dror,,Sharon
#>           Series_contact_email Series_contact_phone Series_contact_fax
#> 1 dror_sharon@meei.harvard.edu         617-573-4347       617-573-3168
#>              Series_contact_laboratory Series_contact_department
#> 1 Ocular Molecular Genetics Laboratory                          
#>    Series_contact_institute Series_contact_address Series_contact_city
#> 1 Massachusetts Eye and Ear        243 Charles St.              Boston
#>   Series_contact_state Series_contact_zip/postal_code Series_contact_country
#> 1                   MA                          02114                    USA
#>            Series_contact_web_link Series_platform_id Series_platform_taxid
#> 1 http://eyegene.meei.harvard.edu/               GPL4                  9606
#>   Series_sample_taxid
#> 1                9606
#>                                                  Series_relation
#> 1 BioProject: https://www.ncbi.nlm.nih.gov/bioproject/PRJNA84465
```
