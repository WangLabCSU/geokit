# Search GEO

``` r

library(geokit)
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
#> ■■■■■■■■■                        500/1854 [436/s] | ETA:  3s
#> ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■  1855/1854 [355/s] | ETA:  0s
#> → Parsing GEO records
#> ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■  1855/1854 [355/s] | ETA:  0sGet records from NCBI for 1854 queries in 5.4s
head(diabetes_gse_records[1:5])
#>                                                                                                               Title
#> 1                  Transcriptomic Profiling of HRMVPC and HRMEC Co-culture Under Normal and High Glucose Conditions
#> 2 EZH2 inhibition via GSK-126 mitigates EndMT and atherosclerosis in diabetes: A translational epigenetic approach.
#> 3                                       Transcriptomic profiling of human placenta in gestational diabetes mellitus
#> 4                                     Dynamic remodeling of the pancreas immune landscape in obesity [bulk RNA-seq]
#> 5                                        Dynamic remodeling of the pancreas immune landscape in obesity. [CITE-Seq]
#> 6                                                   Dynamic remodeling of the pancreas immune landscape in obesity.
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   Summary
#> 1                                                                          We investigated the transcriptomic alterations in human retinal microvascular pericytes (HRMVPC-Immortalized) exposed to normal and high glucose conditions, with or without co-culture with human retinal microvascular endothelial cells (HRMEC-Immortalized). The study aimed to elucidate how glucose levels and endothelial interaction influence pericyte gene expression, providing insights into the cellular mechanisms potentially involved in diabetic retinopathy.
#> 2  Atherosclerosis drives cardiovascular morbidity in diabetes, with endothelial-to-mesenchymal transition (EndMT) as a key contributor. While epigenetic regulators are increasingly implicated in atherosclerotic progression, the specific role of Enhancer of Zeste Homolog 2 (EZH2), a histone methyltransferase, in EndMT in diabetes-associated atherosclerosis remains unclear. We show that EZH2-mediated H3K27 trimethylation is elevated in carotid plaques from diabetic patients and in aortic endothelium of diabetic Apoe-/- mice. more...
#> 3                                                                                                                                                                                                                                                                                                                                                                                                      We performed transcriptomics analysis on the placental tissues from gestational diabetes mellitus (GDM) patients and normal pregnant participants.
#> 4 Obesity is a known risk factor for diseases of the pancreas, including diabetes, pancreatic cancer and pancreatitis, but mechanisms remain unclear. To elucidate how obesity impacts pancreatic immune homeostasis, we performed spatial, transcriptomic and functional profiling of human pancreatic immune cells from obese and non-obese organ donors. Obesity was associated with higher density of tissue resident memory T-cells (TRM) in the exocrine pancreas which display high cytotoxic functions and aggregated around macrophages. more...
#> 5 Obesity is a known risk factor for diseases of the pancreas, including diabetes, pancreatic cancer and pancreatitis, but mechanisms remain unclear. To elucidate how obesity impacts pancreatic immune homeostasis, we performed spatial, transcriptomic and functional profiling of human pancreatic immune cells from obese and non-obese organ donors. Obesity was associated with higher density of tissue resident memory T-cells (TRM) in the exocrine pancreas which display high cytotoxic functions and aggregated around macrophages. more...
#> 6 Obesity is a known risk factor for diseases of the pancreas, including diabetes, pancreatic cancer and pancreatitis, but mechanisms remain unclear. To elucidate how obesity impacts pancreatic immune homeostasis, we performed spatial, transcriptomic and functional profiling of human pancreatic immune cells from obese and non-obese organ donors. Obesity was associated with higher density of tissue resident memory T-cells (TRM) in the exocrine pancreas which display high cytotoxic functions and aggregated around macrophages. more...
#>       Organism                                                      Type
#> 1 Homo sapiens        Expression profiling by high throughput sequencing
#> 2 Homo sapiens        Expression profiling by high throughput sequencing
#> 3 Homo sapiens        Expression profiling by high throughput sequencing
#> 4 Homo sapiens        Expression profiling by high throughput sequencing
#> 5 Homo sapiens Expression profiling by high throughput sequencing; Other
#> 6 Homo sapiens Expression profiling by high throughput sequencing; Other
#>                                                                     FTP download
#> 1           GEO (TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE298nnn/GSE298973/
#> 2           GEO (TSV) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE316nnn/GSE316326/
#> 3          GEO (XLSX) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE237nnn/GSE237061/
#> 4           GEO (CSV) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE306nnn/GSE306366/
#> 5 GEO (CSV, MTX, TSV) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE306nnn/GSE306178/
#> 6 GEO (CSV, MTX, TSV) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE305nnn/GSE305278/
```

Once you have the search results, you can filter them based on specific
criteria. For instance, to filter for GSE datasets that contain at least
6 diabetic nephropathy samples with expression profiling, use the
following code:

``` r

diabetes_nephropathy_gse_records <- diabetes_gse_records |>
  dplyr::mutate(
    number_of_samples = stringr::str_match(
      Contains, "(\\d+) Samples?"
    )[, 2L, drop = TRUE],
    number_of_samples = as.integer(number_of_samples)
  ) |>
  dplyr::filter(
    dplyr::if_any(
      c(Title, Summary),
      ~ stringr::str_detect(.x, "(?i)diabetes|diabetic")
    ),
    dplyr::if_any(
      c(Title, Summary),
      ~ stringr::str_detect(.x, "(?i)nephropathy")
    ),
    stringr::str_detect(Type, "(?i)expression profiling"),
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
#> [1] geokit_0.0.1.9000
#> 
#> loaded via a namespace (and not attached):
#>  [1] vctrs_0.7.3       httr_1.4.8        cli_3.6.6         knitr_1.51       
#>  [5] rlang_1.2.0       xfun_0.58         stringi_1.8.7     otel_0.2.0       
#>  [9] generics_0.1.4    textshaping_1.0.5 jsonlite_2.0.0    glue_1.8.1       
#> [13] htmltools_0.5.9   XML_3.99-0.23     ragg_1.5.2        sass_0.4.10      
#> [17] rmarkdown_2.31    tibble_3.3.1      evaluate_1.0.5    jquerylib_0.1.4  
#> [21] fastmap_1.2.0     yaml_2.3.12       lifecycle_1.0.5   stringr_1.6.0    
#> [25] compiler_4.6.0    dplyr_1.2.1       codetools_0.2-20  rentrez_1.2.4    
#> [29] fs_2.1.0          pkgconfig_2.0.3   systemfonts_1.3.2 digest_0.6.39    
#> [33] R6_2.6.1          tidyselect_1.2.1  pillar_1.11.1     curl_7.1.0       
#> [37] magrittr_2.0.5    bslib_0.11.0      withr_3.0.2       tools_4.6.0      
#> [41] pkgdown_2.2.0     cachem_1.1.0      desc_1.4.3
```
