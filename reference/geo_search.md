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
#> ■■■■■■■■■                        500/1771 [385/s] | ETA:  3s
#> ■■■■■■■■■■■■■■■■■■               1000/1771 [353/s] | ETA:  2s
#> ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■  1772/1771 [367/s] | ETA:  0s
#> → Parsing GEO records
#> ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■  1772/1771 [367/s] | ETA:  0s
#> Get records from NCBI for 1771 queries in 5s
#> 
head(out)
#>                                                                                                                                                                                        Title
#> 1                                                                    Extracellular Vesicles from Cytokine-Treated Human Pancreatic Ductal Cells Enhance HLA Class I Expression in Beta Cells
#> 2                                          N-acetyl-L-cysteine ethyl ester (NACET) induces the transcription factor NRF2 in the retina and prevents its aging and diabetic retinopathy. [II]
#> 3                                           N-acetyl-L-cysteine ethyl ester (NACET) induces the transcription factor NRF2 in the retina and prevents its aging and diabetic retinopathy. [I]
#> 4                                                                                                         Zinc accumulation-induced integrated stress response triggers β-cell identity loss
#> 5 Multi-omics profiling reveals microbiota, metabolite, lipid, and immunological heterogeneity underlying distinct pathophysiological mechanisms of age-related endotypes in type 1 diabetes
#> 6                                                                      Cutaneous adipose tissue has a strong inflammatory signature in psoriasis patients, and it is partly IL-17 dependent.
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       Summary
#> 1                               Introduction/Objective: Type 1 diabetes (T1D) is an autoimmune disease characterized by the loss of insulin-producing beta cells and has no cure. The role of cell-cell interactions in immune recognition of beta cells remains poorly understood. Beta cells develop adjacent to ductal cells, which undergo changes during T1D progression, suggesting crosstalk between the two cell types. Extracellular vesicles (EVs) mediate intercellular communication through their cargo, but whether human ductal cells secrete EVs that modulate beta cells is unknown. more...
#> 2                                                                                      Age-related macular degeneration (AMD) and diabetic retinopathy (DR) are leading causes of visual impairment in older people, with oxidative stress playing a central role in the development of these diseases. In fact, the cells of the retina are particularly susceptible to oxidative damage due to high metabolic activity and exposure to light. Glutathione (GSH), a key intracellular antioxidant, is essential for retinal protection but it becomes limited during aging and in diabetes patients. more...
#> 3                                                                                      Age-related macular degeneration (AMD) and diabetic retinopathy (DR) are leading causes of visual impairment in older people, with oxidative stress playing a central role in the development of these diseases. In fact, the cells of the retina are particularly susceptible to oxidative damage due to high metabolic activity and exposure to light. Glutathione (GSH), a key intracellular antioxidant, is essential for retinal protection but it becomes limited during aging and in diabetes patients. more...
#> 4                                         Pancreatic β cell identity loss is increasingly recognized as a critical pathogenic contributor to β cell failure in type 2 diabetes (T2D), but the specific mechanism remains to be elucidated. In this study, we demonstrate that zinc accumulation contributes to the β cell identity loss during diabetes progression in both human and mouse islets. Using a model of human embryonic stem cell-derived islets (SC-islets), we reveal that accumulated zinc triggers the integrated stress response (ISR) with elevated ATF4 expression in SC-β cells. more...
#> 5 Type 1 diabetes (T1D) is an autoimmune disease characterized by marked heterogeneity in age at diagnosis, clinical progression, and immune pathology. Increasing evidence suggests that age-related T1D endotypes may reflect distinct underlying molecular mechanisms; however, these mechanisms remain incompletely characterized at the cellular and transcriptional levels. To investigate age-associated immune heterogeneity in T1D, peripheral blood mononuclear cells (PBMCs) were collected from a selected cohort of newly diagnosed pediatric individuals with T1D and healthy controls. more...
#> 6                                                     Background: Psoriasis is an inflammatory skin disease associated with systemic inflammation and comorbidities such as diabetes and cardiovascular disease. Although the association between psoriasis and obesity has been studied extensively, the role of cutaneous adipose tissue (CAT) in pathogenesis of psoriasis remains unclear. Objectives This study aimed to provide a comprehensive evaluation of the CAT transcriptome in psoriasis patients and investigate the effects of IL-17 pathway blockade on adipose tissue inflammation. more...
#>       Organism                                               Type
#> 1 Homo sapiens Expression profiling by high throughput sequencing
#> 2 Homo sapiens Expression profiling by high throughput sequencing
#> 3 Homo sapiens Expression profiling by high throughput sequencing
#> 4 Homo sapiens Expression profiling by high throughput sequencing
#> 5 Homo sapiens Expression profiling by high throughput sequencing
#> 6 Homo sapiens Expression profiling by high throughput sequencing
#>                                                                FTP download
#> 1      GEO (TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE316nnn/GSE316823/
#> 2      GEO (TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE299nnn/GSE299876/
#> 3      GEO (TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE299nnn/GSE299875/
#> 4 GEO (MTX, TSV) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE236nnn/GSE236316/
#> 5 GEO (MTX, TSV) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE316nnn/GSE316337/
#> 6      GEO (CSV) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE287nnn/GSE287022/
#>          ID SRA Run Selector Project    Contains Datasets Platforms
#> 1 200316823             <NA>    <NA>   8 Samples     <NA>  GPL24676
#> 2 200299876             <NA>    <NA>  18 Samples     <NA>  GPL18573
#> 3 200299875             <NA>    <NA>   6 Samples     <NA>  GPL18573
#> 4 200236316             <NA>    <NA>   2 Samples     <NA>  GPL30209
#> 5 200316337             <NA>    <NA>  54 Samples     <NA>  GPL24676
#> 6 200287022             <NA>    <NA> 241 Samples     <NA>  GPL24676
#>   Series Accession
#> 1        GSE316823
#> 2        GSE299876
#> 3        GSE299875
#> 4        GSE236316
#> 5        GSE316337
#> 6        GSE287022
# }
```
