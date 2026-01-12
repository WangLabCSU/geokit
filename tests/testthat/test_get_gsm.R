testthat::test_that("basic GSM works", {
    gsm <- geo_soft("GSM11805", odir = tempdir())

    testthat::expect_s4_class(gsm, "GEOSoft")
    testthat::expect_s4_class(gsm, "GEODatatable")
    testthat::expect_type(metadata(gsm), "list")
    testthat::expect_s3_class(columns(gsm), "data.frame")
    testthat::expect_s3_class(datatable(gsm), "data.frame")
    testthat::expect_equal(accession(gsm), "GSM11805")
    testthat::expect_equal(nrow(datatable(gsm)), 22283L)
    testthat::expect_length(metadata(gsm), 28L)
    testthat::expect_equal(ncol(columns(gsm)), 1L)
    testthat::expect_equal(nrow(columns(gsm)), 3L)
})
