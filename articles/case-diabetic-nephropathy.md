# Case Study: Diabetic Nephropathy Meta-Analysis

This vignette demonstrates a comprehensive meta-analysis workflow for
diabetic nephropathy (DN) gene expression datasets. We show how to
systematically search, filter, annotate, and visualize relevant GEO
datasets to prepare for downstream meta-analysis.

## Introduction

Diabetic nephropathy is a major complication of diabetes and a leading
cause of chronic kidney disease. Conducting a meta-analysis of gene
expression studies can help identify robust molecular signatures. This
workflow demonstrates how to use `geokit` to:

- Search GEO using multiple query strategies
- Build a customized metadata database
- Filter datasets by quality criteria
- Visualize dataset characteristics
- Prepare a curated list for downstream analysis

``` r

library(geokit)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
library(stringr)
library(ggplot2)
```

## 1. Multi-Strategy Dataset Discovery

Different researchers use varying terminology, so we query for both
“diabetic nephropathy” and “diabetic kidney disease” and merge the
results.

``` r

dn_search_terms <- c(
  "diabetic nephropathy[ALL] AND Homo sapiens[ORGN] AND GSE[ETYP]",
  "diabetic kidney disease[ALL] AND Homo sapiens[ORGN] AND GSE[ETYP]"
)

dn_gse_list <- lapply(dn_search_terms, geo_search)
#> → Parsing GEO records
#> → Parsing GEO records
dn_gse <- unique(dplyr::bind_rows(dn_gse_list))

cat(sprintf("Found %d unique GSE datasets\n", nrow(dn_gse)))
#> Found 133 unique GSE datasets
head(dn_gse[, 1:3])
#>                                                                                                                                                     Title
#> 1 Reduction of SIRPα connects podocyte metabolism dysfunction to inflammatory activation via promoting PKM2 nuclear translocation in diabetes nephropathy
#> 2                                  Transcriptional analyses reveal the molecular features that underlie established injury and disease progression in DKD
#> 3                                                Exercise Alleviates Diabetic Kidney Disease Through PPARδ-CPT1α pathway-dependent Fatty Acid β-oxidation
#> 4                                            Exercise Alleviates Diabetic Kidney Disease Through PPARδ-CPT1α pathway-dependent Fatty Acid β-oxidation [I]
#> 5      Single-cell RNA sequencing-based identification of novel podocyte injury-associated genes from isolated glomeruli of diabetic db/db mice [RNA-seq]
#> 6                                                Elevated glucose in kidney organoids induces tissue-intrinsic inflammation driving epithelial detachment
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 Summary
#> 1                                                                                                                                                                                                                                                                                                                          A central cause of diabetic nephropathy (DN) is podocyte injury. There are many factors causing podocyte injury in DN, such as hyperglycemia, oxidative stress and inflammation. In this study, a signal regulator protein α (SIRPα) was found to play a critical role in regulating podocyte metabolism, oxidative stress and inflammatory.
#> 2                                                     Diabetes is the leading cause of kidney failure in the developed world. Despite its importance, the molecular events driving the pathogenesis of diabetic kidney disease remain incompletely understood. Here we present a comprehensive exploration of the renal transcriptome in the largest cohort of patients with diabetic kidney disease to be transcriptionally profiled to date. Using RNA-Seq to profile 50 diabetic kidney and 13 healthy control biopsies, we link the renal transcriptome to baseline clinical and histologic parameters, as well as rates of kidney function loss over time. more...
#> 3                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           This SuperSeries is composed of the SubSeries listed below.
#> 4 Regular physical exercise has been regarded as an effective strategy in alleviating diabetic kidney disease, although the underlying mechanisms are only partially understood. In the present study, we provide evidence that physical exercise restores renal function in diabetic mice through enhancement of PPARδ-CPT1α-dependent fatty acid β-oxidation (FAO), highlight the importance of PPARδ during exercise, and uncover a previously unappreciated link between exercise and PPARδ-CPT1α-dependent FAO in restoring renal function of diabetic kidney disease, which could become new target for therapeutic intervention against diabetic kidney disease.
#> 5                                                                                                                                                                                                             Podocyte injury is a key driver of progression in diabetic kidney disease (DKD). Because podocytes are underrepresented in whole-kidney single-cell RNA sequencing datasets, we performed single-cell RNA sequencing of isolated glomeruli from diabetic db/db mice and control db/m mice to generate a glomerulus-focused transcriptomic dataset. Diabetic glomeruli showed reduced podocyte abundance and extensive transcriptional remodeling. more...
#> 6                                                                                                                       Diabetic kidney disease involves hyperglycemia, inflammation, and epithelial cell dysfunction, but the relationship between these factors is not well understood. We demonstrate that human kidney organoids treated with elevated glucose exhibit a phenotype of epithelial detachment driven by tissue-intrinsic upregulation of proinflammatory cytokines, which can be targeted therapeutically. High glucose induces morphological deterioration of organoids featuring podocyte and tubular cell detachment without cytotoxicity. more...
#>                     Organism
#> 1               Homo sapiens
#> 2               Homo sapiens
#> 3 Mus musculus; Homo sapiens
#> 4               Homo sapiens
#> 5               Homo sapiens
#> 6               Homo sapiens
```

