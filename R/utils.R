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
    if (any(geotype %in% c("GPL", "GSM", "GDS"))) {
        rlang::abort(
            c(
                "Sorry, Current `rgeo` only support parse GSE matrix.",
                "Please check the `ids` provided is correct."
            )
        )
    }
    if (id_test) {
        rlang::abort(
            c(
                "`ids` should representing the GEO GSE identity.",
                "Please check the `ids` provided is correct."
            )
        )
    }
}

wrap_cat <- function(label, names) {
    label <- sprintf("%s:", label)
    total <- length(names)

    ext <- if (identical(total, 0L)) {
        "none"
    } else if (total <= 6L) {
        paste(names, collapse = " ")
    } else {
        paste(
            paste(names[1:3], collapse = " "),
            "...",
            paste(names[(total - 1L):total], collapse = " "),
            sprintf("(%d total)", total),
            sep = " "
        )
    }
    cat(strwrap(
        paste(label, ext, sep = " "),
        indent = 2L, exdent = 4L
    ), sep = "\n")
}

`%||%` <- function(x, y) if (!is.null(x)) x else y
