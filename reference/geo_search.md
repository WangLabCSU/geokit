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
#> ■■■■■■■■■                        500/1863 [353/s] | ETA:  4s
#> ■■■■■■■■■■■■■■■■■■■■■■■■■        1500/1863 [360/s] | ETA:  1s
#> → Parsing GEO records
#> ■■■■■■■■■■■■■■■■■■■■■■■■■        1500/1863 [360/s] | ETA:  1s
#> Get records from NCBI for 1863 queries in 6.3s
#> 
head(out)
#>                                                                                                                                            Title
#> 1                Chromatin accessibility and transcriptomic changes underlying progression from islet autoantibody positivity to type 1 diabetes
#> 2                                            Transcriptomic changes underlying progression from islet autoantibody positivity to type 1 diabetes
#> 3                                   Chromatin accessibility changes underlying progression from islet autoantibody positivity to type 1 diabetes
#> 4 Integrative single-cell multi-omics profiling of human pancreatic islets identifies T1D-associated genes and regulatory signals  [single cell]
#> 5                                                          Regenerative macrophages enhance stem cell-derived beta-cell function and engraftment
#> 6                                                                                                       Effect of HNF1A-MODY on stem cell islets
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             Summary
#> 1                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       This SuperSeries is composed of the SubSeries listed below.
#> 2                                                                                                                                                                                                                                                                                                                                In this study, we we collected RNA-seq data from four different human immune cells (CD4+ T cells, CD8+ T cells,  B cells, NK ) to  assess gene expression changes during type 1 diabetes (T1D) disease progression
#> 3                                                                                        Type 1 diabetes (T1D) usually has a preclinical phase identified by the presence of circulating autoantibodies to pancreatic islet antigens, and most young children who have multiple autoantibodies progress to diabetes within 10 years. While autoantibodies denote underlying islet autoimmunity, how this process is initiated and then progresses to clinical diabetes on a background of genetic susceptibility is not clearly understood. more...
#> 4 Genome-wide association studies (GWAS) have identified over 100 signals associated with type 1 diabetes (T1D). However, it has been challenging to translate any given T1D GWAS signal into mechanistic insights, such as causal variants, their target genes, and the specific cell types involved. Here, we present a comprehensive multi-omic integrative analysis of single-cell/nucleus resolution profiles of gene expression and chromatin accessibility in human pancreatic islets under baseline and T1D-stimulating conditions. more...
#> 5                                                                                   The generation of insulin-producing beta cells from human embryonic stem cells (SC-β cells) holds promise for treating type 1 diabetes. Transplantation of SC-β cells is already in clinical testing, but generating mature cells with insulin-secreting properties similar to endogenous cells has been challenging. Since macrophages are essential for islet development, we hypothesized they could enhance SC-β-cell differentiation and function. more...
#> 6         This project investigates the impact of the hotspot mutation P291fsinsC in HNF1A-MODY (Maturity-Onset Diabetes of the Young) on stem cell-derived islets. RNA sequencing (RNA-seq) was performed on islets differentiated from mutant and control HNF1A-MODY stem cells to study the mutation's effect on gene expression. By comparing the transcriptomic profiles of these islets, the study aims to uncover molecular mechanisms underlying the dysfunction caused by the P291fsinsC mutation during islet development and maturation.
#>       Organism
#> 1 Homo sapiens
#> 2 Homo sapiens
#> 3 Homo sapiens
#> 4 Homo sapiens
#> 5 Homo sapiens
#> 6 Homo sapiens
#>                                                                                                                   Type
#> 1 Expression profiling by high throughput sequencing; Genome binding/occupancy profiling by high throughput sequencing
#> 2                                                                   Expression profiling by high throughput sequencing
#> 3                                                     Genome binding/occupancy profiling by high throughput sequencing
#> 4 Expression profiling by high throughput sequencing; Genome binding/occupancy profiling by high throughput sequencing
#> 5                                                                   Expression profiling by high throughput sequencing
#> 6                                                                   Expression profiling by high throughput sequencing
#>                                                           FTP download
#> 1 GEO (TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE178nnn/GSE178494/
#> 2 GEO (TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE178nnn/GSE178493/
#> 3 GEO (TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE178nnn/GSE178492/
#> 4 GEO (TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE335nnn/GSE335464/
#> 5 GEO (RDS) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE308nnn/GSE308718/
#> 6 GEO (CSV) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE312nnn/GSE312607/
#>          ID Project SRA Run Selector   Contains Datasets Platforms
#> 1 200178494    <NA>             <NA> 89 Samples     <NA>  GPL18573
#> 2 200178493    <NA>             <NA> 80 Samples     <NA>  GPL18573
#> 3 200178492    <NA>             <NA>  9 Samples     <NA>  GPL18573
#> 4 200335464    <NA>             <NA> 28 Samples     <NA>  GPL24676
#> 5 200308718    <NA>             <NA>  6 Samples     <NA>  GPL24676
#> 6 200312607    <NA>             <NA> 12 Samples     <NA>  GPL34284
#>   Series Accession
#> 1        GSE178494
#> 2        GSE178493
#> 3        GSE178492
#> 4        GSE335464
#> 5        GSE308718
#> 6        GSE312607
# }
```
