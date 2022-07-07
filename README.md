
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rgeo

<!-- badges: start -->

[![R-CMD-check](https://github.com/Yunuuuu/rgeo/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Yunuuuu/rgeo/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The goal of `rgeo` is to reduce the dependencies of
[`GEOquery`](https://github.com/seandavi/GEOquery) and provide a unified
R interface for most operation including both searching and downloading
in [GEO database](https://www.ncbi.nlm.nih.gov/geo/).

## Installation

You can install the development version of rgeo from
[GitHub](https://github.com/) with:

``` r
pak::pkg_install("Yunuuuu/rgeo")
```

## Features

-   Low dependency, using
    [`data.table`](https://github.com/Rdatatable/data.table) to
    implement all reading and preprocessing process. Reducing
    dependencies is the main purpose of this package since I have
    experienced several times of code failure after updating packages
    when using [`GEOquery`](https://github.com/seandavi/GEOquery).
-   Provide a searching interface of [GEO
    database](https://www.ncbi.nlm.nih.gov/geo/), in this way, we can
    filter the searching results using `R function`.
-   Provide some useful utils function to deal with GEO datasets like
    `parse_pdata`, `set_pdata`, `log_trans` and `show_geo`.

## Vignettes

``` r
library(rgeo)
```

### Search GEO database - `search_geo`

The NCBI uses a search term syntax which can be associated with a
specific search field with square brackets. So, for instance “Homo
sapiens\[ORGN\]” denotes a search for `Homo sapiens` in the “Organism”
field. Details see
<https://www.ncbi.nlm.nih.gov/geo/info/qqtutorial.html>. We can use the
same term to query our desirable results in `search_geo`. `search_geo`
will parse the searching results and return a data.frame containing all
the records based on the search term. The internal of `search_geo` is
based on [`rentrez`](https://github.com/ropensci/rentrez) package, which
provides functions that work with the [NCBI
Eutils](http://www.ncbi.nlm.nih.gov/books/NBK25500/) API, so we can
utilize `NCBI API key` to increase the downloading speed, details see
<https://docs.ropensci.org/rentrez/articles/rentrez_tutorial.html#rate-limiting-and-api-keys>.

Providing we want ***GSE*** GEO records related to ***human diabetes***,
we can get these records by this:

``` r
diabetes_gse_records <- search_geo(
    "diabetes[ALL] AND Homo sapiens[ORGN] AND GSE[ETYP]"
)
head(diabetes_gse_records)
#>                                                                                                                                         Title
#> 1         Bioinformatic analysis of the mechanism by which metformin enhances chemosensitivity of head and neck squamous cell carcinoma cells
#> 2                                    Glucagon-like Peptide-1 (GLP-1) Rescue Diabetic Cardiac Dysfuntions in Human iPSC-Derived Cardiomyocytes
#> 3                                           DNA Methylation Profiling Reveals Novel Pathway Implicated in Cardiovascular Diseases of Diabetes
#> 4                      Transcriptome analysis of Newly Diagnosed Type 2 Diabetes Subjects identifies genes to predict Metformin drug Response
#> 5 Hepatic senescence is associated with clinical progression of NAFLD/NASH: Role of BMP4 and its antagonist Gremlin1 (Visceral adipose cells)
#> 6                                                                              Single-cell Transcriptome Atlas of the Human Corpus Cavernosum
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    Summary
#> 1 Metformin is one of the first-line drugs for clinical treatment of type II diabetes, and recent studies have found that metformin can inhibit the development of multiple malignant tumors. When metformin is combined with chemotherapeutic drugs to treat head and neck squamous cell carcinoma（HNSCC）, it can effectively enhance the efficacy of chemotherapy. The aim of this study was to define the signaling pathways regulated by metformin in HNSCC, and the underlying mechanisms by which metformin sensitizes HNSCC chemotherapy. more...
#> 2                                                                                                                   We investigate the effects of GLP-1 on diabetic cardiomyocytes (DCMs) model established by human induced pluripotent stem cells-derived cardiomyocytes (iPSC-CMs). Two subtypes of GLP-1, GLP-17-36 and GLP-19-36, were evaluated for their efficacy on hypertrophic phenotype, impaired calcium homeostasis and electrophysiological properties. RNA-seq was performed to reveal the underlying molecular mechanism of GLP-1. more...
#> 3                                                                                                                                                                                      Epigenetics was reported to mediate the effects of environmental risk factors on disease pathogenesis. To unleash the role of DNA methylation modification in the pathological process of cardiovascular diseases in diabetes, we screened differentially methylated genes by methylated DNA immunoprecipitation chip (MeDIP-chip) among the enrolled participants.
#> 4                                                                                          Aims: Metformin is a widely used, primary drug of choice to treat individuals with type 2 diabetes (T2D). Clinically, inter-individual variability of drug response is of significant  concern. The targets and precise mechanisms of action for metformin is still under interrogation. In the present study, a whole transcriptome analysis was performed with an  intent to identify predictive biomarkers of metformin response in T2D individuals. more...
#> 5                                                                                                                                                                                                                                                                                                                                                                                              To understand the role of adipose tissue senescence in NAFLD/NASH,  RNA sequencing was performed in the visceral adipose tissue of NAFLD and NASH pateints.
#> 6                                                                                                                                                                                                                                                                                                                                                                                                              Single-cell transcriptomes of corpus cavernosum from three males with normal erections and five organic erectile dysfunction (ED) patients.
#>       Organism                                               Type Platforms
#> 1 Homo sapiens Expression profiling by high throughput sequencing  GPL20795
#> 2 Homo sapiens Expression profiling by high throughput sequencing  GPL11154
#> 3 Homo sapiens                     Methylation profiling by array  GPL16353
#> 4 Homo sapiens Expression profiling by high throughput sequencing  GPL17303
#> 5 Homo sapiens Expression profiling by high throughput sequencing  GPL16791
#> 6 Homo sapiens Expression profiling by high throughput sequencing  GPL24676
#>     Contains
#> 1  6 Samples
#> 2 16 Samples
#> 3  9 Samples
#> 4 30 Samples
#> 5 35 Samples
#> 6  8 Samples
#>                                                                 FTP download
#> 1       GEO (TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE207nnn/GSE207122/
#> 2       GEO (TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE197nnn/GSE197850/
#> 3 GEO (PAIR, TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE188nnn/GSE188395/
#> 4       GEO (TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE153nnn/GSE153315/
#> 5       GEO (TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE200nnn/GSE200678/
#> 6       GEO (CSV) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE206nnn/GSE206528/
#>   Series Accession        ID
#> 1        GSE207122 200207122
#> 2        GSE197850 200197850
#> 3        GSE188395 200188395
#> 4        GSE153315 200153315
#> 5        GSE200678 200200678
#> 6        GSE206528 200206528
#>                                             SRA Run Selector Project Datasets
#> 1                                                       <NA>    <NA>     <NA>
#> 2                                                       <NA>    <NA>     <NA>
#> 3                                                       <NA>    <NA>     <NA>
#> 4 https://www.ncbi.nlm.nih.gov/Traces/study/?acc=PRJNA642130    <NA>     <NA>
#> 5                                                       <NA>    <NA>     <NA>
#> 6                                                       <NA>    <NA>     <NA>
```

### download data from GEO database - `get_geo`
