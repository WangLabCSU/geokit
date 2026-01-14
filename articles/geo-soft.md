# Download and Parse SOFT File from GEO database

``` r
library(geokit)
```

The GEO database provides SOFT (Simple Omnibus Format in Text) files for
GPL, GSM, and GDS entities. SOFT is designed for efficient batch
submission and download of data. It is a simple, line-based, plain text
format, which makes it easy to generate SOFT files from common
spreadsheet and database applications.

The `geo_soft` function allows you to download and preprocess SOFT
files. Here are some example codes to download SOFT files for the GSM,
and GDS entities:

``` r
gsm <- geo_soft("GSM1", odir = tempdir())
#> Downloading 1 file
gsm
#> <GEOSoft> 
#> datatable: a 5494 * 3 data.frame
#>   datatable vars: TAG COUNT TPM
#> columns: a 3 * 1 data.frame
#>   columns vars: labelDescription
#> metadata: Sample_title Sample_geo_accession Sample_status ...
#>   Sample_series_id Sample_data_row_count (29 total)
#> accession: GSM1
```

``` r
gds <- geo_soft("GDS10", odir = tempdir())
#> Downloading 1 file
gds
#> <GEOSoft> 
#> datatable: a 39114 * 30 data.frame
#>   datatable vars: ID_REF IDENTIFIER GSM582 ... GSM602 GSM609 (30 total)
#> columns: a 30 * 1 data.frame
#>   columns vars: labelDescription
#> metadata: DATABASE DATASET SUBSET
#> accession: GDS10
```

A single SOFT file can contain both data tables and accompanying
descriptive information for multiple, concatenated Platforms, Samples,
and/or Series records. The `geokit` package provides a `GEOSoft` class
object to store SOFT file contents. The `GEOSoft` object contains six
slots: `accession`, `rcd_type`, `rcd_name`, `metadata`, `datatable`, and
`columns`.

- `accession`: Stores the GEO accession ID.

- `rcd_type`: Indicates the type of record (e.g., Platform, Sample,
  Series, Datasets). This helps categorize the data and identify the
  nature of the record.

- `rcd_name`: Represents the name associated with the record (e.g., the
  GEO dataset name). It usually matches the accession, but in some
  cases, it may differ. This allows for a more flexible identification
  of the record.

- `metadata`: Contains the header metadata from the SOFT file.

- `datatable`: Contains the main data table, which is the primary data
  for analysis.

- `columns`: Provides descriptive column headers for the datatable.

You can use functions with the same names as the slots to extract the
data.

``` r
head(datatable(gsm))
#>          TAG COUNT     TPM
#> 1 AAAAAAAAAA    17 1741.98
#> 2 AAAAAAATCA     1  102.47
#> 3 AAAAAAATTT     1  102.47
#> 4 AAAAAACAAA     1  102.47
#> 5 AAAAAACTCC     1  102.47
#> 6 AAAAAATAAA     1  102.47
head(columns(gsm))
#>         labelDescription
#> TAG   Ten base SAGE tag,
#> COUNT         TAG NUMBER
#> TPM     tags per million
```

``` r
head(datatable(gds))
#>   ID_REF    IDENTIFIER GSM582 GSM589 GSM583 GSM590 GSM584 GSM591 GSM585 GSM592
#> 1      1 1200011I18Rik    101     54    111     55     87     30     99     43
#> 2      2             2     26     23     30     27     19     22     32     19
#> 3      3       Ccdc28b     NA     NA     NA     NA     NA     NA     NA     NA
#> 4      4      AA014405    233    162    252    178    214    144    238    147
#> 5      5        Crebrf     NA     NA     NA     NA     NA     NA     NA     NA
#> 6      6             6    691    661    696    652    609    665    684    672
#>   GSM586 GSM593 GSM587 GSM594 GSM588 GSM595 GSM596 GSM603 GSM597 GSM604 GSM598
#> 1    105     56     43     14    112     43     97     36    117     40    125
#> 2     24     25     14     49     32     29     31     22     26     26     35
#> 3     NA     NA     NA      7     NA      4     10     22     NA     15     NA
#> 4    250    166     86     22    236    139    216    112    241    130    270
#> 5     NA     NA     NA     NA     NA      3     NA     NA     NA     NA     NA
#> 6    644    679    631    596    609    606    601    557    596    580    601
#>   GSM605 GSM599 GSM606 GSM600 GSM607 GSM601 GSM608 GSM602 GSM609
#> 1     45     99      1    109     38     87     18     72     16
#> 2     26     18     13     25     32     28     40     14     41
#> 3     23     NA     29      9     25     11     40     NA     22
#> 4    144    239    148    211    139    208     16    174     15
#> 5     NA     NA     NA     NA     NA     NA     NA     NA     NA
#> 6    554    562    561    580    568    519    562    497    564
head(columns(gds))
#>                                  labelDescription
#> ID_REF              Platform reference identifier
#> IDENTIFIER                             identifier
#> GSM582      Value for GSM582: NOD_S1; src: Spleen
#> GSM589      Value for GSM589: NOD_S2; src: Spleen
#> GSM583     Value for GSM583: Idd3_S1; src: Spleen
#> GSM590     Value for GSM590: Idd3_S2; src: Spleen
```

For the GPL entity, the structure differs from that of GSM and GDS. The
`geokit` package provides the `GEOPlatform` class to store the contents
of the GPL SOFT file. A GPL SOFT file typically includes most of the
contents found in its subset entities, including both GSE and GSM.
Therefore, the `GEOPlatform` class contains both `gse` and `gsm` slots,
each being a list of GEOSoft objects.

``` r
gpl <- geo_soft("gpl98", odir = tempdir())
#> Downloading 1 file
gpl
#> <GEOSoft> 
#> datatable: a 8934 * 16 data.frame
#>   datatable vars: ID GB_ACC SPOT_ID ... Gene Ontology Cellular
#>     Component Gene Ontology Molecular Function (16 total)
#> columns: a 16 * 1 data.frame
#>   columns vars: labelDescription
#> metadata: Platform_title Platform_geo_accession Platform_status ...
#>   Platform_series_id Platform_data_row_count (26 total)
#> accession: GPL98
```

Similarly, the GSE entity contains subset entities of GPL and GSM. The
`GEOSeries` class provides both `gpl` and `gsm` slots as lists of
GEOSoft objects.

``` r
gse <- geo_soft("GSE10", odir = tempdir())
#> Downloading 1 file
gse
#> <GEOSeries> 
#> gsm: GSM571 GSM572 GSM573 GSM574
#> gpl: GPL4
#> datatable: a 0 * 0 data.frame
#> columns: a 0 * 1 data.frame
#>   columns vars: labelDescription
#> metadata: DATABASE SERIES
#> accession: GSE10
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
#>  [1] digest_0.6.39     desc_1.4.3        R6_2.6.1          codetools_0.2-20 
#>  [5] fastmap_1.2.0     xfun_0.55         cachem_1.1.0      knitr_1.51       
#>  [9] htmltools_0.5.9   rmarkdown_2.30    lifecycle_1.0.5   cli_3.6.5        
#> [13] sass_0.4.10       pkgdown_2.2.0     data.table_1.18.0 textshaping_1.0.4
#> [17] jquerylib_0.1.4   systemfonts_1.3.1 compiler_4.5.2    tools_4.5.2      
#> [21] ragg_1.5.0        curl_7.0.0        evaluate_1.0.5    bslib_0.9.0      
#> [25] yaml_2.3.12       jsonlite_2.0.0    rlang_1.1.7       fs_1.6.6
```
