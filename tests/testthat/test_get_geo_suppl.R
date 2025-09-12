testthat::test_that("Create dir correctly", {
    geo_suppl("GSM15789", odir = file.path(tempdir(), "test"))
    testthat::expect_true(dir.exists(file.path(tempdir(), "test")))
})

testthat::test_that("GSE Supplemental files downloading works", {
    res <- geo_suppl("GSE1000", odir = tempdir())
    testthat::expect_equal(length(res), 1L, ignore_attr = TRUE)
    testthat::expect_true(file.exists(res))
})

testthat::test_that("GSM Supplemental files downloading works", {
    res <- geo_suppl("GSM15789", odir = tempdir())
    testthat::expect_equal(length(res), 1L, ignore_attr = TRUE)
    testthat::expect_true(file.exists(res))
})
