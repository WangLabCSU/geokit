#' @import data.table
#' @import rlang
NULL

#' To read gz and bz2 files directly for fread()
#' @import R.utils
NULL

str_extract_all <- function(string, pattern) {
    regmatches(
        string,
        gregexpr(pattern, string, perl = TRUE, fixed = FALSE),
        invert = FALSE
    )
}
column_to_rownames <- function(.data, var) {
    rownames(.data) <- .data[[var]]
    .data[[var]] <- NULL
    .data
}

read_lines <- function(file) {
    data.table::fread(
        file = file, sep = "", header = FALSE,
        colClasses = "character"
    )[[1]]
}

check_ids <- function(ids) {
    geotype <- unique(substr(ids, 1L, 3L))
    id_test <- any(!geotype %in% c("GSE", "GPL", "GSM", "GDS"))
    if (id_test) {
        rlang::abort(
            c("`ids` should representing the GEO identity (One of GSE, GDS, GSM and GPL). Please check the `ids` provided is correct.")
        )
    }
}

`%||%` <- function(x, y) if (!is.null(x)) x else y
