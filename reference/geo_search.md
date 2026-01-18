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
#> ■■■■■■■■■                        500/1767 [392/s] | ETA:  3s
#> ■■■■■■■■■■■■■■■■■■               1000/1767 [342/s] | ETA:  2s
#> ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■  1768/1767 [312/s] | ETA:  0s
#> → Parsing GEO records
#> ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■  1768/1767 [312/s] | ETA:  0s
#> Get records from NCBI for 1767 queries in 5.8s
#> 
head(out)
#>                                                                                                                                                                                        Title
#> 1 Multi-omics profiling reveals microbiota, metabolite, lipid, and immunological heterogeneity underlying distinct pathophysiological mechanisms of age-related endotypes in type 1 diabetes
#> 2                                                                      Cutaneous adipose tissue has a strong inflammatory signature in psoriasis patients, and it is partly IL-17 dependent.
#> 3                                                            Functional gene regulatory networks and broad applications of the human expandable pancreatic progenitor-islet system [RNA-Seq]
#> 4                                                         Functional gene regulatory networks and broad applications of the human expandable pancreatic progenitor-islet system [snATAC-seq]
#> 5                                                          Functional gene regulatory networks and broad applications of the human expandable pancreatic progenitor-islet system [scRNA-Seq]
#> 6                                                                      Metabolic surgery mitigates early kidney injury in obese youth with diabetes by suppressing mTORC1/JAK–STAT signaling
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           Summary
#> 1                                                                                     Type 1 diabetes (T1D) is an autoimmune disease characterized by marked heterogeneity in age at diagnosis, clinical progression, and immune pathology. Increasing evidence suggests that age-related T1D endotypes may reflect distinct underlying molecular mechanisms; however, these mechanisms remain incompletely characterized at the cellular and transcriptional levels. To investigate age-associated immune heterogeneity in T1D, peripheral blood mononuclear cells (PBMCs) were collected from a selected cohort of newly diagnosed pediatric individuals with T1D and healthy controls. more...
#> 2                                                                                                                                         Background: Psoriasis is an inflammatory skin disease associated with systemic inflammation and comorbidities such as diabetes and cardiovascular disease. Although the association between psoriasis and obesity has been studied extensively, the role of cutaneous adipose tissue (CAT) in pathogenesis of psoriasis remains unclear. Objectives This study aimed to provide a comprehensive evaluation of the CAT transcriptome in psoriasis patients and investigate the effects of IL-17 pathway blockade on adipose tissue inflammation. more...
#> 3 Investigating the precise gene regulatory programs directing pancreatic differentiation provides insights into the mechanisms of pancreatic development and diabetes progression. Here, we performed integrated single-cell multi-omic analyses of the expandable pancreatic progenitor (ePP)-islet system. We defined the dynamic transcriptomic and chromatin landscapes of pancreatic differentiation, inferred the sophisticated gene regulatory networks (GRNs) that govern ePP self-renewal, endocrine specification and islet function, and identified the essential roles and interesting mechanisms of the NKX2.2-CLEC16A/endosomal pathway axis during cell-fate transitions. more...
#> 4 Investigating the precise gene regulatory programs directing pancreatic differentiation provides insights into the mechanisms of pancreatic development and diabetes progression. Here, we performed integrated single-cell multi-omic analyses of the expandable pancreatic progenitor (ePP)-islet system. We defined the dynamic transcriptomic and chromatin landscapes of pancreatic differentiation, inferred the sophisticated gene regulatory networks (GRNs) that govern ePP self-renewal, endocrine specification and islet function, and identified the essential roles and interesting mechanisms of the NKX2.2-CLEC16A/endosomal pathway axis during cell-fate transitions. more...
#> 5 Investigating the precise gene regulatory programs directing pancreatic differentiation provides insights into the mechanisms of pancreatic development and diabetes progression. Here, we performed integrated single-cell multi-omic analyses of the expandable pancreatic progenitor (ePP)-islet system. We defined the dynamic transcriptomic and chromatin landscapes of pancreatic differentiation, inferred the sophisticated gene regulatory networks (GRNs) that govern ePP self-renewal, endocrine specification and islet function, and identified the essential roles and interesting mechanisms of the NKX2.2-CLEC16A/endosomal pathway axis during cell-fate transitions. more...
#> 6                              Background Youth with type 2 diabetes (T2D) and severe obesity face high risk of diabetic kidney disease, which metabolic bariatric surgery (MBS) can mitigate. This study explores structural and molecular changes in kidneys after vertical sleeve gastrectomy (VSG), a form of MBS. Methods Paired analyses, including metabolic profiling, kidney volume assessment, histological evaluation, and single-cell RNA sequencing (scRNAseq) on kidney biopsies from five youth with T2D and obesity pre- and 12 months post-VSG in the IMPROVE-T2D (Impact of Metabolic surgery on Pancreatic, Renal and cardiOVascular hEalth in youth with T2D) cohort. more...
#>       Organism                                                             Type
#> 1 Homo sapiens               Expression profiling by high throughput sequencing
#> 2 Homo sapiens               Expression profiling by high throughput sequencing
#> 3 Homo sapiens               Expression profiling by high throughput sequencing
#> 4 Homo sapiens Genome binding/occupancy profiling by high throughput sequencing
#> 5 Homo sapiens               Expression profiling by high throughput sequencing
#> 6 Homo sapiens               Expression profiling by high throughput sequencing
#>                                                                         FTP download
#> 1          GEO (MTX, TSV) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE316nnn/GSE316337/
#> 2               GEO (CSV) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE287nnn/GSE287022/
#> 3               GEO (TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE284nnn/GSE284159/
#> 4 GEO (CSV, H5, TBI, TSV) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE284nnn/GSE284103/
#> 5          GEO (MTX, TSV) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE284nnn/GSE284101/
#> 6          GEO (MTX, TSV) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE315nnn/GSE315877/
#>          ID SRA Run Selector Project    Contains Datasets Platforms
#> 1 200316337             <NA>    <NA>  54 Samples     <NA>  GPL24676
#> 2 200287022             <NA>    <NA> 241 Samples     <NA>  GPL24676
#> 3 200284159             <NA>    <NA>  12 Samples     <NA>  GPL24676
#> 4 200284103             <NA>    <NA>   3 Samples     <NA>  GPL21697
#> 5 200284101             <NA>    <NA>   5 Samples     <NA>  GPL21697
#> 6 200315877             <NA>    <NA>  16 Samples     <NA>  GPL11154
#>   Series Accession
#> 1        GSE316337
#> 2        GSE287022
#> 3        GSE284159
#> 4        GSE284103
#> 5        GSE284101
#> 6        GSE315877
# }
```
