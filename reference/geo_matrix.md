# Retrieve Series Matrix and Create ExpressionSet

The function downloads and parses the relevant Series Matrix files,
optionally mapping platform IDs to Bioconductor annotation packages.

## Usage

``` r
geo_matrix(
  accession,
  add_gpl = NULL,
  pdata_from_soft = FALSE,
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

- add_gpl:

  Logical or `NULL`. Whether to include platform information (the
  [`featureData`](https://rdrr.io/pkg/Biobase/man/featureData.html)
  slot). If `NULL` (default), the function attempts to map the GPL
  accession to a Bioconductor annotation package. If successful, the
  [`annotation`](https://rdrr.io/pkg/Biobase/man/class.eSet.html) slot
  is updated and `add_gpl` is set to `FALSE`; otherwise, `add_gpl` is
  set to `TRUE`.

- pdata_from_soft:

  Logical. Specifies whether to derive `phenoData` from the GSE series
  SOFT file. Defaults to `FALSE`, in which case `phenoData` is parsed
  directly from the series matrix file. Set to `TRUE` if you encounter
  issues parsing `characteristics_ch*` columns correctly, as it will
  attempt to retrieve the data from the SOFT file instead.

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

An
[`ExpressionSet`](https://rdrr.io/pkg/Biobase/man/class.ExpressionSet.html)
or a list of `ExpressionSet`s, one per Series Matrix file.

## Examples

``` r
# \donttest{
if (require("Biobase")) {
    eset <- geo_matrix("GSE10", odir = tempdir())
}
#> Loading required package: Biobase
#> Loading required package: BiocGenerics
#> Loading required package: generics
#> 
#> Attaching package: ‘generics’
#> The following objects are masked from ‘package:base’:
#> 
#>     as.difftime, as.factor, as.ordered, intersect, is.element, setdiff,
#>     setequal, union
#> 
#> Attaching package: ‘BiocGenerics’
#> The following objects are masked from ‘package:stats’:
#> 
#>     IQR, mad, sd, var, xtabs
#> The following objects are masked from ‘package:base’:
#> 
#>     Filter, Find, Map, Position, Reduce, anyDuplicated, aperm, append,
#>     as.data.frame, basename, cbind, colnames, dirname, do.call,
#>     duplicated, eval, evalq, get, grep, grepl, is.unsorted, lapply,
#>     mapply, match, mget, order, paste, pmax, pmax.int, pmin, pmin.int,
#>     rank, rbind, rownames, sapply, saveRDS, table, tapply, unique,
#>     unsplit, which.max, which.min
#> Welcome to Bioconductor
#> 
#>     Vignettes contain introductory material; view with
#>     'browseVignettes()'. To cite Bioconductor, see
#>     'citation("Biobase")', and for packages 'citation("pkgname")'.
#> Downloading 1 file
#> ℹ No Bioconductor annotation package available for platform "GPL4".
#> Downloading 1 file
#> ℹ annot file for "GPL4" is not available on the FTP site.  Attempting to use the data amount file from the GEO Accession Site instead.
#> Downloading 1 file
#> Error in c("cli::cli_alert_info(paste(\"Failed to download annotation file for {.val {accession[!downloaded$success]}},\", ", "    \"Platform information will not be added.\"))"): ! Could not evaluate cli `{}` expression: `accession[!download…`.
#> Caused by error in `eval(expr, envir = envir)`:
#> ! object 'downloaded' not found
# }
```
