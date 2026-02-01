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
#> ■■■■■■■■■■■■■■■■■■               1000/1776 [492/s] | ETA:  2s
#> → Parsing GEO records
#> ■■■■■■■■■■■■■■■■■■               1000/1776 [492/s] | ETA:  2s
#> Get records from NCBI for 1776 queries in 4.2s
#> 
head(out)
#>                                                                                                                     Title
#> 1                                         Stratifying High-Risk Prediabetes Clusters Using Blood-Based Epigenetic Markers
#> 2                                                        DNA methylation-based classification of hematolymphoid neoplasms
#> 3                                   Placental Remodeling in Gestational Diabetes Mellitus (GDM) Disrupts Lipid Metabolism
#> 4 Energy-sensing molecule RORγ regulates Cholesterol Metabolism and Immune Signaling in Diabetic Kidney Disease and Aging
#> 5                                                         iCLIP analysis of full-length and deletion mutants of myc-LARP6
#> 6 Extracellular Vesicles from Cytokine-Treated Human Pancreatic Ductal Cells Enhance HLA Class I Expression in Beta Cells
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            Summary
#> 1                                                                                                                                                                                                                                                                                                                                                                                        Previously, we identified six prediabetes clusters, three at moderate and three at high-risk for type 2 diabetes and/or complications. While this novel classification could enable earlier and improved disease prevention, it relies on intensive clinical phenotyping.
#> 2                                                                                                                     Accurate pathological diagnosis is crucial for optimal management of cancer patients. For a number of hematolymphoid tumor entities, standardization of the diagnostic process has been shown to be particularly challenging - with substantial inter-observer variability in the histopathological diagnosis of many tumor types. Genome-wide DNA methylation profiling has been shown to contribute to accurate and precise tumor classification and diagnosis in several tumor types, including central nervous system neoplasms. more...
#> 3                                                                                                                                                                                                                                      Gestational diabetes mellitus (GDM) is a pregnancy-specific metabolic disorder associated with adverse maternal and fetal outcomes, with epigenetic dysregulation increasingly implicated in fetal programming. As the placenta plays a central role in maternal–fetal nutrient and hormonal exchange, this study investigated structural, epigenetic, and metabolic alterations in placentas from GDM pregnancies. more...
#> 4                                                 Aging is a major risk factor for diabetic kidney disease (DKD), with both conditions exhibiting similar renal pathology. We identify the energy-sensing molecule Retinoic acid-related orphan receptor γ (RORγ) as significantly downregulated in diabetic and aged kidneys. Tubule-specific RORγ deficiency exacerbates kidney injury, whereas its overexpression protects. Mechanistically, RORγ stabilizes insulin-induced gene 1 (INSIG1) by upregulating the deubiquitinase YOD1 and enhancing AMPK activity via CAB39, which together promote INSIG1 phosphorylation and subsequent stabilization. more...
#> 5 Intrinsically disordered regions (IDRs) are prevalent in RNA-binding proteins (RBPs), yet their roles in RNA interactions remain poorly defined. We examined the structured and disordered RNA-binding activities of LARP6, an RBP with a diverse RNA-binding repertoire. U87 glioblastoma cells stably expressing myc-tagged full-length or various deletion mutants of LARP6 under a doxycycline switch were induced to express myc-LARP6 variants at near endogenous levels, before individual-nucleotide resolution UV-crosslinking and immunoprecipitation (iCLIP) was performed to assess each variants' RNA-binding targets on the transcriptome. more...
#> 6                                                                                    Introduction/Objective: Type 1 diabetes (T1D) is an autoimmune disease characterized by the loss of insulin-producing beta cells and has no cure. The role of cell-cell interactions in immune recognition of beta cells remains poorly understood. Beta cells develop adjacent to ductal cells, which undergo changes during T1D progression, suggesting crosstalk between the two cell types. Extracellular vesicles (EVs) mediate intercellular communication through their cargo, but whether human ductal cells secrete EVs that modulate beta cells is unknown. more...
#>       Organism
#> 1 Homo sapiens
#> 2 Homo sapiens
#> 3 Homo sapiens
#> 4 Homo sapiens
#> 5 Homo sapiens
#> 6 Homo sapiens
#>                                                                   Type
#> 1                         Methylation profiling by genome tiling array
#> 2 Methylation profiling by genome tiling array; Third-party reanalysis
#> 3                         Methylation profiling by genome tiling array
#> 4                   Expression profiling by high throughput sequencing
#> 5            Other; Expression profiling by high throughput sequencing
#> 6                   Expression profiling by high throughput sequencing
#>                                                                      FTP download
#> 1      GEO (CSV, IDAT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE315nnn/GSE315764/
#> 2 GEO (CSV, IDAT, TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE237nnn/GSE237299/
#> 3      GEO (IDAT, TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE317nnn/GSE317191/
#> 4            GEO (TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE317nnn/GSE317266/
#> 5       GEO (BED, TAB) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE297nnn/GSE297587/
#> 6            GEO (TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE316nnn/GSE316823/
#>          ID SRA Run Selector Project    Contains Datasets         Platforms
#> 1 200315764             <NA>    <NA> 333 Samples     <NA> GPL33022 GPL21145
#> 2 200237299             <NA>    <NA> 989 Samples     <NA> GPL13534 GPL23976
#> 3 200317191             <NA>    <NA>  11 Samples     <NA>          GPL33022
#> 4 200317266             <NA>    <NA>   6 Samples     <NA>          GPL28352
#> 5 200297587             <NA>    <NA>  30 Samples     <NA> GPL18573 GPL34284
#> 6 200316823             <NA>    <NA>   8 Samples     <NA>          GPL24676
#>   Series Accession
#> 1        GSE315764
#> 2        GSE237299
#> 3        GSE317191
#> 4        GSE317266
#> 5        GSE297587
#> 6        GSE316823
# }
```
