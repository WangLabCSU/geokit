#' Apply log2 transformation for matrix data if not.
#'
#' @param data A matrix-like data object.
#' @param pseudo Since expression values for a gene can be zero in some
#' conditions (and non-zero in others), some advocate the use of
#' pseudo-expression values, i.e. transformations of the form: log2(exprs +
#' pseudo)
#' @details Automatically check whether `data` has been logarithmically
#' transformed, if not, applying a log2 transformation. The test methodology for
#' logarithm transformation is based on
#' [GEO2R](https://www.ncbi.nlm.nih.gov/geo/geo2r/)
#' @references [geo2r
#' analysis](https://www.ncbi.nlm.nih.gov/geo/geo2r/?acc=GSE1122)
#' @return A `matrix` or an [ExpressionSet][Biobase::ExpressionSet] object
#' @export
log_trans <- function(data, pseudo = 1) {
    if (inherits(data, "ExpressionSet")) {
        expr_data <- Biobase::exprs(data)
    } else if (inherits(data, "matrix")) {
        expr_data <- data
    } else {
        rlang::abort("data should be a class of `matrix` or `ExpressionSet`")
    }
    if (is_log_trans(expr_data)) {
        rlang::inform("log2 transformation wasn't needed")
        return(data)
    } else {
        rlang::inform("Doing log2 transformation")
        expr_data <- log2(expr_data + pseudo)
    }
    if (inherits(data, "ExpressionSet")) {
        Biobase::exprs(data) <- expr_data
        return(data)
    }
    if (inherits(data, "matrix")) {
        return(expr_data)
    }
}

# check whether vector is log transformation ------------------------------
# a scalar logical value, `TRUE` means logged, and `FALSE` indicates not.
is_log_trans <- function(x) {
    qx <- as.numeric(
        stats::quantile(x, c(0, 0.25, 0.5, 0.75, 0.99, 1.0), na.rm = TRUE)
    )
    not_log <- (qx[[5L]] > 100) ||
        (qx[[6L]] - qx[[1L]] > 50 && qx[[2L]] > 0) ||
        (qx[[2L]] > 0 && qx[[2L]] < 1 && qx[[4L]] > 1 && qx[[4L]] < 2)

    !not_log
}
