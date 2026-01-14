# Search GEO database

Search the [GDS](https://www.ncbi.nlm.nih.gov/gds) database and return
search results as a
[data.table](https://rdatatable.gitlab.io/data.table/reference/data.table.html).

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
#> ■■■■■■■■■                        500/1765 [458/s] | ETA:  3s
#> ■■■■■■■■■■■■■■■■■■               1000/1765 [395/s] | ETA:  2s
#> ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■  1766/1765 [405/s] | ETA:  0s
#> → Parsing GEO records
#> ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■  1766/1765 [405/s] | ETA:  0s
#> Get records from NCBI for 1765 queries in 4.5s
#> 
head(out)
#>                                                                                                                                Title
#> 1    Functional gene regulatory networks and broad applications of the human expandable pancreatic progenitor-islet system [RNA-Seq]
#> 2 Functional gene regulatory networks and broad applications of the human expandable pancreatic progenitor-islet system [snATAC-seq]
#> 3  Functional gene regulatory networks and broad applications of the human expandable pancreatic progenitor-islet system [scRNA-Seq]
#> 4              Metabolic surgery mitigates early kidney injury in obese youth with diabetes by suppressing mTORC1/JAK–STAT signaling
#> 5                    A stem cell knockout village reveals lineage rewiring and a non-canonical islet cell fate in monogenic diabetes
#> 6                                  Natural daylight during office hours improves glucose control and whole-body substrate metabolism
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           Summary
#> 1 Investigating the precise gene regulatory programs directing pancreatic differentiation provides insights into the mechanisms of pancreatic development and diabetes progression. Here, we performed integrated single-cell multi-omic analyses of the expandable pancreatic progenitor (ePP)-islet system. We defined the dynamic transcriptomic and chromatin landscapes of pancreatic differentiation, inferred the sophisticated gene regulatory networks (GRNs) that govern ePP self-renewal, endocrine specification and islet function, and identified the essential roles and interesting mechanisms of the NKX2.2-CLEC16A/endosomal pathway axis during cell-fate transitions. more...
#> 2 Investigating the precise gene regulatory programs directing pancreatic differentiation provides insights into the mechanisms of pancreatic development and diabetes progression. Here, we performed integrated single-cell multi-omic analyses of the expandable pancreatic progenitor (ePP)-islet system. We defined the dynamic transcriptomic and chromatin landscapes of pancreatic differentiation, inferred the sophisticated gene regulatory networks (GRNs) that govern ePP self-renewal, endocrine specification and islet function, and identified the essential roles and interesting mechanisms of the NKX2.2-CLEC16A/endosomal pathway axis during cell-fate transitions. more...
#> 3 Investigating the precise gene regulatory programs directing pancreatic differentiation provides insights into the mechanisms of pancreatic development and diabetes progression. Here, we performed integrated single-cell multi-omic analyses of the expandable pancreatic progenitor (ePP)-islet system. We defined the dynamic transcriptomic and chromatin landscapes of pancreatic differentiation, inferred the sophisticated gene regulatory networks (GRNs) that govern ePP self-renewal, endocrine specification and islet function, and identified the essential roles and interesting mechanisms of the NKX2.2-CLEC16A/endosomal pathway axis during cell-fate transitions. more...
#> 4                              Background Youth with type 2 diabetes (T2D) and severe obesity face high risk of diabetic kidney disease, which metabolic bariatric surgery (MBS) can mitigate. This study explores structural and molecular changes in kidneys after vertical sleeve gastrectomy (VSG), a form of MBS. Methods Paired analyses, including metabolic profiling, kidney volume assessment, histological evaluation, and single-cell RNA sequencing (scRNAseq) on kidney biopsies from five youth with T2D and obesity pre- and 12 months post-VSG in the IMPROVE-T2D (Impact of Metabolic surgery on Pancreatic, Renal and cardiOVascular hEalth in youth with T2D) cohort. more...
#> 5                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     This SuperSeries is composed of the SubSeries listed below.
#> 6                                                                                                                            Chronic lack of daylight is increasingly considered as a risk factor for metabolic diseases, such as type 2 diabetes (T2D). In a randomized cross-over design (NCT05263232), 13 individuals with T2D were exposed to natural daylight facilitated through windows vs. constant artificial lighting during office hours for 4.5 consecutive days. Continuous glucose monitoring revealed that participants spent more time in the normal glucose range and whole-body substrate metabolism shifted towards a greater reliance on fat oxidation upon daylight. more...
#>       Organism                                                             Type
#> 1 Homo sapiens               Expression profiling by high throughput sequencing
#> 2 Homo sapiens Genome binding/occupancy profiling by high throughput sequencing
#> 3 Homo sapiens               Expression profiling by high throughput sequencing
#> 4 Homo sapiens               Expression profiling by high throughput sequencing
#> 5 Homo sapiens               Expression profiling by high throughput sequencing
#> 6 Homo sapiens               Expression profiling by high throughput sequencing
#>                                                                         FTP download
#> 1               GEO (TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE284nnn/GSE284159/
#> 2 GEO (CSV, H5, TBI, TSV) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE284nnn/GSE284103/
#> 3          GEO (MTX, TSV) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE284nnn/GSE284101/
#> 4          GEO (MTX, TSV) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE315nnn/GSE315877/
#> 5                     GEO ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE315nnn/GSE315753/
#> 6               GEO (TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE309nnn/GSE309688/
#>          ID SRA Run Selector Project   Contains Datasets Platforms
#> 1 200284159             <NA>    <NA> 12 Samples     <NA>  GPL24676
#> 2 200284103             <NA>    <NA>  3 Samples     <NA>  GPL21697
#> 3 200284101             <NA>    <NA>  5 Samples     <NA>  GPL21697
#> 4 200315877             <NA>    <NA> 16 Samples     <NA>  GPL11154
#> 5 200315753             <NA>    <NA> 21 Samples     <NA>  GPL34281
#> 6 200309688             <NA>    <NA> 48 Samples     <NA>  GPL24676
#>   Series Accession
#> 1        GSE284159
#> 2        GSE284103
#> 3        GSE284101
#> 4        GSE315877
#> 5        GSE315753
#> 6        GSE309688
# }
```
