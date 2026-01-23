# Build Your Own GEOmetadb

If you are conducting bioinformatics research, especially when dealing
with GEO (Gene Expression Omnibus) data, you may have used the
[GEOmetadb](https://github.com/zhujack/GEOmetadb) package. While it was
once a great tool, unfortunately, it has not been updated for years.
Additionally, the `GEOmetadb` package is static, relying on the
developer to manually update it, which often results in incomplete or
outdated data.

**Why Build Your Own GEOmetadb?**

- **Focus on Your Research Area**: For example, diabetes, liver cancer,
  urothelial carcinoma, etc. You can aggregate and annotate all relevant
  Series, making it easier for subsequent bulk downloads, filtering, and
  reproducible analysis.
- **Flexible Offline Querying**: GEO’s web search is not flexible
  enough. After building your own database with `geokit`, you can use
  familiar tools like regular expressions or database queries (e.g.,
  grep, SQLite) to freely search and meet various needs.
- **Dynamic Updates and Incremental Sync**: Automate scripts to
  regularly update the database, ensuring that the data is always
  up-to-date and avoiding the hassle of manual updates.
- **Efficient Data Access**: After storing the data offline, query
  speeds are significantly improved, especially when handling large GEO
  Series datasets, saving both time and bandwidth.

`geokit` offers an efficient and straightforward method, with core
operations implemented in `rust`, allowing you to build your own
metadata database in just a few minutes. For example, processing 654
records takes around **30.5 seconds** if the data is already downloaded.

- Search the GEO database using **NCBI Eutils** and extract relevant
  metadata.
- Fetch the relevant **metadata** from the GEO database and save it
  locally to build your own `GEOmetadb`.
- Use R’s regular expressions, filtering features, or tools like Excel
  and SQLite to quickly search and analyze Series (GSE) and sample
  information.

## Search and Filter Single-Cell Studies of Urothelial Carcinoma

``` r
library(geokit)
```

### 1. Search for Related Series by Keywords (e.g., Bladder/Urothelial Cancer)

Based on the **NCBI Eutils** query, more details can be found here:
[Querying GEO
DataSets](https://www.ncbi.nlm.nih.gov/geo/info/qqtutorial.html)

``` r
uc_gse <- list(
    geo_search(
        "bladder cancer[ALL] AND Homo sapiens[ORGN] AND GSE[ETYP]"
    ),
    geo_search(
        "urothelial cancer[ALL] AND Homo sapiens[ORGN] AND GSE[ETYP]"
    )
)
#> ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■  627/626 [269/s] | ETA:  0s
#> → Parsing GEO records
#> ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■  627/626 [269/s] | ETA:  0sGet records from NCBI for 626 queries in 2.4s
#> 
#> → Parsing GEO records
uc_gse <- unique(dplyr::bind_rows(uc_gse))
```

### 2. Extract Sample Count from the “Contains” Field

``` r
uc_gse$number_of_samples <- stringr::str_match(
  uc_gse$Contains, "(\\d+) Samples?"
)[, 2L, drop = TRUE]

# Quick Statistics
max_samples <- max(as.numeric(uc_gse$number_of_samples), na.rm = TRUE)
median_samples <- median(as.numeric(uc_gse$number_of_samples), na.rm = TRUE)
top_series <- dplyr::slice_max(uc_gse, as.numeric(number_of_samples))
```

### 3. Fetch Series Metadata (Parallel Processing and Batch Saving to Local Directory)

``` r
uc_gse_meta <- geo_meta(uc_gse[["Series Accession"]],
  odir = "gse_urothelial_cancer"
)
```

### 4. Filter Possible Single-Cell Studies (Search for Keywords in Summary/Title/Design)

``` r
uc_gse_sc <- dplyr::filter(
  uc_gse_meta,
  dplyr::if_any(
    c(Series_summary, Series_title, Series_overall_design),
    grepl,
    pattern = "single[- ]cell|scRNA", ignore.case = TRUE
  )
) |>
  dplyr::mutate(
    number_of_samples = lengths(
      strsplit(Series_sample_id, "; ", fixed = TRUE)
    )
  )

# Output Results and Statistics
dplyr::slice_max(uc_gse_sc, number_of_samples)$Series_geo_accession
max(uc_gse_sc$number_of_samples, na.rm = TRUE)
median(uc_gse_sc$number_of_samples, na.rm = TRUE)
writexl::write_xlsx(uc_gse_sc, "uc_gse_sc.xlsx")
```

By following these steps, you have successfully created your own
`GEOmetadb`!

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
#> [25] rentrez_1.2.4     dplyr_1.1.4       fs_1.6.6          pkgconfig_2.0.3  
#> [29] systemfonts_1.3.1 digest_0.6.39     R6_2.6.1          tidyselect_1.2.1 
#> [33] pillar_1.11.1     curl_7.0.0        magrittr_2.0.4    bslib_0.9.0      
#> [37] tools_4.5.2       pkgdown_2.2.0     cachem_1.1.0      desc_1.4.3
```
