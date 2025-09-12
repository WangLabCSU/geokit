#' Apply log2 Transformation to Expression Data
#'
#' Checks whether the input data is already log-transformed; if not,
#' applies a log2 transformation. This helps ensure comparability
#' of expression values across datasets.
#'
#' @param data A matrix-like data object.
#' @param pseudo A numeric value added before transformation to avoid
#'   taking log of zero. For example, `log2(exprs + pseudo)`.
#' @param ... Additional arguments passed to methods.
#' @details
#' The function heuristically determines whether `data` has been
#' log-transformed, following the methodology used in
#' [GEO2R](https://www.ncbi.nlm.nih.gov/geo/geo2r/). If not, it
#' applies `log2()` with the specified `pseudo` offset.
#' @references
#' NCBI GEO2R: <https://www.ncbi.nlm.nih.gov/geo/geo2r/?acc=GSE1122>
#' @return A `matrix` or an [ExpressionSet][Biobase::ExpressionSet] with
#'   log2-transformed expression values.
#' @export
log_trans <- function(data, pseudo = 1, ...) {
    assert_number_decimal(pseudo, allow_infinite = FALSE)
    UseMethod("log_trans")
}

#' @export
#' @rdname log_trans
log_trans.matrix <- function(data, pseudo = 1, ...) {
    if (is_log_trans(data)) {
        cli::cli_inform("log2 transformation wasn't needed")
    } else {
        cli::cli_inform("Doing log2 transformation")
        data <- log2(data + pseudo)
    }
    data
}

#' @export
#' @rdname log_trans
log_trans.ExpressionSet <- function(data, pseudo = 1, ...) {
    Biobase::exprs(data) <- log_trans.matrix(Biobase::exprs(data), pseudo)
    data
}

# check whether vector is log transformation ------------------------------
# a scalar logical value, `TRUE` means logged, and `FALSE` indicates not.
is_log_trans <- function(x) {
    qx <- stats::quantile(x, c(0, 0.25, 0.5, 0.75, 0.99, 1.0), na.rm = TRUE)
    qx <- as.numeric(qx)
    not_log <- (qx[[5L]] > 100) ||
        (qx[[6L]] - qx[[1L]] > 50 && qx[[2L]] > 0) ||
        (qx[[2L]] > 0 && qx[[2L]] < 1 && qx[[4L]] > 1 && qx[[4L]] < 2)

    !not_log
}
