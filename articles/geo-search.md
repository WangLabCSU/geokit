# Search GEO

``` r

library(geokit)
library(stringr)
```

The NCBI uses a search term syntax which can be associated with a
specific search field enclosed by a pair of square brackets. So, for
instance `"Homo sapiens[ORGN]"` denotes a search for `Homo sapiens` in
the `"Organism"` field. Details see
<https://www.ncbi.nlm.nih.gov/geo/info/qqtutorial.html>. We can use the
same term to query our desirable results in
[`geo_search()`](https://WangLabCSU.github.io/geokit/reference/geo_search.md).
[`geo_search()`](https://WangLabCSU.github.io/geokit/reference/geo_search.md)
will parse the searching results and return a `data.frame` object
containing all the records based on the search term. The internal of
[`geo_search()`](https://WangLabCSU.github.io/geokit/reference/geo_search.md)
is based on [`rentrez`](https://github.com/ropensci/rentrez) package,
which provides functions working with the [NCBI
Eutils](http://www.ncbi.nlm.nih.gov/books/NBK25500/) API, so we can
utilize `NCBI API key` to increase the searching speed, details see
<https://docs.ropensci.org/rentrez/articles/rentrez_tutorial.html#rate-limiting-and-api-keys>.

Providing we want ***GSE*** GEO records related to ***human diabetes***,
we can get these records by following code, the returned object is a
`data.frame`:

``` r

diabetes_gse_records <- geo_search(
  "diabetes[ALL] AND Homo sapiens[ORGN] AND GSE[ETYP]"
)
#> ■■■■■■■■■                        500/1925 [340/s] | ETA:  4s
#> Get records from NCBI for 1925 queries in 5s
#> 
#> → Parsing GEO records
head(diabetes_gse_records[1:5])
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
```

Once you have the search results, you can filter them based on specific
criteria. For instance, to filter for GSE datasets that contain at least
6 diabetic nephropathy samples with expression profiling, use the
following code:

``` r

diabetes_nephropathy_gse_records <- diabetes_gse_records |>
  dplyr::mutate(
    number_of_samples = str_match(Contains, "(\\d+) Samples?")[
      , 2L,
      drop = TRUE
    ],
    number_of_samples = as.integer(number_of_samples)
  ) |>
  dplyr::filter(
    dplyr::if_any(
      c(Title, Summary),
      ~ str_detect(.x, regex("diabetes|diabetic", ignore_case = TRUE))
    ),
    dplyr::if_any(
      c(Title, Summary),
      ~ str_detect(.x, regex("nephropathy", ignore_case = TRUE))
    ),
    str_detect(Type, regex("expression profiling", ignore_case = TRUE)),
    number_of_samples >= 6L
  )
head(diabetes_nephropathy_gse_records[1:5, 1:5])
#>                                                                                                                        Title
#> 1                                        Single-nucleus transcriptomic landscape of human glomerular diseases [10x Genomics]
#> 2                                       DJ-1 alleviates high glucose-induced podocyte injury via activating ERK1/2 signaling
#> 3                          RBBP6 orchestrates diabetic endothelial dysfunction viadisrupting JUNB-centric chromatin topology
#> 4 Integrative RNA-seq and CLIP-seq analysis reveals hnRNP-F regulation of the TNFα/NFκB signaling in high glucose conditions
#> 5                                             Effect of FGF9 on human renal tubular epithelial cells in high glucose culture
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          Summary
#> 1                                                          Disease-specific similarities and differences in single-cell-level transcriptomic alterations in various glomerular diseases are necessary to understand the pathophysiology of kidney glomerular diseases. We analyzed single-nucleus RNA sequencing (snRNA-seq) data from 262,984 nuclei from kidney biopsy cores from 28 subjects with glomerular disease, including minimal change disease, membranous nephropathy, IgA nephropathy, and diabetic kidney disease and control individuals. more...
#> 2 Diabetic nephropathy (DN) is one of the most common complications of diabetes. DJ-1 has been reported to participate in the response to renal ischemia/reperfusion (I/R) injury. However, the underlying mechanisms of DJ-1 in the regulation of high glucose-induced renal injury remain obscure. In this study, we performed RNA-seq to explore the function of high glucose on human podocyte cells (HPC), and found that high glucose widely regulated a variety of signaling pathways, including cell growth and death, signal transduction, etc. more...
#> 3  Diabetes mellitus, a chronic metabolic disease affecting over 536.6 million people globally, is closely associated with vascular endothelial dysfunction, an early hallmark of diabetic cardiovascular complications. This dysfunction is characterized by impaired endothelial nitric oxide synthase (eNOS) activity, reduced nitric oxide (NO) production, and diminished angiogenic capacity, ultimately contributing to tissue ischemia and complications such as diabetic nephropathy, coronary artery disease, and peripheral arterial disease. more...
#> 4                                                                                                            Using RNA-seq and ChIP-seq we found that we found that hnRNP-F may bind to lncRNA SNHG1 to negatively regulate the transcription of genes involved in the TNFα/NFκB signaling pathway in diabetic nephropathy. Our study suggests that hnRNP-F may play a role in diabetic nephropathy by regulating the differential expression and variable splicing of diabetic nephropathy-associated genes, especially those related to inflammatory response.
#> 5                                                                                                                                Diabetic nephropathy is characterised by the accumulation of extracellular matrix in the glomerular tunica and tubular interstitium, which ultimately leads to excessive renal scarring and decreased excretory function. The main pathological changes of renal fibrosis are: glomerulosclerosis, tubulointerstitial fibrosis, infiltration of inflammatory mediators and activation of α-SMA-positive myofibroblasts. more...
#>                     Organism
#> 1               Homo sapiens
#> 2               Homo sapiens
#> 3 Mus musculus; Homo sapiens
#> 4               Homo sapiens
#> 5               Homo sapiens
#>                                                                                                                          Type
#> 1                                                                          Expression profiling by high throughput sequencing
#> 2                                                                          Expression profiling by high throughput sequencing
#> 3 Expression profiling by high throughput sequencing; Genome binding/occupancy profiling by high throughput sequencing; Other
#> 4                                                                          Expression profiling by high throughput sequencing
#> 5                                                                          Expression profiling by high throughput sequencing
#>                                                                       FTP download
#> 1        GEO (MTX, TSV) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE271nnn/GSE271188/
#> 2             GEO (TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE307nnn/GSE307956/
#> 3 GEO (BIGWIG, BW, TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE291nnn/GSE291636/
#> 4             GEO (TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE273nnn/GSE273001/
#> 5             GEO (TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE265nnn/GSE265918/
```

After applying the filter, we obtain 41 candidate datasets. This
filtering step significantly reduces the time spent manually reviewing
summary records.

You can also use
[`geo_meta()`](https://WangLabCSU.github.io/geokit/reference/geo_meta.md)
to dynamically create a self-knowledge-concerned database in real-time.
See
[`vignette("geometadb")`](https://WangLabCSU.github.io/geokit/articles/geometadb.md)
for details.

## Session Information

``` r

sessionInfo()
#> R version 4.6.1 (2026-06-24)
#> Platform: x86_64-pc-linux-gnu
#> Running under: Ubuntu 24.04.5 LTS
#> 
#> Matrix products: default
#> BLAS:   /usr/lib/x86_64-linux-gnu/openblas-pthread/libblas.so.3 
#> LAPACK: /usr/lib/x86_64-linux-gnu/openblas-pthread/libopenblasp-r0.3.26.so;  LAPACK version 3.12.0
#> 
#> locale:
#>  [1] LC_CTYPE=C.UTF-8       LC_NUMERIC=C           LC_TIME=C.UTF-8       
#>  [4] LC_COLLATE=C.UTF-8     LC_MONETARY=C.UTF-8    LC_MESSAGES=C.UTF-8   
#>  [7] LC_PAPER=C.UTF-8       LC_NAME=C              LC_ADDRESS=C          
#> [10] LC_TELEPHONE=C         LC_MEASUREMENT=C.UTF-8 LC_IDENTIFICATION=C   
#> 
#> time zone: UTC
#> tzcode source: system (glibc)
#> 
#> attached base packages:
#> [1] stats     graphics  grDevices utils     datasets  methods   base     
#> 
#> other attached packages:
#> [1] stringr_1.6.0 geokit_0.0.2 
#> 
#> loaded via a namespace (and not attached):
#>  [1] vctrs_0.7.3       httr_1.4.9        cli_3.6.6         knitr_1.52       
#>  [5] rlang_1.3.0       xfun_0.62         stringi_1.8.9     otel_0.2.0       
#>  [9] generics_0.1.4    textshaping_1.0.5 jsonlite_2.0.0    glue_1.8.1       
#> [13] htmltools_0.5.9   XML_3.99-0.25     ragg_1.5.2        sass_0.4.10      
#> [17] rmarkdown_2.32    tibble_3.3.1      evaluate_1.0.5    jquerylib_0.1.4  
#> [21] fastmap_1.2.0     yaml_2.3.12       lifecycle_1.0.5   compiler_4.6.1   
#> [25] dplyr_1.2.1       codetools_0.2-20  rentrez_1.2.4     fs_2.1.0         
#> [29] pkgconfig_2.0.3   systemfonts_1.3.2 digest_0.6.39     R6_2.6.1         
#> [33] tidyselect_1.2.1  pillar_1.11.1     curl_8.1.0        magrittr_2.0.5   
#> [37] bslib_0.12.0      withr_3.0.3       tools_4.6.1       pkgdown_2.2.1    
#> [41] cachem_1.1.0      desc_1.4.3
```
