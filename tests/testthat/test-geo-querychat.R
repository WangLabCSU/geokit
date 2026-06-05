testthat::test_that("geo_qc adds GEO context to querychat", {
    testthat::skip_if_not_installed("querychat")
    testthat::skip_if_not_installed("duckdb")

    records <- data.frame(
        Accession = c("GSE1", "GSM1"),
        Title = c("human diabetes study", "treated sample"),
        Type = c("Expression profiling by array", "Sample"),
        Samples = c(12L, 1L)
    )

    qc <- geo_qc(
        NULL,
        records,
        table_name = "geo_records",
        data_description = "Rows are prefiltered for diabetes-related records.",
        instructions = "Prefer human-readable accession summaries.",
        cleanup = TRUE
    )
    on.exit(qc$cleanup(), add = TRUE)

    testthat::expect_s3_class(qc, "QueryChat")
    testthat::expect_match(qc$system_prompt, "Gene Expression Omnibus")
    testthat::expect_match(qc$system_prompt, "GSE for series")
    testthat::expect_match(qc$system_prompt, "Rows are prefiltered")
    testthat::expect_match(qc$system_prompt, "Prefer human-readable")
})

testthat::test_that("geo_qc forwards table name and querychat arguments", {
    testthat::skip_if_not_installed("querychat")
    testthat::skip_if_not_installed("duckdb")

    records <- data.frame(
        Accession = "GSE1",
        Title = "human diabetes study"
    )

    qc <- geo_qc(
        NULL,
        records,
        table_name = "geo_records",
        cleanup = TRUE
    )
    on.exit(qc$cleanup(), add = TRUE)

    testthat::expect_s3_class(qc, "QueryChat")
    testthat::expect_match(qc$system_prompt, "Gene Expression Omnibus")
    testthat::expect_match(qc$system_prompt, "geo_records")
})
