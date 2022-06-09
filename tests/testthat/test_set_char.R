testthat::test_that("GSE/GSM with characteristic column seperated by no special string warned and parsing column names worked well", {
    testthat::expect_warning(
        gse <- rgeo::get_geo("GSE53987", tempdir()),
        class = "warn_cannot_parse_characteristics"
    )
    pdata <- Biobase::pData(gse)
    data.table::setDT(pdata)
    testthat::expect_error(
        rgeo::set_char(pdata),
        regexp = "Please check if `sep` and `split` parameters can parse `columns`."
    )
    gse53987_smp_info[, characteristics_ch1 := stringr::str_replace_all(
        characteristics_ch1,
        "gender|race|pmi|ph|rin|tissue|disease state",
        function(x) paste0("; ", x)
    )]
    rgeo::set_char(gse53987_smp_info)
    testthat::expect_true(
        identical(
            length(
                grep("^ch1_", names(gse53987_smp_info),
                    perl = TRUE, value = TRUE
                )
            ), 8L
        )
    )
})
