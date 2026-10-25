# Case Study: Urothelial Cancer Expression Analysis

This vignette demonstrates a complete workflow for extracting,
filtering, downloading, and analyzing urothelial cancer expression data
from GEO. We cover dataset discovery, quality-based filtering, data
retrieval, and exploratory analysis with publication-quality
visualizations.

## Introduction

Urothelial carcinoma, the most common histological subtype of bladder
cancer, is one of the most common urological malignancies. Meta-analysis
of gene expression studies can reveal consistent molecular alterations
across patient cohorts. This workflow shows how to:

- Search and combine results for bladder/urothelial cancer datasets
- Filter datasets by sample size and assay type
- Download expression matrices
- Perform log transformation and data integration
- Conduct exploratory analysis (PCA, boxplots, heatmaps)
- Generate publication-quality visualizations

``` r

library(geokit)
library(dplyr)
library(stringr)
library(tidyr)
library(ggplot2)
```

## 1. Dataset Discovery

Search for bladder and urothelial cancer datasets using multiple related
terms to maximize coverage. Note that “urothelial carcinoma” is the
standard histopathological term and matches records the other two terms
miss.

``` r

uc_searches <- list(
  bladder = geo_search(
    "bladder cancer[ALL] AND Homo sapiens[ORGN] AND GSE[ETYP]"
  ),
  urothelial = geo_search(
    "urothelial cancer[ALL] AND Homo sapiens[ORGN] AND GSE[ETYP]"
  ),
  carcinoma = geo_search(
    "urothelial carcinoma[ALL] AND Homo sapiens[ORGN] AND GSE[ETYP]"
  )
)
#> → Parsing GEO records
#> → Parsing GEO records
#> → Parsing GEO records

uc_gse <- unique(dplyr::bind_rows(uc_searches))

cat(sprintf("Found %d unique urothelial cancer datasets\n", nrow(uc_gse)))
#> Found 794 unique urothelial cancer datasets
head(uc_gse[, 1:3])
#>                                                                                                                                                                       Title
#> 1                                                                                                      E2F3 amplification primes bladder cancer cells for premature mitosis
#> 2                                                                                                       RIP-seq and N6-methyladenosine RIP-seq (MeRIP-seq) in UM-UC-3 cells
#> 3                                                                                                      ATHENA: Augmenting Therapeutic Effectiveness through Novel Analytics
#> 4                                                                               Bulk RNA sequencing of human bladder cancer clinical specimens for transcriptomic analysis.
#> 5 Morphological and Single-Cell Analyses of En Bloc Resected Non-Muscle invasive Bladder Cancer Reveal Structural and functional disruption of Tertiary lymphoid Structures
#> 6                                                                                                                       snRNASeq of Metastatic Urothelial carcinoma samples
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     Summary
#> 1                                                     The E2F–RB pathway controls the G1/S checkpoint, and tumors often bypass it through RB1 or CDKN2A loss. Unlike these lesions, E2F3 amplification drives persistent excessive E2F-dependent transcription through S and G2 phases. This oncogene is frequently amplified in for example bladder cancer, but its impact on the cancer cell cycle remains unclear. Using isogenic bladder cancer models and patient data, we show that E2F3 amplification hyperactivates a mitotic gene expression program, including cyclin B1. more...
#> 2                                                                                                                                                              Cisplatin resistance and tumor relapse are the leading causes of the mortality in muscle-invasive bladder cancer (MIBC). Preceding evidence supported that basal/squamous subtype, N6-methyladenosine (m6A) modifications and hypoxia are associated with a reduced chemotherapy response.  To explore the m6a modification in UM-UC-3 cells, we performed RNA immunoprecipitation with an antibody against m6a (No. more...
#> 3                                                                                                                      With a yearly incidence of about 2500 new cases in Belgium, bladder cancer (BC) is a commonly-diagnosed cancer type. Furthermore, it is accompanied with high mortality rates, with ca. 70% of patients not surviving past five years (Richters et al., 2020). In order to reduce the risk of recurrence and progression, patients with non-muscle invasive bladder cancer (NMIBC) are monitored frequently, undergoing cystoscopy examination and cytology. more...
#> 4                                                                                                                                                                                                                                                                                                              This study characterized transcriptomic features of human bladder cancer using bulk RNA sequencing of tumor specimens. Processed gene-expression data were analyzed to investigate biological features associated with the tumor microenvironment and tumor characteristics.
#> 5                                                      Tertiary lymphoid structures (TLS) have emerged as critical immune niches within the tumor microenvironment across various cancers. However, their structural organization and functional roles in non–muscle-invasive bladder cancer (NMIBC) remain poorly characterized. In this study, we provide the first detailed characterization of TLS in NMIBC using en bloc resected specimens, enabling high-resolution spatial mapping and quantitative histological assessment across a large cohort of primary tumors (n=97). more...
#> 6 Histological variation is a common feature of metastatic cancer but its clonal origins and impact on disease history remains poorly defined. In this study, we developed a first-in-kind metastatic bladder cancer (BLCA) rapid autopsy cohort enriched in rare histological subtypes to extensively profile individuals with terminal disease. By reconstructing the evolutionary history of patient tumors, we determined that metastasis-to-metastasis seeding was the dominant driver of cancer spread and that increased polyclonal migration contributed to poor prognosis. more...
#>       Organism
#> 1 Homo sapiens
#> 2 Homo sapiens
#> 3 Homo sapiens
#> 4 Homo sapiens
#> 5 Homo sapiens
#> 6 Homo sapiens
```

