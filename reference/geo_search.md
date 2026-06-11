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
#> ■■■■■■■■■                        500/1858 [395/s] | ETA:  3s
#> ■■■■■■■■■■■■■■■■■■■■■■■■■        1500/1858 [387/s] | ETA:  1s
#> → Parsing GEO records
#> ■■■■■■■■■■■■■■■■■■■■■■■■■        1500/1858 [387/s] | ETA:  1s
#> Get records from NCBI for 1858 queries in 4.9s
#> 
head(out)
#>                                                                                                                    Title
#> 1                                                                               Effect of HNF1A-MODY on stem cell islets
#> 2                                                                       Effect of HNF1A-MODY on stem cell islets [PGP-1]
#> 3          Single-cell transcriptomics reveals markers of regulatory T cell dysfunction in Gestational Diabetes Mellitus
#> 4 EIF1 coordinates transcriptomic and splicing networks associated with cell cycle dysregulation in diabetic retinopathy
#> 5                       Transcriptomic Profiling of HRMVPC and HRMEC Co-culture Under Normal and High Glucose Conditions
#> 6      EZH2 inhibition via GSK-126 mitigates EndMT and atherosclerosis in diabetes: A translational epigenetic approach.
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  Summary
#> 1              This project investigates the impact of the hotspot mutation P291fsinsC in HNF1A-MODY (Maturity-Onset Diabetes of the Young) on stem cell-derived islets. RNA sequencing (RNA-seq) was performed on islets differentiated from mutant and control HNF1A-MODY stem cells to study the mutation's effect on gene expression. By comparing the transcriptomic profiles of these islets, the study aims to uncover molecular mechanisms underlying the dysfunction caused by the P291fsinsC mutation during islet development and maturation.
#> 2              This project investigates the impact of the hotspot mutation P291fsinsC in HNF1A-MODY (Maturity-Onset Diabetes of the Young) on stem cell-derived islets. RNA sequencing (RNA-seq) was performed on islets differentiated from mutant and control HNF1A-MODY stem cells to study the mutation's effect on gene expression. By comparing the transcriptomic profiles of these islets, the study aims to uncover molecular mechanisms underlying the dysfunction caused by the P291fsinsC mutation during islet development and maturation.
#> 3                                                                                                                                                                 Gestational Diabetes Mellitus (GDM) is a common pregnancy complication and the role of regulatory T cells (Tregs) in this disease is ambiguous. This study aims to determine the aberrant transcriptional landscape in Tregs from GDM patients and controls. We identify gene expression programmes dysregulated in GDM Tregs and assess their utlilty as GDM biomarkers in bulk mRNA.
#> 4                                                                              EIF1, an RNA-binding protein implicated in multiple diseases, remains poorly characterized in diabetic retinopathy (DR). To investigate its role in DR, human retinal pigment epithelial cells (ARPE-19) were exposed to 50 mM glucose to model the condition. Under hyperglycemic conditions, EIF1 was knocked down using siRNA, followed by transcriptome sequencing (RNA-seq) to profile differentially expressed genes (DEGs) and alternative splicing events (ASEs).
#> 5                                                                         We investigated the transcriptomic alterations in human retinal microvascular pericytes (HRMVPC-Immortalized) exposed to normal and high glucose conditions, with or without co-culture with human retinal microvascular endothelial cells (HRMEC-Immortalized). The study aimed to elucidate how glucose levels and endothelial interaction influence pericyte gene expression, providing insights into the cellular mechanisms potentially involved in diabetic retinopathy.
#> 6 Atherosclerosis drives cardiovascular morbidity in diabetes, with endothelial-to-mesenchymal transition (EndMT) as a key contributor. While epigenetic regulators are increasingly implicated in atherosclerotic progression, the specific role of Enhancer of Zeste Homolog 2 (EZH2), a histone methyltransferase, in EndMT in diabetes-associated atherosclerosis remains unclear. We show that EZH2-mediated H3K27 trimethylation is elevated in carotid plaques from diabetic patients and in aortic endothelium of diabetic Apoe-/- mice. more...
#>       Organism                                                      Type
#> 1 Homo sapiens        Expression profiling by high throughput sequencing
#> 2 Homo sapiens        Expression profiling by high throughput sequencing
#> 3 Homo sapiens Expression profiling by high throughput sequencing; Other
#> 4 Homo sapiens        Expression profiling by high throughput sequencing
#> 5 Homo sapiens        Expression profiling by high throughput sequencing
#> 6 Homo sapiens        Expression profiling by high throughput sequencing
#>                                                                     FTP download
#> 1           GEO (CSV) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE312nnn/GSE312607/
#> 2          GEO (XLSX) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE285nnn/GSE285253/
#> 3 GEO (CSV, MTX, TSV) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE280nnn/GSE280975/
#> 4           GEO (TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE334nnn/GSE334496/
#> 5           GEO (TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE298nnn/GSE298973/
#> 6           GEO (TSV) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE316nnn/GSE316326/
#>          ID Project SRA Run Selector   Contains Datasets Platforms
#> 1 200312607    <NA>             <NA> 12 Samples     <NA>  GPL34284
#> 2 200285253    <NA>             <NA> 12 Samples     <NA>  GPL34284
#> 3 200280975    <NA>             <NA> 33 Samples     <NA>  GPL24676
#> 4 200334496    <NA>             <NA>  6 Samples     <NA>  GPL24676
#> 5 200298973    <NA>             <NA>  9 Samples     <NA>  GPL24676
#> 6 200316326    <NA>             <NA>  7 Samples     <NA>  GPL24676
#>   Series Accession
#> 1        GSE312607
#> 2        GSE285253
#> 3        GSE280975
#> 4        GSE334496
#> 5        GSE298973
#> 6        GSE316326
# }
```
