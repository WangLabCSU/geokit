# Chat with GEO Metadata

[`geo_chat()`](https://WangLabCSU.github.io/geokit/reference/geo_chat.md)
connects GEO metadata tables to a large language model (LLM) so that you
can explore them with natural language: *find single-cell studies with
more than 20 samples*, *which platforms dominate these datasets?*, or
*filter to post-2020 human studies*. Under the hood it delegates schema
summarization, SQL querying, and dashboard filtering to the
[querychat](https://posit-dev.github.io/querychat/r/) package, so the
model never needs the raw table serialized into the prompt — it queries
your local copy with SQL instead.

Three functions cover the whole workflow:

- [`geo_chat()`](https://WangLabCSU.github.io/geokit/reference/geo_chat.md)
  creates and returns a `QueryChat` object
- [`geo_shiny()`](https://WangLabCSU.github.io/geokit/reference/geo_chat.md)
  creates it and immediately launches a Shiny app
- [`geo_console()`](https://WangLabCSU.github.io/geokit/reference/geo_chat.md)
  creates it and immediately starts a console chat

``` r

library(geokit)
```

## Prerequisites

1.  Install [querychat](https://posit-dev.github.io/querychat/r/) if it
    is not already on your system. It is currently archived on CRAN, so
    install it from the posit-dev R-universe:

    ``` r

    install.packages(
      "querychat",
      repos = c("https://posit-dev.r-universe.dev", getOption("repos"))
    )
    ```

2.  To chat with a plain data frame, querychat needs a local SQL engine:
    install either `duckdb` or `RSQLite`.

3.  Configure an LLM client (see the next section).

> **Note**: LLM answers are generated from your metadata by an external
> model, so treat them as suggestions and verify important selections
> yourself.

## Choosing an LLM Client

The first argument of
[`geo_chat()`](https://WangLabCSU.github.io/geokit/reference/geo_chat.md),
`client`, is passed to querychat and accepts:

- `NULL` (default): querychat uses the `querychat.client` option, the
  `QUERYCHAT_CLIENT` environment variable, or falls back to
  [`ellmer::chat_openai()`](https://ellmer.tidyverse.org/reference/chat_openai.html).

- An [ellmer](https://ellmer.tidyverse.org/) `Chat` object, for full
  control over model, base URL, and system prompt:

  ``` r

  client <- ellmer::chat_openai(model = "gpt-4o-mini")
  ```

- A provider string understood by
  [`ellmer::chat()`](https://ellmer.tidyverse.org/reference/chat-any.html),
  such as `"anthropic/claude-sonnet-4-5"`.

- A function returning a `Chat` object — handy for OpenAI-compatible
  endpoints or custom credentials. querychat calls the function with
  `system_prompt = NULL`:

  ``` r

  client <- \(system_prompt = NULL) ellmer::chat_openai_compatible(
    base_url = "https://example.com/v1",
    model = "my-model",
    api_key = Sys.getenv("MY_API_KEY"),
    system_prompt = system_prompt
  )
  ```

API keys are read from environment variables by ellmer (e.g.,
`OPENAI_API_KEY`, `ANTHROPIC_API_KEY`); set them in your `.Renviron`.

## From Search Results to a Chat Session

A typical session starts with
[`geo_search()`](https://WangLabCSU.github.io/geokit/reference/geo_search.md).
The returned data frame can be handed to
[`geo_chat()`](https://WangLabCSU.github.io/geokit/reference/geo_chat.md)
directly:

``` r

records <- geo_search(
  "diabetes[ALL] AND Homo sapiens[ORGN] AND GSE[ETYP]"
)

chat <- geo_chat(
  NULL,
  records,
  data_description = paste(
    "GEO DataSets records about diabetes in human, one row per record.",
    "The Contains column lists related GSM/GSE/GPL accessions."
  )
)
```

`data_description` gives the model background about what the columns
mean, which noticeably improves query quality. Use `extra_instructions`
for additional behavioral rules (both are passed through to querychat).

## From a Metadata Database to a Chat Session

For richer series-level metadata, build a local database with
[`geo_meta()`](https://WangLabCSU.github.io/geokit/reference/geo_meta.md)
first (see
[`vignette("geometadb")`](https://WangLabCSU.github.io/geokit/articles/geometadb.md))
and chat with that table:

``` r

meta <- geo_meta(
  records[["Series Accession"]][1:20],
  odir = tempdir()
)

qc <- geo_chat(
  NULL,
  meta,
  data_description = paste(
    "One row per GEO Series fetched from SOFT metadata.",
    "Series_title, Series_summary and Series_overall_design describe each",
    "study; Series_sample_id lists its GSM accessions separated by '; '."
  )
)
```

The object returned by
[`geo_chat()`](https://WangLabCSU.github.io/geokit/reference/geo_chat.md)
is a standard `QueryChat` object, so you can launch the interface
whenever you are ready:

``` r

qc$app() # or qc$console() for the terminal
```

The convenience wrappers do both steps at once:

``` r

geo_shiny(NULL, records) # build + launch Shiny app
geo_console(NULL, records) # build + start console chat
```

## A Self-Contained Example

The following example needs no LLM access — it only builds and destroys
the chat object, which is useful to verify your installation:

``` r

records <- data.frame(
  `Series Accession` = c("GSE1", "GSE2"),
  Title = c("human diabetes study", "mouse liver study"),
  Type = c("Expression profiling by array", "RNA-seq"),
  Samples = c(12L, 8L),
  check.names = FALSE
)

chat <- geo_chat(NULL, records, cleanup = TRUE)
#> Warning: The "visualize" tool requires {.pkg ggsql} 0.5.2 or later.
#> ℹ Install it with `install.packages("ggsql")`; continuing without the "visualize" tool.
#> This warning is displayed once per session.
#> duckdb keeps downloaded extensions and secrets in a temporary directory:
#> ℹ /tmp/RtmpawMNnK/duckdb
#> This is removed when the R session ends.
#> • Extensions are re-downloaded each session.
#> • Secrets are lost.
#> ℹ Run duckdb(shared_home = TRUE) (or create ~/.duckdb) to keep them (suitable for most users).
#> ℹ Run duckdb(shared_home = FALSE) to accept the temporary directory (and silence this message).
#> ℹ See ?duckdb_storage for details and alternatives.
chat$cleanup()
```

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
#> [1] geokit_0.0.2
#> 
#> loaded via a namespace (and not attached):
#>  [1] cli_3.6.6            knitr_1.52           rlang_1.3.0         
#>  [4] xfun_0.62            querychat_0.4.1.9000 otel_0.2.0          
#>  [7] DBI_1.3.0            promises_1.5.0       shiny_1.14.0        
#> [10] textshaping_1.0.5    xtable_1.8-8         jsonlite_2.0.0      
#> [13] htmltools_0.5.9      httpuv_1.6.17        ragg_1.5.2          
#> [16] sass_0.4.10          rmarkdown_2.32       evaluate_1.0.5      
#> [19] jquerylib_0.1.4      fastmap_1.2.0        yaml_2.3.12         
#> [22] lifecycle_1.0.5      duckdb_2.0.0         compiler_4.6.1      
#> [25] fs_2.1.0             Rcpp_1.1.2           later_1.4.8         
#> [28] systemfonts_1.3.2    digest_0.6.39        R6_2.6.1            
#> [31] magrittr_2.0.5       bslib_0.12.0         tools_4.6.1         
#> [34] mime_0.13            pkgdown_2.2.1        cachem_1.1.0        
#> [37] desc_1.4.3
```
