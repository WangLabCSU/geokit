testthat::test_that("Create dir correctly", {
    get_geo_suppl("GSM15789", file.path(tempdir(), "test"))
    testthat::expect_true(dir.exists(file.path(tempdir(), "test")))
})

testthat::test_that("GSE Supplemental files downloading works", {
    res <- get_geo_suppl("GSE1000", tempdir())
    testthat::expect_equal(length(res), 1L, ignore_attr = TRUE)
    testthat::expect_true(file.exists(res))
})

testthat::test_that("GSM Supplemental files downloading works", {
    res <- get_geo_suppl("GSM15789", tempdir())
    testthat::expect_equal(length(res), 1L, ignore_attr = TRUE)
    testthat::expect_true(file.exists(res))
})
