str_extract <- function(string, pattern, ignore.case = FALSE) {
    matches <- regexpr(pattern, string,
        perl = TRUE, fixed = FALSE,
        ignore.case = ignore.case
    )
    start <- as.vector(matches)
    end <- start + attr(matches, "match.length") - 1L
    start[start == -1L] <- NA_integer_
    substr(string, start, end)
}
str_extract_all <- function(string, pattern, ignore.case = FALSE) {
    regmatches(
        string,
        gregexpr(pattern, string,
            perl = TRUE, fixed = FALSE,
            ignore.case = ignore.case
        ),
        invert = FALSE
    )
}
# split string based on pattern, Only split once, Return a list of character,
# the length of every element is two
str_split <- function(string, pattern, ignore.case = FALSE) {
    regmatches(
        string,
        regexpr(pattern, string,
            perl = TRUE, fixed = FALSE,
            ignore.case = ignore.case
        ),
        invert = TRUE
    )
}

str_match <- function(string, pattern, ignore.case = FALSE) {
    out <- regmatches(
        string,
        regexec(pattern, string,
            perl = TRUE, fixed = FALSE,
            ignore.case = ignore.case
        ),
        invert = FALSE
    )
    out <- do.call("rbind", out)
    out[out == ""] <- NA_character_
    out
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
    )[[1L]]
}

check_ids <- function(ids) {
    geotype <- unique(substr(ids, 1L, 3L))
    id_test <- any(!geotype %in% c("GSE", "GPL", "GSM", "GDS"))
    if (id_test) {
        rlang::abort(
            c(
                "`ids` should representing the GEO identity.",
                "Please check the `ids` provided is correct."
            )
        )
    }
}

wrap_cat <- function(label, names, indent = 0L, exdent = 2L) {
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
        indent = indent, exdent = exdent
    ), sep = "\n")
}

`%||%` <- function(x, y) if (is.null(x)) y else x
