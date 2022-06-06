testthat::test_that("basic GSM works", {
    gsm <- rgeo::get_geo("GSM11805", tempdir())

    testthat::expect_s4_class(gsm, "GEODataTable")
    testthat::expect_s4_class(gsm, "GEOData")
    testthat::expect_type(meta(gsm), "list")
    testthat::expect_s3_class(columns(gsm), "data.frame")
    testthat::expect_s3_class(datatable(gsm), "data.frame")
    testthat::expect_equal(accession(gsm), "GSM11805")
    testthat::expect_equal(nrow(datatable(gsm)), 22283L)
    testthat::expect_length(meta(gsm), 30L)
    testthat::expect_equal(ncol(columns(gsm)), 1L)
    testthat::expect_equal(nrow(columns(gsm)), 3L)
})
