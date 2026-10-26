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
    # the result always keeps one row per input element, like
    # stringr::str_match(). the column count (full match + capture groups)
    # must come from an element that actually matched: a non-match reports a
    # single -1 position and carries no group information, so when nothing
    # matches the result degrades to one all-NA column
    n_cols <- 1L
    for (m in matches) {
        if (m[[1L]] != -1L) {
            n_cols <- length(attr(m, "match.length"))
            break
        }
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
