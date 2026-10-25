# base R equivalents of stringr helpers used internally ----
str_subset <- function(string, pattern, ..., fixed = FALSE) {
    grep(
        pattern = pattern, x = string, ...,
        perl = !fixed, value = TRUE,
        fixed = fixed
    )
}

str_replace <- function(string, pattern, replacement, ..., fixed = FALSE) {
    sub(
        pattern = pattern, replacement = replacement, x = string,
        perl = !fixed, fixed = fixed, ...
    )
}

str_replace_all <- function(string, pattern, replacement, ..., fixed = FALSE) {
    gsub(
        pattern = pattern, replacement = replacement, x = string,
        perl = !fixed, fixed = fixed, ...
    )
}

str_extract_all <- function(string, pattern, ..., fixed = FALSE) {
    regmatches(
        string,
        m = gregexpr(
            pattern = pattern, text = string,
            perl = !fixed, ..., fixed = fixed
        )
    )
}

str_split <- function(string, pattern, fixed = FALSE) {
    strsplit(x = string, split = pattern, fixed = fixed, perl = !fixed)
}

str_match <- function(string, pattern, ..., fixed = FALSE) {
    matches <- regexec(
        pattern = pattern, text = string,
        perl = !fixed, ..., fixed = fixed
    )
    out <- regmatches(string, matches, invert = FALSE)
    # a non-matching element yields character(0); pad it with an all-NA row so
    # the result always keeps one row (and one column per capture group) per
    # input element, like stringr::str_match()
    n_cols <- if (length(matches)) {
        length(attr(matches[[1L]], "match.length"))
    } else {
        1L
    }
    out <- lapply(out, function(x) {
        if (!length(x)) rep(NA_character_, n_cols) else x
    })
    out <- do.call("rbind", out)
    if (is.null(out)) {
        return(out)
    }
    out[out == ""] <- NA_character_
    out
}
