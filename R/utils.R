#' @import data.table
#' @import rlang
#' @import Biobase
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
    id_test <- length(unique(geotype)) > 1L || 
        any(!geotype %in% c("GSE", "GPL", "GSM", "GDS"))
    if (id_test) {
        rlang::abort(
            c("`ids` should representing the same GEO identity (One of GSE, GDS, GSM and GPL).")
        )
    }
}

`%null%` <- function(x, y) if (!is.null(x)) x else y

#' @importFrom curl new_handle handle_setopt
h <- curl::new_handle()
curl::handle_setopt(h, buffersize = 33554432)
