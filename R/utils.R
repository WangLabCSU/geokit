# stingr from base R ---------------------------------
# str_which <- function(string, pattern, ...) {
#     grep(
#         pattern = pattern, x = string, ...,
#         perl = TRUE,
#         value = FALSE
#     )
# }
# str_extract <- function(string, pattern, ...) {
#     matches <- regexpr(pattern, string, perl = TRUE)
#     start <- as.vector(matches)
#     end <- start + attr(matches, "match.length") - 1L
#     start[start == -1L] <- NA_integer_
#     substring(string, start, end)
# }
# str_extract_all <- function(string, pattern, ..., invert = FALSE) {
#     regmatches(
#         string,
#         m = gregexpr(pattern = pattern, text = string, perl = TRUE, ...),
#         invert = invert
#     )
# }
# split string based on pattern, Only split once, Return a list of character,
# the length of every element is two
# str_split_fixed <- function(string, pattern, ...) {
#     regmatches(
#         string,
#         regexpr(pattern = pattern, text = string,
#             perl = TRUE, ...
#         ),
#         invert = TRUE
#     )
# }
# str_match <- function(string, pattern, ...) {
#     out <- regmatches(
#         string,
#         regexec(pattern = pattern, text = string,
#             perl = TRUE, ...
#         ),
#         invert = FALSE
#     )
#     out <- lapply(out, function(x) {
#         if (!length(x)) "" else x
#     })
#     out <- do.call("rbind", out)
#     out[out == ""] <- NA_character_
#     out
# }

# stingr from stringi --------------------------
str_c <- function(...) {
    stringi::stri_c(...)
}

str_detect <- function(string, ...) {
    stringi::stri_detect(str = string, ...)
}

str_which <- function(string, ..., use_names = FALSE) {
    which(str_detect(str = string, ...), useNames = use_names)
}

str_sub <- function(string, from = 1L, to = -1L, ..., use_matrix = FALSE) {
    stringi::stri_sub(
        str = string, from = from, to = to,
        use_matrix = use_matrix
    )
}

str_subset <- function(string, ...) {
    stringi::stri_subset(str = string, ...)
}

str_replace <- function(string, ...) {
    stringi::stri_replace(str = string, ...)
}

str_replace_all <- function(string, ...) {
    stringi::stri_replace_all(str = string, ...)
}

str_extract <- function(string, ...) {
    stringi::stri_extract(str = string, ...)
}

str_extract_all <- function(string, ...) {
    stringi::stri_extract_all(str = string, ...)
}

#' @return A list, each element with the same length
#' @noRd
str_split_fixed <- function(string, n, ...) {
    stringi::stri_split(str = string, n = n, ...)
}

#' @return A list
#' @noRd
str_split <- function(string, n = -1L, ...) {
    stringi::stri_split(str = string, ..., n = n)
}

str_match <- function(string, ...) {
    stringi::stri_match(str = string, ...)
}

# Other utilities -------------------------------
return_object_or_list <- function(x, names = NULL) {
    if (length(x) == 1L) {
        x[[1L]]
    } else {
        if (!is.null(names)) names(x) <- names
        x
    }
}

read_lines <- function(file) {
    data.table::fread(
        file = file, sep = "", header = FALSE,
        colClasses = "character",
        showProgress = FALSE
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
    data.table::fwrite(list(text),
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

check_ids <- function(ids, arg = rlang::caller_arg(ids), call = parent.frame()) {
    geotypes <- stringi::stri_sub(ids, 1L, 3L, use_matrix = FALSE)
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
}

wrap_cat <- function(label, names, indent = 0L, exdent = 2L) {
    label <- sprintf("%s:", label)
    total <- length(names)

    ext <- if (total == 0L) {
        "none"
    } else if (total <= 6L) {
        str_c(names, collapse = " ")
    } else {
        str_c(
            str_c(names[1:3], collapse = " "),
            "...",
            str_c(names[(total - 1L):total], collapse = " "),
            sprintf("(%d total)", total),
            sep = " "
        )
    }
    cat(strwrap(
        str_c(label, ext, sep = " "),
        indent = indent, exdent = exdent
    ), sep = "\n")
}

`%||%` <- function(x, y) if (is.null(x)) y else x
