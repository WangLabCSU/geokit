testthat::test_that("generic GDS parsing works as expected", {
    gds <- rgeo::get_geo("GDS507", tempdir())

    testthat::expect_s4_class(gds, "GDS") 
    testthat::expect_type(meta(gds), "list") 
    testthat::expect_s3_class(columns(gds), "data.frame") 
    testthat::expect_s3_class(datatable(gds), "data.frame") 
    testthat::expect_equal(nrow(columns(gds)), 19L)
    testthat::expect_equal(ncol(columns(gds)), 4L)
    testthat::expect_length(meta(gds), 21L) 
})
