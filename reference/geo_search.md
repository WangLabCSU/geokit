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
#> ■■■■■■■■■                        500/1777 [437/s] | ETA:  3s
#> ■■■■■■■■■■■■■■■■■■               1000/1777 [442/s] | ETA:  2s
#> ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■  1778/1777 [362/s] | ETA:  0s
#> → Parsing GEO records
#> ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■  1778/1777 [362/s] | ETA:  0s
#> Get records from NCBI for 1777 queries in 5s
#> 
head(out)
#>                                                                                                                     Title
#> 1               HIF regulatory network reflects kidney disease progression in diabetes and reversal with SGLT2 inhibition
#> 2                                         Stratifying High-Risk Prediabetes Clusters Using Blood-Based Epigenetic Markers
#> 3                                                        DNA methylation-based classification of hematolymphoid neoplasms
#> 4                                   Placental Remodeling in Gestational Diabetes Mellitus (GDM) Disrupts Lipid Metabolism
#> 5 Energy-sensing molecule RORγ regulates Cholesterol Metabolism and Immune Signaling in Diabetic Kidney Disease and Aging
#> 6                                                         iCLIP analysis of full-length and deletion mutants of myc-LARP6
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        Summary
#> 1 Hypoxia drives diabetic kidney disease (DKD) progression through Hypoxia Inducible Factor (HIF) signaling. The kidney’s cellular heterogeneity and complex architecture pose challenges for directly assessing the pharmacologic effects on kidney oxygenation and hypoxia responsive pathways in vivo, such as treatment with SGLT2 inhibitors (SGLT2i), presumed to impact kidney oxygenation. Using single-cell transcriptional profiling of kidney tissue from youth with type 2 diabetes (T2D) who showed minimal clinical evidence of DKD, we identified cell type enrichment of HIF regulated genes, findings that replicated in people with later stage DKD in the Kidney Precision Medicine Project (KPMP). more...
#> 2                                                                                                                                                                                                                                                                                                                                                                                                                                                    Previously, we identified six prediabetes clusters, three at moderate and three at high-risk for type 2 diabetes and/or complications. While this novel classification could enable earlier and improved disease prevention, it relies on intensive clinical phenotyping.
#> 3                                                                                                                                                                                 Accurate pathological diagnosis is crucial for optimal management of cancer patients. For a number of hematolymphoid tumor entities, standardization of the diagnostic process has been shown to be particularly challenging - with substantial inter-observer variability in the histopathological diagnosis of many tumor types. Genome-wide DNA methylation profiling has been shown to contribute to accurate and precise tumor classification and diagnosis in several tumor types, including central nervous system neoplasms. more...
#> 4                                                                                                                                                                                                                                                                                                  Gestational diabetes mellitus (GDM) is a pregnancy-specific metabolic disorder associated with adverse maternal and fetal outcomes, with epigenetic dysregulation increasingly implicated in fetal programming. As the placenta plays a central role in maternal–fetal nutrient and hormonal exchange, this study investigated structural, epigenetic, and metabolic alterations in placentas from GDM pregnancies. more...
#> 5                                                                                                             Aging is a major risk factor for diabetic kidney disease (DKD), with both conditions exhibiting similar renal pathology. We identify the energy-sensing molecule Retinoic acid-related orphan receptor γ (RORγ) as significantly downregulated in diabetic and aged kidneys. Tubule-specific RORγ deficiency exacerbates kidney injury, whereas its overexpression protects. Mechanistically, RORγ stabilizes insulin-induced gene 1 (INSIG1) by upregulating the deubiquitinase YOD1 and enhancing AMPK activity via CAB39, which together promote INSIG1 phosphorylation and subsequent stabilization. more...
#> 6                                                             Intrinsically disordered regions (IDRs) are prevalent in RNA-binding proteins (RBPs), yet their roles in RNA interactions remain poorly defined. We examined the structured and disordered RNA-binding activities of LARP6, an RBP with a diverse RNA-binding repertoire. U87 glioblastoma cells stably expressing myc-tagged full-length or various deletion mutants of LARP6 under a doxycycline switch were induced to express myc-LARP6 variants at near endogenous levels, before individual-nucleotide resolution UV-crosslinking and immunoprecipitation (iCLIP) was performed to assess each variants' RNA-binding targets on the transcriptome. more...
#>       Organism
#> 1 Homo sapiens
#> 2 Homo sapiens
#> 3 Homo sapiens
#> 4 Homo sapiens
#> 5 Homo sapiens
#> 6 Homo sapiens
#>                                                                   Type
#> 1                                                                Other
#> 2                         Methylation profiling by genome tiling array
#> 3 Methylation profiling by genome tiling array; Third-party reanalysis
#> 4                         Methylation profiling by genome tiling array
#> 5                   Expression profiling by high throughput sequencing
#> 6            Other; Expression profiling by high throughput sequencing
#>                                                                                                            FTP download
#> 1 GEO (CLOUPE, JPG, JSON, MTX, PARQUET, PNG, RDS, TIFF, TSV) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE317nnn/GSE317226/
#> 2                                            GEO (CSV, IDAT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE315nnn/GSE315764/
#> 3                                       GEO (CSV, IDAT, TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE237nnn/GSE237299/
#> 4                                            GEO (IDAT, TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE317nnn/GSE317191/
#> 5                                                  GEO (TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE317nnn/GSE317266/
#> 6                                             GEO (BED, TAB) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE297nnn/GSE297587/
#>          ID SRA Run Selector Project    Contains Datasets         Platforms
#> 1 200317226             <NA>    <NA>   4 Samples     <NA>          GPL34284
#> 2 200315764             <NA>    <NA> 333 Samples     <NA> GPL33022 GPL21145
#> 3 200237299             <NA>    <NA> 989 Samples     <NA> GPL13534 GPL23976
#> 4 200317191             <NA>    <NA>  11 Samples     <NA>          GPL33022
#> 5 200317266             <NA>    <NA>   6 Samples     <NA>          GPL28352
#> 6 200297587             <NA>    <NA>  30 Samples     <NA> GPL18573 GPL34284
#>   Series Accession
#> 1        GSE317226
#> 2        GSE315764
#> 3        GSE237299
#> 4        GSE317191
#> 5        GSE317266
#> 6        GSE297587
# }
```
