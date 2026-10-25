testthat::test_that("geo_meta returns collapsed series metadata", {
    meta <- skip_if_download_fail(geo_meta("GSE10", odir = tempdir()))

    testthat::expect_s3_class(meta, "data.frame")
    testthat::expect_gte(nrow(meta), 1L)
    for (col in c("Series_geo_accession", "Series_title")) {
        testthat::expect_true(col %in% colnames(meta), info = col)
    }
    testthat::expect_true("GSE10" %in% meta$Series_geo_accession)
})

testthat::test_that("geo_meta is vectorized over accessions", {
    meta <- skip_if_download_fail(
        geo_meta(c("GSE10", "GSE1563"), odir = tempdir())
    )

    testthat::expect_s3_class(meta, "data.frame")
    testthat::expect_true(
        all(c("GSE10", "GSE1563") %in% meta$Series_geo_accession)
    )
})
