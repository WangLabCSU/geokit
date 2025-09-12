testthat::test_that("GSE/GSM with characteristic column seperated by no special string warned and parsing column names worked well", {
    testthat::expect_s4_class(
        get_geo("GSE8462", odir = tempdir()), "ExpressionSet"
    )
    testthat::expect_warning(
        gse <- get_geo(
            "GSE53987",
            odir = tempdir(),
            pdata_from_soft = FALSE, add_gpl = FALSE
        ),
        class = "warn_cannot_parse_characteristics"
    )
    pdata <- Biobase::pData(gse)
    testthat::expect_error(
        parse_pdata(pdata),
        regexp = "Please check if `sep` and `split` parameters can parse `columns`."
    )
    pdata$characteristics_ch1 <- stringr::str_replace_all(
        pdata$characteristics_ch1,
        "gender|race|pmi|ph|rin|tissue|disease state",
        function(x) paste0("; ", x)
    )
    pdata <- parse_pdata(pdata)
    testthat::expect_true(
        length(
            grep("^ch1_", names(pdata),
                perl = TRUE, value = TRUE
            )
        ) == 8L
    )
    testthat::expect_type(pdata$ch1_age, "integer")
    testthat::expect_type(pdata$ch1_gender, "character")
    testthat::expect_type(pdata$ch1_race, "character")
    testthat::expect_type(pdata$ch1_pmi, "double")
    testthat::expect_type(pdata$ch1_ph, "double")
    testthat::expect_type(pdata$ch1_rin, "double")
    testthat::expect_type(pdata$ch1_tissue, "character")
    testthat::expect_type(pdata$`ch1_disease state`, "character")
})
