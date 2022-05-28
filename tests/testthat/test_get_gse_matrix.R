test_that("empty GSE is handled correctly", {
    gse <- rgeo::get_geo("GSE11413", tempdir())

    expect_s4_class(gse, "ExpressionSet")
    expect_equal(nrow(Biobase::pData(gse)), 12)
    expect_equal(nrow(Biobase::fData(gse)), 0)
})

test_that("case-mismatched IDs in GSEs handled correctly", {
    gse <- rgeo::get_geo("GSE35683", tempdir())

    expect_equal(nrow(gse), 54675, ignore_attr = TRUE)
})

test_that("GSE has populated experimentData", {
    gse <- rgeo::get_geo("GSE53986", tempdir())

    ed <- Biobase::experimentData(gse)
    testthat::expect_equal(Biobase::pubMedIds(ed), "24739962")

    ei <- Biobase::expinfo(ed)
    testthat::expect_equal(ei[[1]], "Jason,A,Hackney")
    testthat::expect_equal(ei[[2]], "") # lab
    testthat::expect_equal(ei[[3]], "hackney.jason@gene.com")
    testthat::expect_equal(ei[[4]], "NRROS negatively regulates ROS in phagocytes during host defense and autoimmunity")
    testthat::expect_equal(ei[[5]], "https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE53986") # url
})

test_that("GSE/GPL with integer64 columns handled correctly", {
    gse <- rgeo::get_geo("GSE7864", tempdir())
    fdata <- Biobase::fData(gse)
    expect_s3_class(fdata$ID, "integer64")
    expect_type(rownames(fdata), "character")
})

testthat::test_that("GSE populates experimentData as much as possible", {
    gse <- rgeo::get_geo("GSE99709", tempdir())

    ed <- Biobase::experimentData(gse)
    testthat::expect_equal(Biobase::pubMedIds(ed), "")

    ei <- Biobase::expinfo(ed)
    testthat::expect_equal(ei[[1]], "John,,Mariani")
    testthat::expect_equal(ei[[2]], "") # lab
    testthat::expect_equal(ei[[3]], "john_mariani@urmc.rochester.edu")
    testthat::expect_equal(ei[[4]], "RNA-Sequencing of Stat3 silenced oligodendrocyte progenitor cells.")
    testthat::expect_equal(ei[[5]], "https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE99709") # url
    # ----------------------------------------------------------------
    gse <- rgeo::get_geo("GSE27712", tempdir())

    ed <- Biobase::experimentData(gse[[1]])
    testthat::expect_equal(Biobase::pubMedIds(ed), "22253802")

    ei <- Biobase::expinfo(ed)
    testthat::expect_equal(ei[[1]], "Joachim,L,Schultze")
    testthat::expect_equal(ei[[2]], "") # lab
    testthat::expect_equal(ei[[3]], "j.schultze@uni-bonn.de")
    testthat::expect_equal(ei[[4]], "GC424 tumor cells and gastric tumors")
    testthat::expect_equal(ei[[5]], "https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE27712") # url
    testthat::expect_equal(Biobase::abstract(ed), "This SuperSeries is composed of the SubSeries listed below.")
})
