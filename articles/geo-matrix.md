# Download and Parse Seires matrix File from GEO database

``` r
library(geokit)
```

In many typical analysis workflows, a series matrix file is commonly
used. You can easily handle it in `geokit` using the `gse_matrix()`
function. The `gse_matrix()` function returns an `ExpressionSet` object,
which is compatible with many Bioconductor packages.

``` r
gse_matix <- geo_matrix("GSE180383", odir = tempdir())
#> Downloading 1 file
#> Warning: Multiple occurrences of ":" found in metadata characteristics
#> ℹ See column "characteristics_ch1" for details.
#> ℹ No Bioconductor annotation package available for platform "GPL21359".
#> Downloading 1 fileℹ annot file in FTP site for "GPL21359" is not available, will use data amount file from GEO Accession Site instead
#> Downloading 1 file✔ Parsing 1 Series matrix successfully!
gse_matix
#> ExpressionSet (storageMode: lockedEnvironment)
#> assayData: 0 features, 6 samples 
#>   element names: exprs 
#> protocolData: none
#> phenoData
#>   sampleNames: GSM5461787 GSM5461788 ... GSM5461792 (6 total)
#>   varLabels: title geo_accession ... supplementary_file_1 (39 total)
#>   varMetadata: labelDescription
#> featureData: none
#> experimentData: use 'experimentData(object)'
#>   pubMedIds: 34897855 
#> Annotation: GPL21359
```

When parsing `phenoData` from series matrix files, the `gse_matrix()`
function automatically discerns `characteristics_ch*` columns and parses
multiple traits from them. Each trait is named with the prefix `ch*`,
corresponding to the column name.

``` r
Biobase::pData(gse_matix)[c("ch1_cultivar", "ch1_genotypes")]
#>                                                              ch1_cultivar
#> GSM5461787 Charantais type: Cucumis melo L. subsp. melo var cantalupensis
#> GSM5461788 Charantais type: Cucumis melo L. subsp. melo var cantalupensis
#> GSM5461789 Charantais type: Cucumis melo L. subsp. melo var cantalupensis
#> GSM5461790 Charantais type: Cucumis melo L. subsp. melo var cantalupensis
#> GSM5461791 Charantais type: Cucumis melo L. subsp. melo var cantalupensis
#> GSM5461792 Charantais type: Cucumis melo L. subsp. melo var cantalupensis
#>                                                                                                                                                      ch1_genotypes
#> GSM5461787                                                                                                                                   CharMONO inbreed line
#> GSM5461788                                                                                                                                   CharMONO inbreed line
#> GSM5461789                                                                                                                                   CharMONO inbreed line
#> GSM5461790 CharMONO cmlhp1ab double mutant carrying EMS mutations for Cmlhp1a (G1970A, genomic position from ATG ) and cmlhp1b (C1930T genomic position from ATG )
#> GSM5461791 CharMONO cmlhp1ab double mutant carrying EMS mutations for Cmlhp1a (G1970A, genomic position from ATG ) and cmlhp1b (C1930T genomic position from ATG )
#> GSM5461792 CharMONO cmlhp1ab double mutant carrying EMS mutations for Cmlhp1a (G1970A, genomic position from ATG ) and cmlhp1b (C1930T genomic position from ATG )
```

By default, `gse_matrix()` attempts to map the GPL accession to a
Bioconductor annotation package. You can control this behavior using the
`add_gpl` parameter:

- Set `add_gpl = FALSE` to exclude feature information.
- Set `add_gpl = TRUE` to include platform information from GEO.

``` r
Biobase::annotation(gse_matix)
#> [1] "GPL21359"
```

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
#>  [1] cli_3.6.5           knitr_1.51          rlang_1.1.7        
#>  [4] xfun_0.56           generics_0.1.4      textshaping_1.0.4  
#>  [7] jsonlite_2.0.0      data.table_1.18.0   htmltools_0.5.9    
#> [10] ragg_1.5.0          sass_0.4.10         rmarkdown_2.30     
#> [13] Biobase_2.70.0      evaluate_1.0.5      jquerylib_0.1.4    
#> [16] fastmap_1.2.0       yaml_2.3.12         lifecycle_1.0.5    
#> [19] compiler_4.5.2      codetools_0.2-20    fs_1.6.6           
#> [22] systemfonts_1.3.1   digest_0.6.39       R6_2.6.1           
#> [25] curl_7.0.0          bslib_0.9.0         tools_4.5.2        
#> [28] xml2_1.5.2          pkgdown_2.2.0       BiocGenerics_0.56.0
#> [31] cachem_1.1.0        desc_1.4.3
```
