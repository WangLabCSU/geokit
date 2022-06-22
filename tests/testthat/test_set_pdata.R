testthat::test_that("GSE/GSM with characteristic column seperated by no special string warned and parsing column names worked well", {
    testthat::expect_warning(
        gse <- rgeo::get_geo(
            "GSE53987", tempdir(),
            pdata_from_soft = FALSE, add_gpl = FALSE
        ),
        class = "warn_cannot_parse_characteristics",
    )
    pdata <- Biobase::pData(gse)
    data.table::setDT(pdata)
    testthat::expect_error(
        rgeo::set_pdata(pdata),
        regexp = "Please check if `sep` and `split` parameters can parse `columns`."
    )
    pdata[, characteristics_ch1 := stringr::str_replace_all(
        characteristics_ch1,
        "gender|race|pmi|ph|rin|tissue|disease state",
        function(x) paste0("; ", x)
    )]
    rgeo::set_pdata(pdata)
    testthat::expect_true(
        identical(
            length(
                grep("^ch1_", names(pdata),
                    perl = TRUE, value = TRUE
                )
            ), 8L
        )
    )
})
