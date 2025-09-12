testthat::test_that("generic SOFT format GSE handled correctly", {
    gse <- get_geo("GSE1563", tempdir(), gse_matrix = FALSE)

    testthat::expect_equal(length(gsm(gse)), 62L)
    testthat::expect_equal(length(gpl(gse)), 1L)
    testthat::expect_equal(nrow(datatable(gpl(gse)[[1L]])), 12625L)
    testthat::expect_equal(nrow(datatable(gsm(gse)[[1L]])), 12625L)
    lapply(gsm(gse), function(x) {
        testthat::expect_s4_class(x, "GEOSoft")
        testthat::expect_equal(nrow(datatable(x)), 12625L)
    }) 
    testthat::expect_s4_class(gpl(gse)[[1L]], "GEOSoft")
    testthat::expect_equal(accession(gse), "GSE1563")
})
