str_extract_all <- function(string, pattern) {
    regmatches(
        string, 
        gregexpr(pattern, string, perl = TRUE, fixed = FALSE),
        invert = FALSE
    )
}
