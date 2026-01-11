testthat::test_that("generic GPL parsing works as expected", {
    gpl <- geo_soft("GPL96", odir = tempdir())

    testthat::expect_s4_class(gpl, "GEOSoft")
    testthat::expect_s4_class(gpl, "GEODatatable")
    testthat::expect_equal(nrow(datatable(gpl)), 22283L)
    testthat::expect_equal(nrow(columns(gpl)), 16L)
    testthat::expect_equal(ncol(datatable(gpl)), 16L)
    testthat::expect_type(metadata(gpl), "list")
    testthat::expect_length(metadata(gpl), 27L)
    testthat::expect_s3_class(datatable(gpl), "data.frame")
})

testthat::test_that("quoted GPL works", {
    gpl <- geo_soft("GPL4133", odir = tempdir())

    testthat::expect_s4_class(gpl, "GEOSoft")
    testthat::expect_s4_class(gpl, "GEODatatable")
    testthat::expect_equal(nrow(columns(gpl)), 22L)
    testthat::expect_equal(nrow(datatable(gpl)), 45220L)
})

testthat::test_that("short GPL works", {
    gpl <- geo_soft("GPL15505", odir = tempdir())

    testthat::expect_s4_class(gpl, "GEOSoft")
    testthat::expect_s4_class(gpl, "GEODatatable")
    testthat::expect_equal(nrow(datatable(gpl)), 52L)
})

testthat::test_that("GPL with no data table works", {
    gpl <- geo_soft("GPL5082", odir = tempdir())

    testthat::expect_s4_class(gpl, "GEOSoft")
    testthat::expect_s4_class(gpl, "GEODatatable")
    testthat::expect_equal(nrow(datatable(gpl)), 0L)
})