## 2. Extract and Process Sample Information

The count parsed below covers every sample in a series regardless of
group — cases, controls, and technical replicates — so treat it as an
upper bound. Group sizes and balance (e.g., tumor vs. normal) must be
verified from the sample annotations before a dataset is actually
included in a meta-analysis.

``` r

uc_gse <- uc_gse |>
  dplyr::mutate(
    number_of_samples = str_match(
      Contains, "(\\d+) Samples?"
    )[, 2L, drop = TRUE],
    number_of_samples = as.integer(number_of_samples)
  )

cat("\nSample size summary:\n")
#> 
#> Sample size summary:
summary(uc_gse$number_of_samples)
#>     Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
#>     1.00     6.00    12.00    83.99    45.75 16190.00
```

## 3. Filter Datasets by Quality Criteria

Apply stringent filters to select candidate datasets suitable for
meta-analysis.

``` r

uc_gse_filtered <- uc_gse |>
  dplyr::filter(
    # At least 20 samples for robust analysis
    number_of_samples >= 20,
    # Focus on expression profiling
    str_detect(Type, regex("expression profiling", ignore_case = TRUE)),
    # Prefer microarray studies (exclude RNA-seq for now)
    str_detect(Type, regex("array", ignore_case = TRUE)),
    # Exclude methylation studies (defensive: no current GEO Type string
    # passes the filters above, but this guards against future variants)
    !str_detect(Type, regex("methylation", ignore_case = TRUE)),
    # Exclude compound SuperSeries so each study has a single assay type
    !str_detect(Type, ";")
  ) |>
  dplyr::arrange(desc(number_of_samples))

cat(sprintf(
  "\nFiltered to %d candidate datasets (%.1f%% of original)\n",
  nrow(uc_gse_filtered),
  100 * nrow(uc_gse_filtered) / nrow(uc_gse)
))
#> 
#> Filtered to 95 candidate datasets (12.0% of original)

head(
  uc_gse_filtered[, c("Series Accession", "Title", "number_of_samples")],
  10
)
#>    Series Accession
#> 1         GSE203024
#> 2           GSE2109
#> 3          GSE36133
#> 4           GSE5479
#> 5          GSE68950
#> 6          GSE68928
#> 7         GSE198269
#> 8          GSE48277
#> 9         GSE245953
#> 10         GSE32894
#>                                                                                                                                   Title
#> 1                                                                                      Gene Expression Data from Human Peripheral Blood
#> 2                                                                                                Expression Project for Oncology (expO)
#> 3                                                                         Expression data from the Cancer Cell Line Encyclopedia (CCLE)
#> 4                 Gene expression signatures predict outcome in non-muscle invasive bladder carcinoma - a multi-center validation study
#> 5                                                              caArray_golub-00327: Sanger cell line Affymetrix gene expression project
#> 6                                               caArray_golub-00236: Multiclass cancer diagnosis using tumor gene expression signatures
#> 7                                   Predictive biomarkers for survival benefit with ramucirumab in urothelial cancer in the RANGE trial
#> 8  Identification of distinct basal and luminal subsets of human bladder cancers with different sensitivities to frontline chemotherapy
#> 9                                                                   Gene expression data from muscle-invasive bladder cancer samples II
#> 10                                                                                         A Molecular Taxonomy of Urothelial Carcinoma
#>    number_of_samples
#> 1               2845
#> 2               2158
#> 3                917
#> 4                808
#> 5                798
#> 6                539
#> 7                394
#> 8                349
#> 9                310
#> 10               308
```

