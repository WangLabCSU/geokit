testthat::test_that("generic GPL parsing works as expected", {
    gpl <- rgeo::get_geo("GPL96", tempdir())

    testthat::expect_s4_class(gpl, "GEODataTable")
    testthat::expect_s4_class(gpl, "GEOData")
    testthat::expect_equal(nrow(datatable(gpl)), 22283L)
    testthat::expect_equal(ncol(datatable(gpl)), 21L)
    testthat::expect_type(meta(gpl), "list")
    testthat::expect_length(meta(gpl), 4L)
    testthat::expect_s3_class(datatable(gpl), "data.frame")
})

testthat::test_that("quoted GPL works", {
    gpl <- rgeo::get_geo("GPL4133", tempdir())

    testthat::expect_s4_class(gpl, "GEODataTable")
    testthat::expect_s4_class(gpl, "GEOData")
    testthat::expect_equal(nrow(datatable(gpl)), 45220L)
})

testthat::test_that("short GPL works", {
    gpl <- rgeo::get_geo("GPL15505", tempdir())

    testthat::expect_s4_class(gpl, "GEODataTable")
    testthat::expect_s4_class(gpl, "GEOData")
    testthat::expect_equal(nrow(datatable(gpl)), 52L)
})

testthat::test_that("GPL with no data table works", {
    gpl <- rgeo::get_geo("GPL5082", tempdir())

    testthat::expect_s4_class(gpl, "GEODataTable")
    testthat::expect_s4_class(gpl, "GEOData")
    testthat::expect_equal(nrow(datatable(gpl)), 0L)
})
