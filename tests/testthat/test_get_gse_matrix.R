testthat::test_that("empty GSE is handled correctly", {
    gse <- rgeo::get_geo("GSE11413", tempdir())

    testthat::expect_s4_class(gse, "ExpressionSet")
    testthat::expect_equal(nrow(Biobase::pData(gse)), 12L)
    testthat::expect_equal(nrow(Biobase::fData(gse)), 0L)
})

testthat::test_that("case-mismatched IDs in GSEs handled correctly", {
    gse <- rgeo::get_geo("GSE35683", tempdir())

    testthat::expect_equal(nrow(gse), 54675L, ignore_attr = TRUE)
})

testthat::test_that("single-sample GSE handled correctly", {
    gse <- rgeo::get_geo("GSE11595", tempdir())

    testthat::expect_s4_class(gse[[1L]], "ExpressionSet")
    testthat::expect_equal(ncol(gse[[1L]]), 1L, ignore_attr = TRUE)
})

testthat::test_that("short GSE handled correctly", {
    gse <- rgeo::get_geo("GSE34145", tempdir())

    testthat::expect_equal(nrow(gse[[1L]]), 15L, ignore_attr = TRUE)
})

testthat::test_that("GSE with more than one value per characteristic handled", {
    gse <- rgeo::get_geo("GSE71989", tempdir())

    testthat::expect_equal(nrow(gse), 54675L, ignore_attr = TRUE)
    testthat::expect_equal(ncol(gse), 22L, ignore_attr = TRUE)
})

testthat::test_that("GSE has populated experimentData", {
    gse <- rgeo::get_geo("GSE53986", tempdir())

    ed <- Biobase::experimentData(gse)
    testthat::expect_equal(Biobase::pubMedIds(ed), "24739962")

    ei <- Biobase::expinfo(ed)
    testthat::expect_equal(ei[[1L]], "Jason,A,Hackney")
    testthat::expect_equal(ei[[2L]], "") # lab
    testthat::expect_equal(ei[[3L]], "hackney.jason@gene.com")
    testthat::expect_equal(ei[[4L]], "NRROS negatively regulates ROS in phagocytes during host defense and autoimmunity")
    testthat::expect_equal(ei[[5L]], "https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE53986") # url
})

testthat::test_that("GSE populates experimentData as much as possible", {
    gse <- rgeo::get_geo("GSE99709", tempdir())

    ed <- Biobase::experimentData(gse)
    testthat::expect_equal(Biobase::pubMedIds(ed), "")

    ei <- Biobase::expinfo(ed)
    testthat::expect_equal(ei[[1L]], "John,,Mariani")
    testthat::expect_equal(ei[[2L]], "") # lab
    testthat::expect_equal(ei[[3L]], "john_mariani@urmc.rochester.edu")
    testthat::expect_equal(ei[[4L]], "RNA-Sequencing of Stat3 silenced oligodendrocyte progenitor cells.")
    testthat::expect_equal(ei[[5L]], "https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE99709") # url
    # ----------------------------------------------------------------
    gse <- rgeo::get_geo("GSE27712", tempdir())

    ed <- Biobase::experimentData(gse[[1L]])
    testthat::expect_equal(Biobase::pubMedIds(ed), "22253802")

    ei <- Biobase::expinfo(ed)
    testthat::expect_equal(ei[[1L]], "Joachim,L,Schultze")
    testthat::expect_equal(ei[[2L]], "") # lab
    testthat::expect_equal(ei[[3L]], "j.schultze@uni-bonn.de")
    testthat::expect_equal(ei[[4L]], "GC424 tumor cells and gastric tumors")
    testthat::expect_equal(ei[[5L]], "https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE27712") # url
    testthat::expect_equal(Biobase::abstract(ed), "This SuperSeries is composed of the SubSeries listed below.")
})

testthat::test_that("GSE/GPL with integer64 columns handled correctly", {
    gse <- rgeo::get_geo("GSE7864", tempdir())
    fdata <- Biobase::fData(gse)
    testthat::expect_s3_class(fdata$ID, "integer64")
    testthat::expect_type(rownames(fdata), "character")
})

testthat::test_that("GSE/GSM with characteristic column seperated by no special string warned", {
    testthat::expect_warning(rgeo::get_geo("GSE53987", tempdir()))
})
