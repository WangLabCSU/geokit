testthat::test_that("geo_chat adds GEO context to querychat", {
    testthat::skip_if_not_installed("querychat")
    testthat::skip_if_not_installed("duckdb")

    records <- data.frame(
        Accession = c("GSE1", "GSM1"),
        Title = c("human diabetes study", "treated sample"),
        Type = c("Expression profiling by array", "Sample"),
        Samples = c(12L, 1L)
    )

    chat <- geo_chat(
        NULL,
        records,
        table_name = "geo_records",
        data_description = "Rows are prefiltered for diabetes-related records.",
        cleanup = TRUE
    )
    on.exit(chat$cleanup(), add = TRUE)

    testthat::expect_s3_class(chat, "QueryChat")
})
