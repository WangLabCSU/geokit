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
#> ■■■■■■■■■                        500/1772 [392/s] | ETA:  3s
#> ■■■■■■■■■■■■■■■■■■■■■■■■■■       1500/1772 [330/s] | ETA:  1s
#> → Parsing GEO records
#> ■■■■■■■■■■■■■■■■■■■■■■■■■■       1500/1772 [330/s] | ETA:  1sGet records from NCBI for 1772 queries in 5.6s
head(diabetes_gse_records[1:5])
#>                                                                                                                                                                                        Title
#> 1                                                                    Energy-sensing molecule RORγ regulates Cholesterol Metabolism and Immune Signaling in Diabetic Kidney Disease and Aging
#> 2                                                                    Extracellular Vesicles from Cytokine-Treated Human Pancreatic Ductal Cells Enhance HLA Class I Expression in Beta Cells
#> 3                                          N-acetyl-L-cysteine ethyl ester (NACET) induces the transcription factor NRF2 in the retina and prevents its aging and diabetic retinopathy. [II]
#> 4                                           N-acetyl-L-cysteine ethyl ester (NACET) induces the transcription factor NRF2 in the retina and prevents its aging and diabetic retinopathy. [I]
#> 5                                                                                                         Zinc accumulation-induced integrated stress response triggers β-cell identity loss
#> 6 Multi-omics profiling reveals microbiota, metabolite, lipid, and immunological heterogeneity underlying distinct pathophysiological mechanisms of age-related endotypes in type 1 diabetes
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            Summary
#> 1 Aging is a major risk factor for diabetic kidney disease (DKD), with both conditions exhibiting similar renal pathology. We identify the energy-sensing molecule Retinoic acid-related orphan receptor γ (RORγ) as significantly downregulated in diabetic and aged kidneys. Tubule-specific RORγ deficiency exacerbates kidney injury, whereas its overexpression protects. Mechanistically, RORγ stabilizes insulin-induced gene 1 (INSIG1) by upregulating the deubiquitinase YOD1 and enhancing AMPK activity via CAB39, which together promote INSIG1 phosphorylation and subsequent stabilization. more...
#> 2                                    Introduction/Objective: Type 1 diabetes (T1D) is an autoimmune disease characterized by the loss of insulin-producing beta cells and has no cure. The role of cell-cell interactions in immune recognition of beta cells remains poorly understood. Beta cells develop adjacent to ductal cells, which undergo changes during T1D progression, suggesting crosstalk between the two cell types. Extracellular vesicles (EVs) mediate intercellular communication through their cargo, but whether human ductal cells secrete EVs that modulate beta cells is unknown. more...
#> 3                                                                                           Age-related macular degeneration (AMD) and diabetic retinopathy (DR) are leading causes of visual impairment in older people, with oxidative stress playing a central role in the development of these diseases. In fact, the cells of the retina are particularly susceptible to oxidative damage due to high metabolic activity and exposure to light. Glutathione (GSH), a key intracellular antioxidant, is essential for retinal protection but it becomes limited during aging and in diabetes patients. more...
#> 4                                                                                           Age-related macular degeneration (AMD) and diabetic retinopathy (DR) are leading causes of visual impairment in older people, with oxidative stress playing a central role in the development of these diseases. In fact, the cells of the retina are particularly susceptible to oxidative damage due to high metabolic activity and exposure to light. Glutathione (GSH), a key intracellular antioxidant, is essential for retinal protection but it becomes limited during aging and in diabetes patients. more...
#> 5                                              Pancreatic β cell identity loss is increasingly recognized as a critical pathogenic contributor to β cell failure in type 2 diabetes (T2D), but the specific mechanism remains to be elucidated. In this study, we demonstrate that zinc accumulation contributes to the β cell identity loss during diabetes progression in both human and mouse islets. Using a model of human embryonic stem cell-derived islets (SC-islets), we reveal that accumulated zinc triggers the integrated stress response (ISR) with elevated ATF4 expression in SC-β cells. more...
#> 6      Type 1 diabetes (T1D) is an autoimmune disease characterized by marked heterogeneity in age at diagnosis, clinical progression, and immune pathology. Increasing evidence suggests that age-related T1D endotypes may reflect distinct underlying molecular mechanisms; however, these mechanisms remain incompletely characterized at the cellular and transcriptional levels. To investigate age-associated immune heterogeneity in T1D, peripheral blood mononuclear cells (PBMCs) were collected from a selected cohort of newly diagnosed pediatric individuals with T1D and healthy controls. more...
#>       Organism                                               Type
#> 1 Homo sapiens Expression profiling by high throughput sequencing
#> 2 Homo sapiens Expression profiling by high throughput sequencing
#> 3 Homo sapiens Expression profiling by high throughput sequencing
#> 4 Homo sapiens Expression profiling by high throughput sequencing
#> 5 Homo sapiens Expression profiling by high throughput sequencing
#> 6 Homo sapiens Expression profiling by high throughput sequencing
#>                                                                FTP download
#> 1      GEO (TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE317nnn/GSE317266/
#> 2      GEO (TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE316nnn/GSE316823/
#> 3      GEO (TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE299nnn/GSE299876/
#> 4      GEO (TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE299nnn/GSE299875/
#> 5 GEO (MTX, TSV) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE236nnn/GSE236316/
#> 6 GEO (MTX, TSV) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE316nnn/GSE316337/
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
#> 1      Integrative RNA-seq and CLIP-seq analysis reveals hnRNP-F regulation of the TNFα/NFκB signaling in high glucose conditions
#> 2                                                  Effect of FGF9 on human renal tubular epithelial cells in high glucose culture
#> 3 Endothelial Kallikrein-Related Peptidase 8 Promotes Diabetic Nephropathy via Reducing SDC4 Expression and Enhancing LIF Release
#> 4       Upregulation of FGF13 promotes type 2 diabetic nephropathy by modulating glomerular endothelial mitochondrial homeostasis
#> 5                 Sodium Butyrate Ameliorates Renal Tubular Lipid Accumulation Through the PP2A-TFEB axis in Diabetic Nephropathy
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           Summary
#> 1                                                                                                                                                                                                                                             Using RNA-seq and ChIP-seq we found that we found that hnRNP-F may bind to lncRNA SNHG1 to negatively regulate the transcription of genes involved in the TNFα/NFκB signaling pathway in diabetic nephropathy. Our study suggests that hnRNP-F may play a role in diabetic nephropathy by regulating the differential expression and variable splicing of diabetic nephropathy-associated genes, especially those related to inflammatory response.
#> 2                                                                                                                                                                                                                                                                 Diabetic nephropathy is characterised by the accumulation of extracellular matrix in the glomerular tunica and tubular interstitium, which ultimately leads to excessive renal scarring and decreased excretory function. The main pathological changes of renal fibrosis are: glomerulosclerosis, tubulointerstitial fibrosis, infiltration of inflammatory mediators and activation of α-SMA-positive myofibroblasts. more...
#> 3                                                                                                                                                                                                                                                             The molecular mechanisms underlying diabetic nephropathy (DN) are poorly defined. We sought to investigate the roles of kallikrein-related peptidases (KLKs) in DN pathogenesis. Screening of renal tissue from diabetic mice revealed KLK8 as the most highly induced gene in KLK family. KLK8 expression was greater in glomerular endothelial cells (GECs) than other glomerular cells in DN patients and diabetic mice. more...
#> 4 Studies of diabetic glomerular injury raise the possibility of developing useful early biomarkers and therapeutic approaches for the treatment of type 2 diabetic nephropathy (T2DN). In this study, it is found that FGF13 expression is induced in glomerular endothelial cells (GECs) during T2DN progression, and endothelial-specific deletion of Fgf13 potentially alleviates T2DN damage. Fgf13 deficiency restores the expression of Parkin both in the cytosolic, mitochondrial, and nuclear fractions under diabetic conditions, resulting in improved mitochondrial homeostasis and endothelial barrier integrity due to promotion of mitophagy and inhibition of apoptosis. more...
#> 5                                                                                                                                                                                                                               Background: Diabetic kidney disease (DKD) is the leading cause of end-stage renal disease worldwide with limited treatment options. The intricate pathogenesis of dysregulated lipid metabolism leading to the development of DKD remains obscure. Lipophagy, which refers to the autophagic degradation of intracellular lipid droplets, has been found to be impaired in DKD, resulting in renal tubule dysfunction and ectopic lipid deposition (ELD). more...
#>       Organism                                               Type
#> 1 Homo sapiens Expression profiling by high throughput sequencing
#> 2 Homo sapiens Expression profiling by high throughput sequencing
#> 3 Homo sapiens Expression profiling by high throughput sequencing
#> 4 Homo sapiens Expression profiling by high throughput sequencing
#> 5 Homo sapiens Expression profiling by high throughput sequencing
#>                                                           FTP download
#> 1 GEO (TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE273nnn/GSE273001/
#> 2 GEO (TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE265nnn/GSE265918/
#> 3 GEO (TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE255nnn/GSE255028/
#> 4 GEO (TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE192nnn/GSE192889/
#> 5 GEO (TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE266nnn/GSE266108/
```

After applying the filter, we obtain 38 candidate datasets. This
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
#> R version 4.5.2 (2025-10-31)
#> Platform: x86_64-pc-linux-gnu
#> Running under: Ubuntu 24.04.3 LTS
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
#>  [1] vctrs_0.7.0       httr_1.4.7        cli_3.6.5         knitr_1.51       
#>  [5] rlang_1.1.7       xfun_0.56         stringi_1.8.7     generics_0.1.4   
#>  [9] textshaping_1.0.4 jsonlite_2.0.0    glue_1.8.0        htmltools_0.5.9  
#> [13] XML_3.99-0.20     ragg_1.5.0        sass_0.4.10       rmarkdown_2.30   
#> [17] tibble_3.3.1      evaluate_1.0.5    jquerylib_0.1.4   fastmap_1.2.0    
#> [21] yaml_2.3.12       lifecycle_1.0.5   stringr_1.6.0     compiler_4.5.2   
#> [25] dplyr_1.1.4       rentrez_1.2.4     codetools_0.2-20  fs_1.6.6         
#> [29] pkgconfig_2.0.3   systemfonts_1.3.1 digest_0.6.39     R6_2.6.1         
#> [33] tidyselect_1.2.1  pillar_1.11.1     curl_7.0.0        magrittr_2.0.4   
#> [37] bslib_0.9.0       withr_3.0.2       tools_4.5.2       pkgdown_2.2.0    
#> [41] cachem_1.1.0      desc_1.4.3
```
