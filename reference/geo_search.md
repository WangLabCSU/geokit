# Search GEO database

Search the [GDS](https://www.ncbi.nlm.nih.gov/gds) database and return
search results as a data frame.

## Usage

``` r
geo_search(query, step = 500L, interval = NULL)
```

## Arguments

- query:

  A character string with the search term. The NCBI uses a fielded
  search syntax. For example, `"Homo sapiens[ORGN]"` searches the
  "Organism" field for *Homo sapiens*. See the [GEO query
  tutorial](https://www.ncbi.nlm.nih.gov/geo/info/qqtutorial.html) for
  details. Searchable fields can be listed with
  [`rentrez::entrez_db_searchable("gds")`](https://docs.ropensci.org/rentrez/reference/entrez_db_searchable.html).

- step:

  Integer. Number of records to fetch per request. Use a smaller value
  if requests fail.

- interval:

  Numeric. Time interval (in seconds) between successive requests.
  Defaults to `0`. Increase this value if requests fail due to rate
  limits.

## Value

A data frame contains the search results

## Details

The NCBI allows higher request limits (10 per second) when using an API
key. You can set this key for the current R session with
[`rentrez::set_entrez_key()`](https://docs.ropensci.org/rentrez/reference/set_entrez_key.html),
or permanently by setting the `ENTREZ_KEY` environment variable via
[Sys.setenv()](https://rdrr.io/r/base/Sys.setenv.html). Once set,
`rentrez` will automatically use this key for all NCBI requests. See the
[rentrez
tutorial](https://docs.ropensci.org/rentrez/articles/rentrez_tutorial.html#rate-limiting-and-api-keys)
for details.

## Examples

``` r
# Ensure you have an active internet connection before running the search.
# The `geo_search` function queries NCBI Entrez, which may have network
# restrictions and limited bandwidth usage for large queries.
# \donttest{
out <- geo_search("diabetes[ALL] AND Homo sapiens[ORGN] AND GSE[ETYP]")
#> ■■■■■■■■■                        500/1854 [410/s] | ETA:  3s
#> ■■■■■■■■■■■■■■■■■                1000/1854 [314/s] | ETA:  3s
#> ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■  1855/1854 [305/s] | ETA:  0s
#> → Parsing GEO records
#> ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■  1855/1854 [305/s] | ETA:  0s
#> Get records from NCBI for 1854 queries in 6.2s
#> 
head(out)
#>                                                                                                               Title
#> 1                  Transcriptomic Profiling of HRMVPC and HRMEC Co-culture Under Normal and High Glucose Conditions
#> 2 EZH2 inhibition via GSK-126 mitigates EndMT and atherosclerosis in diabetes: A translational epigenetic approach.
#> 3                                       Transcriptomic profiling of human placenta in gestational diabetes mellitus
#> 4                                     Dynamic remodeling of the pancreas immune landscape in obesity [bulk RNA-seq]
#> 5                                        Dynamic remodeling of the pancreas immune landscape in obesity. [CITE-Seq]
#> 6                                                   Dynamic remodeling of the pancreas immune landscape in obesity.
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   Summary
#> 1                                                                          We investigated the transcriptomic alterations in human retinal microvascular pericytes (HRMVPC-Immortalized) exposed to normal and high glucose conditions, with or without co-culture with human retinal microvascular endothelial cells (HRMEC-Immortalized). The study aimed to elucidate how glucose levels and endothelial interaction influence pericyte gene expression, providing insights into the cellular mechanisms potentially involved in diabetic retinopathy.
#> 2  Atherosclerosis drives cardiovascular morbidity in diabetes, with endothelial-to-mesenchymal transition (EndMT) as a key contributor. While epigenetic regulators are increasingly implicated in atherosclerotic progression, the specific role of Enhancer of Zeste Homolog 2 (EZH2), a histone methyltransferase, in EndMT in diabetes-associated atherosclerosis remains unclear. We show that EZH2-mediated H3K27 trimethylation is elevated in carotid plaques from diabetic patients and in aortic endothelium of diabetic Apoe-/- mice. more...
#> 3                                                                                                                                                                                                                                                                                                                                                                                                      We performed transcriptomics analysis on the placental tissues from gestational diabetes mellitus (GDM) patients and normal pregnant participants.
#> 4 Obesity is a known risk factor for diseases of the pancreas, including diabetes, pancreatic cancer and pancreatitis, but mechanisms remain unclear. To elucidate how obesity impacts pancreatic immune homeostasis, we performed spatial, transcriptomic and functional profiling of human pancreatic immune cells from obese and non-obese organ donors. Obesity was associated with higher density of tissue resident memory T-cells (TRM) in the exocrine pancreas which display high cytotoxic functions and aggregated around macrophages. more...
#> 5 Obesity is a known risk factor for diseases of the pancreas, including diabetes, pancreatic cancer and pancreatitis, but mechanisms remain unclear. To elucidate how obesity impacts pancreatic immune homeostasis, we performed spatial, transcriptomic and functional profiling of human pancreatic immune cells from obese and non-obese organ donors. Obesity was associated with higher density of tissue resident memory T-cells (TRM) in the exocrine pancreas which display high cytotoxic functions and aggregated around macrophages. more...
#> 6 Obesity is a known risk factor for diseases of the pancreas, including diabetes, pancreatic cancer and pancreatitis, but mechanisms remain unclear. To elucidate how obesity impacts pancreatic immune homeostasis, we performed spatial, transcriptomic and functional profiling of human pancreatic immune cells from obese and non-obese organ donors. Obesity was associated with higher density of tissue resident memory T-cells (TRM) in the exocrine pancreas which display high cytotoxic functions and aggregated around macrophages. more...
#>       Organism                                                      Type
#> 1 Homo sapiens        Expression profiling by high throughput sequencing
#> 2 Homo sapiens        Expression profiling by high throughput sequencing
#> 3 Homo sapiens        Expression profiling by high throughput sequencing
#> 4 Homo sapiens        Expression profiling by high throughput sequencing
#> 5 Homo sapiens Expression profiling by high throughput sequencing; Other
#> 6 Homo sapiens Expression profiling by high throughput sequencing; Other
#>                                                                     FTP download
#> 1           GEO (TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE298nnn/GSE298973/
#> 2           GEO (TSV) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE316nnn/GSE316326/
#> 3          GEO (XLSX) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE237nnn/GSE237061/
#> 4           GEO (CSV) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE306nnn/GSE306366/
#> 5 GEO (CSV, MTX, TSV) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE306nnn/GSE306178/
#> 6 GEO (CSV, MTX, TSV) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE305nnn/GSE305278/
#>          ID Project SRA Run Selector   Contains Datasets Platforms
#> 1 200298973    <NA>             <NA>  9 Samples     <NA>  GPL24676
#> 2 200316326    <NA>             <NA>  7 Samples     <NA>  GPL24676
#> 3 200237061    <NA>             <NA> 22 Samples     <NA>  GPL24676
#> 4 200306366    <NA>             <NA> 24 Samples     <NA>  GPL16791
#> 5 200306178    <NA>             <NA> 10 Samples     <NA>  GPL24676
#> 6 200305278    <NA>             <NA>  6 Samples     <NA>  GPL34281
#>   Series Accession
#> 1        GSE298973
#> 2        GSE316326
#> 3        GSE237061
#> 4        GSE306366
#> 5        GSE306178
#> 6        GSE305278
# }
```
