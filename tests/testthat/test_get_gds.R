testthat::test_that("generic GDS parsing works as expected", {
    gds <- geo_soft("GDS507", odir = tempdir())

    testthat::expect_s4_class(gds, "GEOSoft")
    testthat::expect_type(metadata(gds), "list")
    testthat::expect_length(metadata(gds), 3L)
    testthat::expect_s3_class(columns(gds), "data.frame")
    testthat::expect_s3_class(datatable(gds), "data.frame")
    testthat::expect_equal(nrow(columns(gds)), 19L)
    testthat::expect_equal(ncol(columns(gds)), 1L)
})
