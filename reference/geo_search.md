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
#> ■■■■■■■■■■■■■■■■■                1000/1925 [486/s] | ETA:  2s
#> Get records from NCBI for 1925 queries in 4.5s
#> 
#> → Parsing GEO records
head(out)
#>                                                                                                                                                     Title
#> 1 Reduction of SIRPα connects podocyte metabolism dysfunction to inflammatory activation via promoting PKM2 nuclear translocation in diabetes nephropathy
#> 2                            A comprehensive epithelial and immune characterization of autoimmune gastritis reveals novel aspects of disease pathogenesis
#> 3      Human visceral adipose tissue NK cell subsets link immunometabolic inflammation to liver fibrosis and impaired weight loss after bariatric surgery
#> 4                                                                       A single-cell atlas of diabetes-associated remodeling in the human corneal limbus
#> 5                                                                                                    NOTCH3 variants cause familial partial lipodystrophy
#> 6    Genomic and epigenomic insights into purkinje and granule neurons in Alzheimer’s disease and related dementia using single-nucleus multiome analysis
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       Summary
#> 1                                                                                                                                                                                A central cause of diabetic nephropathy (DN) is podocyte injury. There are many factors causing podocyte injury in DN, such as hyperglycemia, oxidative stress and inflammation. In this study, a signal regulator protein α (SIRPα) was found to play a critical role in regulating podocyte metabolism, oxidative stress and inflammatory.
#> 2 Autoimmune gastritis (AIG) is an understudied, adaptive immune-mediated disease characterized by chronic gastric inflammation and autoreactive T and B cells. The epithelial-immune crosstalk leading to a pre-neoplastic environment in AIG is largely unexplored. We profiled the AIG milieu using single cell RNA sequencing (scRNA-seq), T cell receptor sequencing (TCR-seq), and flow cytometry from gastric corpus biopsies and peripheral blood of 5 healthy patients and 15 patients with established AIG. more...
#> 3                                                                                                         Obesity is associated with chronic inflammation in visceral adipose tissue (VAT), but the molecular mechanisms remain incompletely understood. We analyzed gene expression profiles of VAT obtained from individuals with obesity undergoing sleeve gastrectomy and non-obese controls using the Affymetrix Clariom S Human Array. Raw and processed microarray data are provided together with sample annotations.
#> 4                                                                 The limbus at the corneo-conjunctival junction is a complex niche of cell populations whose interactions and regulation affect the overall health of the cornea. Diabetes Mellitus (DM) is a systemic disease that can affect these functions of the limbus and lead to complications including epithelial defects and fragility, abnormal wound repair, and the dysfunction of limbal epithelial stem cells (LESC), known as diabetic keratopathy. more...
#> 5                                       Molecular defects in some ultra-rare subtypes of familial lipodystrophies remain unidentified. We identified novel NOTCH3 heterozygous variants in familial partial lipodystrophy (FPL) pedigrees. All variants were clustered in the heterodimerization domain of the negative regulatory region of NOTCH3. RNA-Seq of skin fibroblasts revealed significantly higher RNA expression of NOTCH3 and activation of widespread senescence pathways in the FPL patients versus controls.
#> 6                                     Although the human cerebellum is known to be neuropathologically impaired in Alzheimer’s disease (AD) and AD-related dementias (ADRD), the cell type-specific transcriptional and epigenomic changes that contribute to this pathology are not well understood. Here, we report single-nucleus multiome (snRNA-seq and snATAC-seq) analysis of 103,861 nuclei isolated from both cerebellum (n = 9) and frontal cortex (n = 6) of AD/ADRD patients and normal controls (n = 8). more...
#>       Organism
#> 1 Homo sapiens
#> 2 Homo sapiens
#> 3 Homo sapiens
#> 4 Homo sapiens
#> 5 Homo sapiens
#> 6 Homo sapiens
#>                                                                                                                   Type
#> 1                                                                   Expression profiling by high throughput sequencing
#> 2                                                            Other; Expression profiling by high throughput sequencing
#> 3                                                                                        Expression profiling by array
#> 4                                                                   Expression profiling by high throughput sequencing
#> 5                                                                   Expression profiling by high throughput sequencing
#> 6 Expression profiling by high throughput sequencing; Genome binding/occupancy profiling by high throughput sequencing
#>                                                                               FTP download
#> 1                     GEO (TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE246nnn/GSE246105/
#> 2      GEO (CSV, MTX, TSV, TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE350nnn/GSE350856/
#> 3                     GEO (CEL) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE339nnn/GSE339099/
#> 4                GEO (MTX, TSV) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE326nnn/GSE326016/
#> 5                     GEO (TAB) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE280nnn/GSE280409/
#> 6 GEO (H5, MTX, TAR, TSV, XLSX) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE331nnn/GSE331288/
#>          ID Project SRA Run Selector   Contains Datasets         Platforms
#> 1 200246105    <NA>             <NA>  4 Samples     <NA>          GPL16791
#> 2 200350856    <NA>             <NA> 55 Samples     <NA> GPL24676 GPL34284
#> 3 200339099    <NA>             <NA> 10 Samples     <NA>          GPL23159
#> 4 200326016    <NA>             <NA>  6 Samples     <NA>          GPL24676
#> 5 200280409    <NA>             <NA>  8 Samples     <NA>          GPL18573
#> 6 200331288    <NA>             <NA> 52 Samples     <NA>          GPL24676
#>   Series Accession
#> 1        GSE246105
#> 2        GSE350856
#> 3        GSE339099
#> 4        GSE326016
#> 5        GSE280409
#> 6        GSE331288
# }
```
