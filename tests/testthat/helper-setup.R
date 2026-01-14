# It's easy to encounter issues when downloading files from the GEO database.
# This function skips the test if the function fails.
skip_if_fail <- function(expr) {
    deparsed <- deparse(substitute(expr))
    tryCatch(expr, geokit_download_error = function(cnd) {
        testthat::skip(sprintf("Failed to execute '%s'", deparsed))
    })
}
