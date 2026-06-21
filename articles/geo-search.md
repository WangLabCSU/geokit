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
#> ■■■■■■■■■                        500/1863 [440/s] | ETA:  3s
#> ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■  1864/1863 [348/s] | ETA:  0s
#> → Parsing GEO records
#> ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■  1864/1863 [348/s] | ETA:  0sGet records from NCBI for 1863 queries in 5.5s
head(diabetes_gse_records[1:5])
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
#>                                                                                                                             Title
#> 1                                            DJ-1 alleviates high glucose-induced podocyte injury via activating ERK1/2 signaling
#> 2                               RBBP6 orchestrates diabetic endothelial dysfunction viadisrupting JUNB-centric chromatin topology
#> 3      Integrative RNA-seq and CLIP-seq analysis reveals hnRNP-F regulation of the TNFα/NFκB signaling in high glucose conditions
#> 4                                                  Effect of FGF9 on human renal tubular epithelial cells in high glucose culture
#> 5 Endothelial Kallikrein-Related Peptidase 8 Promotes Diabetic Nephropathy via Reducing SDC4 Expression and Enhancing LIF Release
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          Summary
#> 1 Diabetic nephropathy (DN) is one of the most common complications of diabetes. DJ-1 has been reported to participate in the response to renal ischemia/reperfusion (I/R) injury. However, the underlying mechanisms of DJ-1 in the regulation of high glucose-induced renal injury remain obscure. In this study, we performed RNA-seq to explore the function of high glucose on human podocyte cells (HPC), and found that high glucose widely regulated a variety of signaling pathways, including cell growth and death, signal transduction, etc. more...
#> 2  Diabetes mellitus, a chronic metabolic disease affecting over 536.6 million people globally, is closely associated with vascular endothelial dysfunction, an early hallmark of diabetic cardiovascular complications. This dysfunction is characterized by impaired endothelial nitric oxide synthase (eNOS) activity, reduced nitric oxide (NO) production, and diminished angiogenic capacity, ultimately contributing to tissue ischemia and complications such as diabetic nephropathy, coronary artery disease, and peripheral arterial disease. more...
#> 3                                                                                                            Using RNA-seq and ChIP-seq we found that we found that hnRNP-F may bind to lncRNA SNHG1 to negatively regulate the transcription of genes involved in the TNFα/NFκB signaling pathway in diabetic nephropathy. Our study suggests that hnRNP-F may play a role in diabetic nephropathy by regulating the differential expression and variable splicing of diabetic nephropathy-associated genes, especially those related to inflammatory response.
#> 4                                                                                                                                Diabetic nephropathy is characterised by the accumulation of extracellular matrix in the glomerular tunica and tubular interstitium, which ultimately leads to excessive renal scarring and decreased excretory function. The main pathological changes of renal fibrosis are: glomerulosclerosis, tubulointerstitial fibrosis, infiltration of inflammatory mediators and activation of α-SMA-positive myofibroblasts. more...
#> 5                                                                                                                            The molecular mechanisms underlying diabetic nephropathy (DN) are poorly defined. We sought to investigate the roles of kallikrein-related peptidases (KLKs) in DN pathogenesis. Screening of renal tissue from diabetic mice revealed KLK8 as the most highly induced gene in KLK family. KLK8 expression was greater in glomerular endothelial cells (GECs) than other glomerular cells in DN patients and diabetic mice. more...
#>                     Organism
#> 1               Homo sapiens
#> 2 Mus musculus; Homo sapiens
#> 3               Homo sapiens
#> 4               Homo sapiens
#> 5               Homo sapiens
#>                                                                                                                          Type
#> 1                                                                          Expression profiling by high throughput sequencing
#> 2 Expression profiling by high throughput sequencing; Genome binding/occupancy profiling by high throughput sequencing; Other
#> 3                                                                          Expression profiling by high throughput sequencing
#> 4                                                                          Expression profiling by high throughput sequencing
#> 5                                                                          Expression profiling by high throughput sequencing
#>                                                                       FTP download
#> 1             GEO (TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE307nnn/GSE307956/
#> 2 GEO (BIGWIG, BW, TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE291nnn/GSE291636/
#> 3             GEO (TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE273nnn/GSE273001/
#> 4             GEO (TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE265nnn/GSE265918/
#> 5             GEO (TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE255nnn/GSE255028/
```

After applying the filter, we obtain 40 candidate datasets. This
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
#> R version 4.6.0 (2026-04-24)
#> Platform: x86_64-pc-linux-gnu
#> Running under: Ubuntu 24.04.4 LTS
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
#> [1] stringr_1.6.0     geokit_0.0.1.9000
#> 
#> loaded via a namespace (and not attached):
#>  [1] vctrs_0.7.3       httr_1.4.8        cli_3.6.6         knitr_1.51       
#>  [5] rlang_1.2.0       xfun_0.59         stringi_1.8.7     otel_0.2.0       
#>  [9] generics_0.1.4    textshaping_1.0.5 jsonlite_2.0.0    glue_1.8.1       
#> [13] htmltools_0.5.9   XML_3.99-0.23     ragg_1.5.2        sass_0.4.10      
#> [17] rmarkdown_2.31    tibble_3.3.1      evaluate_1.0.5    jquerylib_0.1.4  
#> [21] fastmap_1.2.0     yaml_2.3.12       lifecycle_1.0.5   compiler_4.6.0   
#> [25] dplyr_1.2.1       codetools_0.2-20  rentrez_1.2.4     fs_2.1.0         
#> [29] pkgconfig_2.0.3   systemfonts_1.3.2 digest_0.6.39     R6_2.6.1         
#> [33] tidyselect_1.2.1  pillar_1.11.1     curl_7.1.0        magrittr_2.0.5   
#> [37] bslib_0.11.0      withr_3.0.3       tools_4.6.0       pkgdown_2.2.0    
#> [41] cachem_1.1.0      desc_1.4.3
```
