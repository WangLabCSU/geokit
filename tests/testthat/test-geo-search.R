# geo_search() goes through rentrez/curl instead of the download layer, so
# `skip_if_download_fail()` cannot catch its network errors. Skip when the
# failure looks like a network problem, but let real bugs surface.
skip_if_search_unreachable <- function(expr) {
    deparsed <- deparse(substitute(expr))
    tryCatch(
        expr,
        error = function(cnd) {
            msg <- conditionMessage(cnd)
            if (grepl(
                "Timeout|timed out|resolve|SSL|TLS|connection|status code|Failed",
                msg,
                ignore.case = TRUE
            )) {
                testthat::skip(sprintf(
                    "NCBI unreachable during '%s': %s",
                    deparsed, msg
                ))
            }
            stop(cnd)
        }
    )
}

testthat::test_that("geo_search returns parsed summary records", {
    hits <- skip_if_search_unreachable(
        geo_search(
            "diabetic nephropathy[ALL] AND Homo sapiens[ORGN] AND GSE[ETYP]",
            step = 50L
        )
    )

    testthat::expect_s3_class(hits, "data.frame")
    testthat::expect_gt(nrow(hits), 0L)
    for (col in c("Title", "Contains")) {
        testthat::expect_true(col %in% colnames(hits), info = col)
    }
    # accession columns are moved to the tail of the data frame
    testthat::expect_true(grepl("Accession$", tail(colnames(hits), 1L)))
})

testthat::test_that("geo_search errors informatively on empty results", {
    testthat::expect_error(
        skip_if_search_unreachable(
            geo_search("qqno-such-term-xyzzy[ALL] AND GDS[ETYP]", step = 5L)
        )
    )
})
