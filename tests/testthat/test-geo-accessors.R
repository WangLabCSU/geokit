testthat::test_that("record accessors read and write GEOSoft slots", {
    obj <- methods::new(
        "GEOSoft",
        rcd_type = "Sample",
        rcd_name = "GSM1",
        accession = "GSM1"
    )

    testthat::expect_identical(rcd_type(obj), "Sample")
    testthat::expect_identical(rcd_name(obj), "GSM1")
    testthat::expect_identical(accession(obj), "GSM1")
    testthat::expect_type(metadata(obj), "list")

    rcd_type(obj) <- "Platform"
    rcd_name(obj) <- "GPL1"
    testthat::expect_identical(rcd_type(obj), "Platform")
    testthat::expect_identical(rcd_name(obj), "GPL1")
})

testthat::test_that("GEOSoft validity enforces scalar record identity", {
    testthat::expect_error(methods::new("GEOSoft", rcd_type = c("a", "b")))
    testthat::expect_error(methods::new("GEOSoft", rcd_name = character()))
})

testthat::test_that("accessors stay consistent on parsed SOFT records", {
    gsm <- skip_if_download_fail(geo_soft("GSM11805", odir = tempdir()))

    testthat::expect_identical(rcd_name(gsm), accession(gsm))
    testthat::expect_type(rcd_type(gsm), "character")
    testthat::expect_false(is.na(rcd_type(gsm)))
})
