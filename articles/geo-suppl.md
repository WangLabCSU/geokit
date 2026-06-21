# Download Supplementary File from GEO database

``` r

library(geokit)
```

GEO stores raw data and processed sequence data files as the external
supplementary data files. Sometimes, we may want to preprocess and
normalize the rawdata by ourselves, in addition, it’s not uncommon that
a GSE entity series matrix won’t contain the expression matrix, which is
almost the case of high-throughout sequencing data. `geo_suppl` is
designed for these conditions. Usually, the expression matrix will be
provided in the GSE supplementary files or in the GSM supplementary
files.

If the expression matrix is given in the GSE supplementary files, we can
download it directly use `geo_suppl`, which will return a character
vector containing the path of downloaded files.

``` r

gse160724 <- geo_suppl(
  "GSE160724",
  pattern = "counts_anno",
  odir = tempdir()
)
#> Downloading 1 file
gse160724_suppl_data <- data.table::fread(gse160724)
head(gse160724_suppl_data[1:5])
#>    gene_id  NC_1  NC_2 shSRSF1_1 shSRSF1_2
#>     <char> <int> <int>     <int>     <int>
#> 1:    A1BG   189   179       299       310
#> 2:    A1CF     0     0         0         0
#> 3:     A2M     0     0         0         0
#> 4:   A2ML1     0     0         0         0
#> 5: A3GALT2     0     1         0         0
#>                                                          Dbxref
#>                                                          <char>
#> 1:          GeneID:1,Genbank:NM_130786.3,HGNC:HGNC:5,MIM:138670
#> 2:             GeneID:29974,Genbank:NM_138933.2,HGNC:HGNC:24086
#> 3:       GeneID:2,Genbank:NM_001347423.1,HGNC:HGNC:7,MIM:103950
#> 4: GeneID:144568,Genbank:NM_144670.5,HGNC:HGNC:23336,MIM:610627
#> 5:         GeneID:127550,Genbank:NM_001080438.1,HGNC:HGNC:30005
#>                              product
#>                               <char>
#> 1:            alpha-1-B glycoprotein
#> 2:    APOBEC1 complementation factor
#> 3:             alpha-2-macroglobulin
#> 4:      alpha-2-macroglobulin like 1
#> 5: alpha 1,3-galactosyltransferase 2
#>                                                                                                                       GO_id
#>                                                                                                                      <char>
#> 1:                                                                                                                         
#> 2:            GO:0003723,GO:0003727,GO:0005654,GO:0005737,GO:0005783,GO:0006397,GO:0016554,GO:0016556,GO:0030895,GO:0050821
#> 3:                                                                                                                         
#> 4:                                                                   GO:0004867,GO:0005615,GO:0030414,GO:0052548,GO:0070062
#> 5: GO:0005794,GO:0005975,GO:0006688,GO:0009247,GO:0016021,GO:0016757,GO:0030259,GO:0031982,GO:0032580,GO:0046872,GO:0047276
#>                                                                                                                                                                                                                                                                                                                                       GO_term
#>                                                                                                                                                                                                                                                                                                                                        <char>
#> 1:                                                                                                                                                                                                                                                                                                                                           
#> 2:                                                                                                                       RNA binding|single-stranded RNA binding|nucleoplasm|cytoplasm|endoplasmic reticulum|mRNA processing|cytidine to uridine editing|mRNA modification|apolipoprotein B mRNA editing enzyme complex|protein stabilization
#> 3:                                                                                                                                                                                                                                                                                                                                           
#> 4:                                                                                                                                                                                   serine-type endopeptidase inhibitor activity|extracellular space|peptidase inhibitor activity|regulation of endopeptidase activity|extracellular exosome
#> 5: Golgi apparatus|carbohydrate metabolic process|glycosphingolipid biosynthetic process|glycolipid biosynthetic process|integral component of membrane|transferase activity, transferring glycosyl groups|lipid glycosylation|vesicle|Golgi cisterna membrane|metal ion binding|N-acetyllactosaminide 3-alpha-galactosyltransferase activity
#>     pathway                                        pathway_description
#>      <char>                                                     <char>
#> 1:                                                                    
#> 2:                                                                    
#> 3: hsa04610                        Complement and coagulation cascades
#> 4:                                                                    
#> 5: hsa00603 Glycosphingolipid biosynthesis - globo and isoglobo series
```

## sessionInfo

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
#>  [1] cli_3.6.6         knitr_1.51        rlang_1.2.0       xfun_0.59        
#>  [5] otel_0.2.0        textshaping_1.0.5 jsonlite_2.0.0    data.table_1.18.4
#>  [9] htmltools_0.5.9   ragg_1.5.2        sass_0.4.10       rmarkdown_2.31   
#> [13] evaluate_1.0.5    jquerylib_0.1.4   fastmap_1.2.0     yaml_2.3.12      
#> [17] lifecycle_1.0.5   compiler_4.6.0    codetools_0.2-20  fs_2.1.0         
#> [21] R.oo_1.27.1       R.utils_2.13.0    systemfonts_1.3.2 digest_0.6.39    
#> [25] R6_2.6.1          curl_7.1.0        R.methodsS3_1.8.2 bslib_0.11.0     
#> [29] tools_4.6.0       pkgdown_2.2.0     xml2_1.5.2        cachem_1.1.0     
#> [33] desc_1.4.3
```
