testthat::test_that("GSE/GSM with characteristic column seperated by no special string warned", {
    testthat::expect_warning(
        gse <- rgeo::get_geo("GSE53987", tempdir()),
        class = "warn_cannot_parse_characteristics"
    )
    pdata <- Biobase::pData(gse)
    data.table::setDT(pdata)
    testthat::expect_error(
        rgeo::set_char(pdata),
        regexp = "Please check if `con` and `split` parameters can parse `columns`."
    )
})
