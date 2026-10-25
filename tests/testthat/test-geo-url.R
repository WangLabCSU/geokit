testthat::test_that("geo_gtype classifies accessions with and without abbreviation", {
    out <- geo_gtype(c("GSE10", "gpl98", "GSM1", "GDS505"))
    testthat::expect_identical(
        out, c("Series", "Platforms", "Samples", "Datasets")
    )

    abbre <- geo_gtype(c("GSE10", "gpl98", "GSM1", "GDS505"), TRUE)
    testthat::expect_identical(abbre, c("GSE", "GPL", "GSM", "GDS"))
})

testthat::test_that("geo_gtype rejects non-character input", {
    testthat::expect_error(geo_gtype(list("GSE10")), "character vector")
})

testthat::test_that("geo_url builds FTP and display URLs", {
    # GSE defaults to the SOFT family file over HTTPS
    testthat::expect_identical(
        geo_url("GSE10"),
        "https://ftp.ncbi.nlm.nih.gov/geo/series/GSEnnn/GSE10/soft/GSE10_family.soft.gz" # nolint
    )

    testthat::expect_identical(
        geo_url("GSE10", "matrix"),
        "https://ftp.ncbi.nlm.nih.gov/geo/series/GSEnnn/GSE10/matrix"
    )

    # plain FTP when https fronting is disabled
    testthat::expect_identical(
        geo_url("GSE10", ftp_over_https = FALSE),
        "ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSEnnn/GSE10/soft/GSE10_family.soft.gz" # nolint
    )

    # Accession Display Bar URL for a GSM with full text view
    testthat::expect_identical(
        geo_url("GSM1", "text", "full", "self"),
        "https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSM1&targ=self&view=full&form=text" # nolint
    )
})
