testthat::test_that("GSE Supplemental files downloading works", {
    res <- rgeo::get_geo_suppl("GSE1000", tempdir())
    testthat::expect_equal(length(res), 1L, ignore_attr = TRUE)
    testthat::expect_true(file.exists(res))
})

testthat::test_that("GSM Supplemental files downloading works", {
    res <- rgeo::get_geo_suppl("GSM15789", tempdir())
    testthat::expect_equal(length(res), 1L, ignore_attr = TRUE)
    testthat::expect_true(file.exists(res))
})