## 2. Extract Sample Information

Extract the number of samples from the `Contains` field to enable
filtering by sample size. This count covers every sample in a series
regardless of group — cases, controls, and technical replicates — so
treat it as an upper bound; group sizes and balance must be verified
from sample annotations before a dataset is included in a meta-analysis.

``` r

dn_gse <- dn_gse |>
  dplyr::mutate(
    number_of_samples = str_match(
      Contains, "(\\d+) Samples?"
    )[, 2L, drop = TRUE],
    number_of_samples = as.integer(number_of_samples)
  )

summary(dn_gse$number_of_samples)
#>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.     NAs 
#>    1.00    8.00   18.00   41.77   40.25  616.00       1
```

## 3. Filter by Quality Criteria

Apply filters for sample size and study type to focus on candidate
expression profiling studies. Note that this filter admits both
microarray and RNA-seq records (“expression profiling by high throughput
sequencing”); intensity- and count-based studies cannot be pooled
directly, so process them separately or tighten the filter to arrays for
a single integrated analysis.

``` r

dn_gse_filtered <- dn_gse |>
  dplyr::filter(
    # At least 6 samples for meaningful analysis
    number_of_samples >= 6,
    # Focus on expression profiling studies
    str_detect(Type, regex("expression profiling", ignore_case = TRUE)),
    # Exclude methylation studies (defensive: no current GEO Type string
    # passes the filters above, but this guards against future variants)
    !str_detect(Type, regex("methylation", ignore_case = TRUE)),
    # Exclude compound SuperSeries so each study has a single assay type
    !str_detect(Type, ";")
  )

cat(sprintf(
  "After filtering: %d datasets (%.1f%% of original)\n",
  nrow(dn_gse_filtered),
  100 * nrow(dn_gse_filtered) / nrow(dn_gse)
))
#> After filtering: 89 datasets (66.9% of original)
```

## 4. Build a Metadata Database