## 4. Download Expression Data

For demonstration, we work with a subset of datasets. In practice, you
would download all filtered datasets, ideally into a persistent
directory instead of
[`tempdir()`](https://rdrr.io/r/base/tempfile.html).

``` r

demo_gse <- head(uc_gse_filtered[["Series Accession"]], 3)
cat("Demo datasets:", paste(demo_gse, collapse = ", "), "\n")
#> Demo datasets: GSE203024, GSE2109, GSE36133
```

``` r

expression_sets <- list()
for (gse_id in demo_gse) {
  message(sprintf("Downloading %s...", gse_id))
  expression_sets[[gse_id]] <- tryCatch(
    geo_matrix(gse_id, odir = tempdir()),
    error = function(e) {
      message(sprintf("Failed to download %s: %s", gse_id, conditionMessage(e)))
      NULL
    }
  )
}

# Drop failed downloads; names are kept as the GSE accessions
expression_sets <- Filter(Negate(is.null), expression_sets)

cat(sprintf("Successfully downloaded %d datasets\n", length(expression_sets)))
```

## 5. Data Transformation

Apply log transformation to ensure data comparability across datasets.
[`log_trans()`](https://WangLabCSU.github.io/geokit/reference/log_trans.md)
applies `log2(x + 1)` only when a GEO2R-style heuristic indicates the
data are not already on a log scale — check the printed ranges to
confirm each dataset was handled as intended.

``` r

expression_sets_log <- lapply(expression_sets, log_trans)

sapply(expression_sets_log, function(eset) {
  exprs <- Biobase::exprs(eset)
  c(
    min = min(exprs, na.rm = TRUE),
    median = median(exprs, na.rm = TRUE),
    max = max(exprs, na.rm = TRUE)
  )
})
```

## 6. Exploratory Analysis

### 6.1 Expression Distribution

Examine the distribution of expression values across samples using
boxplots.

``` r

eset <- expression_sets_log[[1]]
expr_matrix <- Biobase::exprs(eset)

expr_df <- as.data.frame(expr_matrix) |>
  dplyr::mutate(gene = rownames(expr_matrix)) |>
  tidyr::pivot_longer(
    cols = -gene,
    names_to = "sample",
    values_to = "expression"
  )

ggplot(expr_df, aes(x = sample, y = expression)) +
  geom_boxplot(fill = "lightblue", outlier.size = 0.5, outlier.alpha = 0.3) +
  labs(
    title = sprintf(
      "Expression Distribution - %s",
      names(expression_sets_log)[1]
    ),
    x = "Sample",
    y = "Expression (log2 scale)"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
    plot.title = element_text(hjust = 0.5, face = "bold"),
    panel.grid.major.x = element_blank()
  )
```

### 6.2 Principal Component Analysis (PCA)

Perform PCA to visualize sample relationships and identify potential
batch effects.

``` r

eset <- expression_sets_log[[1]]
expr_matrix <- Biobase::exprs(eset)

# Remove genes with missing values
expr_matrix <- expr_matrix[complete.cases(expr_matrix), ]

pca_result <- stats::prcomp(t(expr_matrix), scale. = TRUE)

pca_df <- as.data.frame(pca_result$x[, 1:2])
pca_df$sample <- rownames(pca_df)

var_explained <- summary(pca_result)$importance[2, 1:2] * 100

ggplot(pca_df, aes(x = PC1, y = PC2)) +
  geom_point(size = 3, alpha = 0.7, color = "darkred") +
  geom_text(aes(label = sample), size = 2.5, vjust = -1) +
  labs(
    title = sprintf("PCA - %s", names(expression_sets_log)[1]),
    x = sprintf("PC1 (%.1f%% variance)", var_explained[1]),
    y = sprintf("PC2 (%.1f%% variance)", var_explained[2])
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    panel.grid = element_line(color = "gray90")
  )
```

### 6.3 Sample Correlation Heatmap

Calculate and visualize pairwise sample correlations to assess data
quality and identify outliers.

``` r

eset <- expression_sets_log[[1]]
expr_matrix <- Biobase::exprs(eset)
expr_matrix <- expr_matrix[complete.cases(expr_matrix), ]

cor_matrix <- cor(expr_matrix, method = "pearson")

cor_df <- as.data.frame(as.table(cor_matrix))
colnames(cor_df) <- c("Sample1", "Sample2", "Correlation")

ggplot(cor_df, aes(x = Sample1, y = Sample2, fill = Correlation)) +
  geom_tile() +
  scale_fill_gradient2(
    low = "blue", mid = "white", high = "red",
    # Midpoint at the typical sample-correlation level on log expression;
    # adjust to the observed range of your data
    midpoint = 0.8,
    limits = c(min(cor_df$Correlation), 1),
    name = "Pearson\nCorrelation"
  ) +
  labs(
    title = sprintf(
      "Sample Correlation Heatmap - %s",
      names(expression_sets_log)[1]
    ),
    x = "Sample",
    y = "Sample"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
    axis.text.y = element_text(size = 8),
    plot.title = element_text(hjust = 0.5, face = "bold"),
    panel.grid = element_blank()
  )
```

### 6.4 Summary Statistics

Generate comprehensive summary statistics across datasets.

``` r

summary_stats <- lapply(names(expression_sets_log), function(name) {
  eset <- expression_sets_log[[name]]
  expr_matrix <- Biobase::exprs(eset)

  data.frame(
    dataset = name,
    n_samples = ncol(expr_matrix),
    n_genes = nrow(expr_matrix),
    mean_expr = mean(expr_matrix, na.rm = TRUE),
    median_expr = median(expr_matrix, na.rm = TRUE),
    sd_expr = sd(as.vector(expr_matrix), na.rm = TRUE),
    missing_pct = mean(is.na(expr_matrix)) * 100
  )
})

summary_table <- dplyr::bind_rows(summary_stats)
print(summary_table)

write.csv(summary_table, "uc_expression_summary.csv", row.names = FALSE)
```

## 7. Data Integration Considerations

**Probe identifiers are not gene identifiers.**
[`geo_matrix()`](https://WangLabCSU.github.io/geokit/reference/geo_matrix.md)
returns series matrices whose rows are platform probe IDs (check
`Biobase::annotation(eset)` and the `featureData` slot). Intersecting
rownames is only valid when all datasets come from the same — or a
nested — platform. Across mixed platforms (e.g., Affymetrix and
Illumina), map probes to genes with the platform annotation first, then
intersect on gene identifiers.

``` r

# 1. Inspect the platform annotation of each dataset, then find common
#    features. Remember: intersecting rownames only works across the same
#    (or nested) platforms; for mixed platforms, map probes to genes via
#    the platform annotation (featureData / Bioconductor annotation
#    packages) first.
sapply(expression_sets_log, Biobase::annotation)

common_genes <- Reduce(intersect, lapply(expression_sets_log, function(eset) {
  rownames(Biobase::exprs(eset))
}))

cat(sprintf("Common features across all datasets: %d\n", length(common_genes)))

# 2. Subset to common features
expression_sets_common <- lapply(expression_sets_log, function(eset) {
  eset[common_genes, ]
})

# 3. Combine expression matrices
combined_expr <- do.call(cbind, lapply(expression_sets_common, Biobase::exprs))

cat(sprintf(
  "Combined matrix dimensions: %d genes x %d samples\n",
  nrow(combined_expr),
  ncol(combined_expr)
))

# 4. Create study labels for batch correction
study_labels <- unlist(lapply(seq_along(expression_sets_common), function(i) {
  rep(
    names(expression_sets_common)[i],
    ncol(Biobase::exprs(expression_sets_common[[i]]))
  )
}))

# At this point, you would apply batch correction methods
# such as ComBat (sva package) or limma's removeBatchEffect
```

## 8. Visualization: Cross-Dataset Comparison

Compare expression patterns across multiple datasets.

``` r

mean_expr_per_dataset <- sapply(expression_sets_log, function(eset) {
  rowMeans(Biobase::exprs(eset), na.rm = TRUE)
})

mean_expr_df <- as.data.frame(mean_expr_per_dataset) |>
  dplyr::mutate(gene = rownames(mean_expr_per_dataset)) |>
  tidyr::pivot_longer(
    cols = -gene,
    names_to = "dataset",
    values_to = "mean_expression"
  )

ggplot(mean_expr_df, aes(x = mean_expression, color = dataset)) +
  geom_density(linewidth = 1, alpha = 0.7) +
  labs(
    title = "Mean Expression Distribution Across Datasets",
    x = "Mean expression (log2 scale)",
    y = "Density",
    color = "Dataset"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    legend.position = "bottom"
  )
```

## 9. Next Steps

With the downloaded and processed data, you can proceed to:

1.  **Batch correction**: Use ComBat or similar methods to remove
    technical variation
2.  **Differential expression**: Identify genes altered in cancer
    vs. normal samples
3.  **Meta-analysis**: Combine results across studies using fixed/random
    effects models
4.  **Pathway analysis**: Investigate enriched biological processes and
    pathways
5.  **Validation**: Cross-validate findings in independent cohorts

``` r

eset <- expression_sets_log[[1]]
pdata <- Biobase::pData(eset)

colnames(pdata)

# A typical workflow would identify tumor vs. normal samples
# and perform differential expression analysis
```

## Summary

This workflow demonstrated:

- Comprehensive dataset discovery using multiple search terms
- Filtering by sample size (\>= 20) and assay type (microarray
  expression profiling, excluding methylation studies and compound
  SuperSeries)
- Downloading expression matrices with
  [`geo_matrix()`](https://WangLabCSU.github.io/geokit/reference/geo_matrix.md)
- Log transformation using
  [`log_trans()`](https://WangLabCSU.github.io/geokit/reference/log_trans.md)
- Exploratory analysis including expression distributions, PCA, sample
  correlation heatmaps, and summary statistics
- Data integration considerations for meta-analysis

These steps provide a solid foundation for conducting rigorous gene
expression meta-analysis in urothelial cancer research.

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
#> [1] ggplot2_4.0.3 tidyr_1.3.2   stringr_1.6.0 dplyr_1.2.1   geokit_0.0.2 
#> 
#> loaded via a namespace (and not attached):
#>  [1] gtable_0.3.6       jsonlite_2.0.0     compiler_4.6.1     tidyselect_1.2.1  
#>  [5] rentrez_1.2.4      jquerylib_0.1.4    systemfonts_1.3.2  scales_1.4.0      
#>  [9] textshaping_1.0.5  yaml_2.3.12        fastmap_1.2.0      R6_2.6.1          
#> [13] generics_0.1.4     curl_8.1.0         knitr_1.52         XML_3.99-0.25     
#> [17] tibble_3.3.1       desc_1.4.3         RColorBrewer_1.1-3 bslib_0.12.0      
#> [21] pillar_1.11.1      rlang_1.3.0        cachem_1.1.0       stringi_1.8.9     
#> [25] xfun_0.62          S7_0.2.2           fs_2.1.0           sass_0.4.10       
#> [29] otel_0.2.0         cli_3.6.6          withr_3.0.3        pkgdown_2.2.1     
#> [33] magrittr_2.0.5     digest_0.6.39      grid_4.6.1         lifecycle_1.0.5   
#> [37] vctrs_0.7.3        evaluate_1.0.5     glue_1.8.1         farver_2.1.2      
#> [41] codetools_0.2-20   ragg_1.5.2         httr_1.4.9         rmarkdown_2.32    
#> [45] purrr_1.2.2        tools_4.6.1        pkgconfig_2.0.3    htmltools_0.5.9
```
