# str_match() is an internal base-R reimplementation of stringr::str_match();
# lock down the semantics the package relies on, especially for non-matches
testthat::test_that("str_match returns one column per capture group on match", {
    matched <- str_match("characteristics_ch1.2_3", "(ch\\d*)(\\.\\d*)?(_\\d*)?$")
    testthat::expect_identical(
        matched,
        matrix(c("ch1.2_3", "ch1", ".2", "_3"), nrow = 1L)
    )
})

testthat::test_that("str_match pads non-matching input with all-NA rows", {
    pattern <- "(ch\\d*)(\\.\\d*)?(_\\d*)?$"

    # a single non-match keeps one row; the width comes from any matching
    # element, so here it degrades to a single all-NA column
    no_match <- str_match("custom_col", pattern)
    testthat::expect_identical(dim(no_match), c(1L, 1L))
    testthat::expect_true(all(is.na(no_match)))

    # in mixed input the width is taken from the matching element
    mixed <- str_match(c("custom_col", "characteristics_ch1"), pattern)
    testthat::expect_identical(dim(mixed), c(2L, 4L))
    testthat::expect_true(all(is.na(mixed[1L, ])))
    testthat::expect_identical(mixed[2L, ], c("ch1", "ch1", NA, NA))
})

testthat::test_that("str_match handles groupless patterns and empty input", {
    plain <- str_match(c("abc", "xyz"), "a")
    testthat::expect_identical(dim(plain), c(2L, 1L))
    testthat::expect_identical(plain[, 1L], c("a", NA))

    testthat::expect_null(str_match(character(0), "a"))
})
