testthat::test_that("parse_sample_data expands characteristics columns", {
    df <- data.frame(
        geo_accession = c("GSM1", "GSM2"),
        characteristics_ch1 = c("disease: yes", "disease: no"),
        characteristics_ch1.1 = c("cell line: HeLa", "cell line: 293T"),
        strain = c("C57BL/6", "C57BL/6"),
        stringsAsFactors = FALSE
    )
    out <- parse_sample_data(df)

    testthat::expect_identical(colnames(out), c(
        "geo_accession", "characteristics_ch1", "ch1_disease",
        "characteristics_ch1.1", "ch1_cell line", "strain"
    ))
    testthat::expect_identical(out$ch1_disease, c("yes", "no"))
    testthat::expect_identical(out$`ch1_cell line`, c("HeLa", "293T"))
    testthat::expect_identical(rownames(out), c("GSM1", "GSM2"))
    # original characteristics columns are preserved
    testthat::expect_identical(out$characteristics_ch1, df$characteristics_ch1)
})

testthat::test_that("parse_sample_data honors fields and sep arguments", {
    df <- data.frame(
        geo_accession = c("GSM1", "GSM2"),
        characteristics_ch1 = c("disease=yes", "disease=no"),
        stringsAsFactors = FALSE
    )
    out <- parse_sample_data(
        df,
        fields = "characteristics_ch1",
        sep = "="
    )
    testthat::expect_identical(colnames(out), c(
        "geo_accession", "characteristics_ch1", "ch1_disease"
    ))
    testthat::expect_identical(out$ch1_disease, c("yes", "no"))
})

testthat::test_that("parse_sample_data skips low-quality characteristic columns", {
    # only 1 of 3 values contains the separator -> below the 50% threshold
    df <- data.frame(
        geo_accession = c("GSM1", "GSM2", "GSM3"),
        characteristics_ch1 = c("trait: yes", "no separator", "no separator"),
        stringsAsFactors = FALSE
    )
    out <- parse_sample_data(df)
    testthat::expect_identical(colnames(out), c(
        "geo_accession", "characteristics_ch1"
    ))
    testthat::expect_identical(rownames(out), c("GSM1", "GSM2", "GSM3"))
})

testthat::test_that("parse_sample_data expands non-contiguous characteristic columns", {
    df <- data.frame(
        geo_accession = c("GSM1", "GSM2"),
        characteristics_ch1 = c("disease: yes", "disease: no"),
        tissue = c("kidney", "kidney"),
        characteristics_ch1.1 = c("cell line: HeLa", "cell line: 293T"),
        strain = c("C57BL/6", "C57BL/6"),
        stringsAsFactors = FALSE
    )
    out <- parse_sample_data(df)
    testthat::expect_identical(out$ch1_disease, c("yes", "no"))
    testthat::expect_identical(out$`ch1_cell line`, c("HeLa", "293T"))
})

testthat::test_that("parse_sample_data returns input unchanged when no characteristics", {
    df <- data.frame(geo_accession = "GSM1", trait = "x")
    out <- parse_sample_data(df)
    testthat::expect_identical(colnames(out), c("geo_accession", "trait"))
    testthat::expect_identical(rownames(out), "GSM1")
})