Fetch detailed metadata for the filtered datasets using
[`geo_meta()`](https://WangLabCSU.github.io/geokit/reference/geo_meta.md).
This creates a local database for offline analysis and detailed
inspection. The download may take several minutes depending on the
number of datasets; if you have an NCBI API key, set it as the
`ENTREZ_KEY` environment variable to speed up searching.

``` r

dn_metadb_dir <- "dn_metadb"
dir.create(dn_metadb_dir, showWarnings = FALSE, recursive = TRUE)

dn_metadb <- geo_meta(
  dn_gse_filtered[["Series Accession"]],
  odir = dn_metadb_dir
)

# Save for future use
saveRDS(dn_metadb, file.path(dn_metadb_dir, "dn_metadb.rds"))
```

In a later session, reload the saved database and calculate the actual
sample counts from the sample identifier list:

``` r

dn_metadb <- readRDS(file.path(dn_metadb_dir, "dn_metadb.rds"))

dn_metadb <- dn_metadb |>
  dplyr::mutate(
    number_of_samples = lengths(
      strsplit(Series_sample_id, "; ", fixed = TRUE)
    )
  )
```

## 5. Annotate and Categorize Datasets

Categorize datasets by criteria relevant to diabetic nephropathy
research, searching the title, summary, and overall design fields of
each series. These keyword assignments are screening heuristics only —
inspect each candidate’s design and sample annotations (tissue, cell
type, group definitions) before final inclusion, as keyword matches can
also pick up cell-line or animal studies.

``` r

dn_metadb <- dn_metadb |>
  dplyr::mutate(
    search_text = paste(Series_title, Series_summary, Series_overall_design),
    has_nephropathy = str_detect(
      search_text, regex("nephropath", ignore_case = TRUE)
    ),
    has_kidney = str_detect(
      search_text, regex("kidney|renal", ignore_case = TRUE)
    ),
    tissue_type = dplyr::case_when(
      str_detect(search_text, regex("glomerul", ignore_case = TRUE)) ~
        "glomerular",
      str_detect(search_text, regex("tubul", ignore_case = TRUE)) ~ "tubular",
      str_detect(search_text, regex("kidney|renal", ignore_case = TRUE)) ~
        "kidney",
      TRUE ~ "other"
    )
  )

table(dn_metadb$tissue_type)
```

## 6. Visualization: Dataset Characteristics

### Timeline of Dataset Submissions

GSE accession numbers are assigned chronologically, so they can serve as
a time proxy for when studies were submitted. Depending on the records,
the SOFT metadata may also provide explicit dates (e.g.,
`Series_submission_date`) that you can parse instead.

``` r

dn_metadb <- dn_metadb |>
  dplyr::mutate(
    gse_number = as.integer(str_extract(Series_geo_accession, "\\d+"))
  )

ggplot(dn_metadb, aes(x = gse_number)) +
  geom_histogram(bins = 30, fill = "steelblue", color = "white") +
  labs(
    title = "Distribution of DN Datasets by GEO Accession Number",
    subtitle = "GSE numbers are assigned chronologically (lower = older)",
    x = "GSE Number",
    y = "Number of Datasets"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    plot.subtitle = element_text(hjust = 0.5, size = 9),
    panel.grid.minor = element_blank()
  )
```

### Sample Size Distribution

``` r

ggplot(dn_metadb, aes(x = number_of_samples)) +
  geom_histogram(binwidth = 5, fill = "coral", color = "white") +
  geom_vline(
    xintercept = median(dn_metadb$number_of_samples, na.rm = TRUE),
    linetype = "dashed", color = "red", linewidth = 1
  ) +
  labs(
    title = "Distribution of Sample Sizes in DN Datasets",
    subtitle = sprintf(
      "Median: %s samples",
      format(median(dn_metadb$number_of_samples, na.rm = TRUE))
    ),
    x = "Number of Samples",
    y = "Number of Datasets"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    plot.subtitle = element_text(hjust = 0.5),
    panel.grid.minor = element_blank()
  )
```

### Platform Usage Trends

``` r

platform_summary <- dn_metadb |>
  dplyr::count(Series_platform_id, sort = TRUE) |>
  dplyr::slice_max(n, n = 10)

ggplot(platform_summary, aes(x = reorder(Series_platform_id, n), y = n)) +
  geom_col(fill = "darkgreen", alpha = 0.7) +
  geom_text(aes(label = n), hjust = -0.2, size = 3.5) +
  coord_flip() +
  labs(
    title = "Top 10 Platforms Used in DN Studies",
    x = "Platform ID",
    y = "Number of Studies"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    panel.grid.major.y = element_blank()
  )
```

## 7. Prepare a Curated Dataset List

Create a final curated list of datasets suitable for meta-analysis.

``` r

dn_curated <- dn_metadb |>
  dplyr::filter(
    number_of_samples >= 10,
    has_nephropathy | has_kidney
  ) |>
  dplyr::arrange(desc(number_of_samples)) |>
  dplyr::select(
    Series_geo_accession,
    Series_title,
    number_of_samples,
    Series_platform_id,
    tissue_type
  )

head(dn_curated, 10)

write.csv(
  dn_curated,
  file.path(dn_metadb_dir, "dn_curated_datasets.csv"),
  row.names = FALSE
)
```

## 8. Next Steps for Meta-Analysis

With this curated list, you can proceed to:

1.  **Download expression data**: Use
    [`geo_matrix()`](https://WangLabCSU.github.io/geokit/reference/geo_matrix.md)
    to download series matrix files
2.  **Quality control**: Examine sample annotations and expression
    distributions
3.  **Data integration**: Normalize and batch-correct across studies
4.  **Differential expression**: Identify genes consistently
    dysregulated in DN
5.  **Pathway analysis**: Investigate enriched biological processes

``` r

top_gse <- dn_curated$Series_geo_accession[1]
eset <- geo_matrix(top_gse, odir = tempdir())

print(eset)
dim(Biobase::exprs(eset))
```

Instead of manually inspecting the curated list, you can also hand it to
an LLM for interactive exploration with
[`geo_chat()`](https://WangLabCSU.github.io/geokit/reference/geo_chat.md);
see
[`vignette("geo-chat")`](https://WangLabCSU.github.io/geokit/articles/geo-chat.md)
for details.

``` r

chat <- geo_chat(
  NULL,
  dn_curated,
  data_description = paste(
    "Curated diabetic nephropathy GEO Series selected for meta-analysis.",
    "number_of_samples is counted from the SOFT sample list."
  )
)
chat$app()
```

## Summary

This workflow demonstrated how to:

- Use multiple search strategies to comprehensively identify relevant
  datasets
- Build a customized metadata database with
  [`geo_meta()`](https://WangLabCSU.github.io/geokit/reference/geo_meta.md)
- Apply quality filters for sample size and study type
- Visualize dataset characteristics over time
- Prepare a curated list for downstream meta-analysis

The systematic approach supports reproducibility and helps identify the
most suitable datasets for gene expression meta-analysis in diabetic
nephropathy research.

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
#> [1] ggplot2_4.0.3 stringr_1.6.0 dplyr_1.2.1   geokit_0.0.2 
#> 
#> loaded via a namespace (and not attached):
#>  [1] gtable_0.3.6       jsonlite_2.0.0     compiler_4.6.1     tidyselect_1.2.1  
#>  [5] rentrez_1.2.4      jquerylib_0.1.4    systemfonts_1.3.2  scales_1.4.0      
#>  [9] textshaping_1.0.5  yaml_2.3.12        fastmap_1.2.0      R6_2.6.1          
#> [13] generics_0.1.4     curl_8.1.0         knitr_1.52         XML_3.99-0.25     
#> [17] tibble_3.3.1       desc_1.4.3         bslib_0.12.0       pillar_1.11.1     
#> [21] RColorBrewer_1.1-3 rlang_1.3.0        cachem_1.1.0       stringi_1.8.9     
#> [25] xfun_0.62          S7_0.2.2           fs_2.1.0           sass_0.4.10       
#> [29] otel_0.2.0         cli_3.6.6          withr_3.0.3        pkgdown_2.2.1     
#> [33] magrittr_2.0.5     digest_0.6.39      grid_4.6.1         lifecycle_1.0.5   
#> [37] vctrs_0.7.3        evaluate_1.0.5     glue_1.8.1         farver_2.1.2      
#> [41] codetools_0.2-20   ragg_1.5.2         httr_1.4.9         rmarkdown_2.32    
#> [45] tools_4.6.1        pkgconfig_2.0.3    htmltools_0.5.9
```
