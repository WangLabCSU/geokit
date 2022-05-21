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
