testthat::test_that("log_trans transforms linear matrices with pseudo offset", {
    mat <- matrix(c(1, 8, 27, 64), nrow = 2)
    out <- NULL
    testthat::expect_message(
        out <- log_trans(mat),
        "Applying log2 transformation"
    )
    testthat::expect_equal(out, log2(mat + 1))

    out2 <- NULL
    testthat::expect_message(
        out2 <- log_trans(mat, pseudo = 2),
        "pseudo count"
    )
    testthat::expect_equal(out2, log2(mat + 2))
})

testthat::test_that("log_trans keeps already log-scale data untouched", {
    mat <- log2(outer(1:10, c(1, 10, 100, 1000))) + 5
    out <- NULL
    testthat::expect_message(
        out <- log_trans(mat),
        "already log-transformed"
    )
    testthat::expect_identical(out, mat)
})

testthat::test_that("log_trans handles ExpressionSet objects", {
    testthat::skip_if_not_installed("Biobase")
    mat <- matrix(c(1, 8, 27, 64, 125, 216), nrow = 2)
    eset <- Biobase::ExpressionSet(
        assayData = Biobase::assayDataNew(exprs = mat)
    )
    out <- NULL
    testthat::expect_message(out <- log_trans(eset))
    testthat::expect_s4_class(out, "ExpressionSet")
    testthat::expect_equal(
        Biobase::exprs(out), log2(mat + 1),
        ignore_attr = "dimnames"
    )
    testthat::expect_identical(dim(out), dim(eset))
})
