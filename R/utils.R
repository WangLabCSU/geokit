`%||%` <- function(x, y) if (is.null(x)) y else x

return_object_or_list <- function(x, names = NULL) {
    if (length(x) == 1L) {
        x[[1L]]
    } else {
        if (!is.null(names)) names(x) <- names
        x
    }
}

read_internal <- function(file = NULL) {
    if (is.null(file)) {
        dir(pkg_extdata())
    } else {
        readRDS(pkg_extdata(file, mustWork = TRUE))
    }
}

set_rownames <- function(x, var = 1L) {
    if (nrow(x)) {
        data.table::setDF(x, rownames = as.character(x[[var]]))
    } else {
        data.table::setDF(x)
    }
}

column_to_rownames <- function(x, var = 1L) {
    data.table::setDF(x[, .SD, .SDcols = !var], # nolint
        rownames = as.character(x[[var]])
    )
}

dir_create <- function(path, ...) {
    if (!dir.exists(path) &&
        !dir.create(path = path, showWarnings = FALSE, ...)) {
        cli::cli_abort("Cannot create directory {.path {path}}")
    }
    invisible(path)
}

read_lines <- function(file, ...) {
    data.table::fread(
        file = file,
        sep = "",
        header = FALSE,
        colClasses = "character",
        showProgress = FALSE,
        ...
    )[[1L]]
}

# comment code to benchmark writeLines
# gen_random <- function(characters, num_lines, min, max) {
#     line_lengths <- sample.int(max - min, num_lines, replace = TRUE) + min
#     vapply(line_lengths, function(len) {
#         paste(sample(characters, len, replace = TRUE), collapse = "")
#     }, character(1))
# }
# set.seed(42)
# generate 1000 random lines between 100-1000 characters long
# data <- gen_random(letters, 500, min = 100, max = 1000)
# bench::mark(
#     brio::write_lines(data, tempfile()),
#     data.table::fwrite(list(data), tempfile(),
#         quote = FALSE,
#         col.names = FALSE
#     ),
#     base::writeLines(data, tempfile()),
#     check = FALSE
# )
#    min   median itr/se…¹ mem_a…² gc/se…³ n_itr  n_gc total…⁴
# 1 1.97ms   2.71ms     353.      0B    0      177     0   502ms
# 2 1.22ms   1.36ms     703.      0B    2.02   348     1   495ms
# 3 3.75ms   4.24ms     224.      0B    0      113     0   504ms
#' @param text A character vector
#' @noRd
read_text <- function(text, ...) {
    if (!length(text)) {
        return(data.table::data.table())
    }
    file <- tempfile()
    data.table::fwrite(
        list(text),
        file = file,
        quote = FALSE,
        na = "NA",
        col.names = FALSE,
        logical01 = FALSE,
        showProgress = FALSE,
        compress = "none",
        verbose = FALSE
    )
    # brio::write_lines(text, file)
    on.exit(file.remove(file))
    data.table::fread(
        file = file, ...,
        na.strings = na_string,
        showProgress = FALSE
    )
}

na_string <- c("NA", "null", "NULL", "Null")

#' @importFrom data.table %chin%
#' @importFrom rlang caller_arg caller_env
check_ids <- function(ids, arg = caller_arg(ids), call = caller_env()) {
    ids <- toupper(ids)
    geotypes <- substr(ids, 1L, 3L)
    is_geo_types <- geotypes %chin% c("GSE", "GPL", "GSM", "GDS")
    if (any(!is_geo_types)) {
        cli::cli_abort(
            "Invalid values provided in {.arg {arg}}: {.val {unique(geotypes[!is_geo_types])}}",
            call = call
        )
    }
    if (any(geotypes != geotypes[1L])) {
        cli::cli_abort(
            "All {.arg {arg}} must be the same GEO types",
            call = call
        )
    }
    ids
}

wrap_cat <- function(label, names, indent = 0L, exdent = 2L) {
    label <- sprintf("%s:", label)
    total <- length(names)

    ext <- if (total == 0L) {
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
