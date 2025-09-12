#' Retrieve GEO Objects from NCBI GEO
#'
#' @description
#' This is the main user-facing function in the `r pkg_nm()` package. It
#' downloads and parses GEO files, returning objects corresponding to different
#' GEO entity types.
#'
#' `geo()` allows programmatic access to
#' [NCBI GEO](http://www.ncbi.nlm.nih.gov/geo) data. GEO stores high-throughput
#' experimental data, including microarrays, SAGE, and mass spectrometry
#' proteomics. Entities handled by `geo()` include:
#'
#' - **Platform (GPLxxx)**: Defines probe elements or detectable molecules.
#' - **Sample (GSMxxx)**: Describes conditions and measurements for individual
#'   samples.
#' - **Series (GSExxx)**: Groups related samples, describing experimental
#'   context.
#' - **DataSet (GDSxxx)**: Curated sets of comparable samples.
#'
#' The function downloads and parses the relevant SOFT or Series Matrix files,
#' optionally mapping platform IDs to Bioconductor annotation packages.
#'
#' @param ids Character vector of GEO accession IDs to download and parse.
#'   All IDs must belong to the same GEO entity type. Examples:
#'   - DataSets: `c("GDS505", "GDS606")`
#'   - Series: `c("GSE2", "GSE22")`
#' @param amount A character string specifying the amount of data to retrieve.
#'   One of `"brief"`, `"quick"`, `"data"`, or `"full"`.
#'   - `"brief"`: shows only the accession's attributes.
#'   - `"quick"`: shows the accession's attributes and the first 20 rows of
#'     its data table.
#'   - `"full"` (default): shows the accession's attributes and the complete
#'     data table.
#'   - `"data"`: omits the accession's attributes, showing only links to other
#'     accessions and the full data table.
#' @param gse_matrix Logical, whether to retrieve Series Matrix files for
#'   `GSE` entities. If `TRUE`, an [`ExpressionSet`][Biobase::ExpressionSet] is
#'   returned.
#' @param pdata_from_soft Logical, whether to derive `phenoData` from the GSE
#'   series SOFT file when creating an
#'   [`ExpressionSet`][Biobase::ExpressionSet].  Defaults to `TRUE`. If `FALSE`,
#'   `phenoData` is parsed from the series matrix file; note that some
#'   `characteristics_ch*` columns may not parse correctly.
#' @param add_gpl Logical or `NULL`. Whether to include platform information
#'   (the [`featureData`][Biobase::featureData] slot) when handling `GSE`
#'   entities with `gse_matrix = TRUE`. If `NULL` (default), the function
#'   attempts to map the GPL accession to a Bioconductor annotation package. If
#'   successful, the [`annotation`][Biobase::eSet] slot is updated and `add_gpl`
#'   is set to `FALSE`; otherwise, `add_gpl` is set to `TRUE`.
#' @param ftp_over_https Logical scalar. If `TRUE`, connects to GEO FTP via
#'   HTTPS (`https://ftp.ncbi.nlm.nih.gov/geo`); otherwise, uses plain FTP.
#' @param handle_opts A list of named options / headers to be set in the
#'  [`multi_download`][curl::multi_download].
#' @param odir Destination directory for downloads. Defaults to the current
#' working directory.
#' @return Returns an object corresponding to the GEO entity type:
#' - `GSE` with `gse_matrix = FALSE`: [GEOSeries-class] object.
#' - `GSE` with `gse_matrix = TRUE`: an
#'   [`ExpressionSet`][Biobase::ExpressionSet] or a list of `ExpressionSet`s,
#'   one per Series Matrix file.
#' - Other entities: [GEOSoft-class] object.
#'
#' @details
#'
#' The Gene Expression Omnibus (GEO) from NCBI serves as a public repository
#' for a wide range of high-throughput experimental data. These data include
#' single and dual channel microarray-based experiments measuring mRNA, genomic
#' DNA, and protein abundance, as well as non-array techniques such as serial
#' analysis of gene expression (SAGE), and mass spectrometry proteomic data. At
#' the most basic level of organization of GEO, there are three entity types
#' that may be supplied by users: Platforms, Samples, and Series.
#' Additionally, there is a curated entity called a GEO dataset.
#'
#' A Platform record describes the list of elements on the array (e.g., cDNAs,
#' oligonucleotide probesets, ORFs, antibodies) or the list of elements that
#' may be detected and quantified in that experiment (e.g., SAGE tags,
#' peptides). Each Platform record is assigned a unique and stable GEO
#' accession number (GPLxxx). A Platform may reference many Samples that have
#' been submitted by multiple submitters.
#'
#' A Sample record describes the conditions under which an individual Sample
#' was handled, the manipulations it underwent, and the abundance measurement
#' of each element derived from it. Each Sample record is assigned a unique and
#' stable GEO accession number (GSMxxx). A Sample entity must reference only
#' one Platform and may be included in multiple Series.
#'
#' A Series record defines a set of related Samples considered to be part of a
#' group, how the Samples are related, and if and how they are ordered. A
#' Series provides a focal point and description of the experiment as a whole.
#' Series records may also contain tables describing extracted data, summary
#' conclusions, or analyses. Each Series record is assigned a unique and stable
#' GEO accession number (GSExxx).
#'
#' GEO DataSets (GDSxxx) are curated sets of GEO Sample data. A GDS record
#' represents a collection of biologically and statistically comparable GEO
#' Samples and forms the basis of GEO's suite of data display and analysis
#' tools. Samples within a GDS refer to the same Platform, that is, they share
#' a common set of probe elements. Value measurements for each Sample within a
#' GDS are assumed to be calculated in an equivalent manner, that is,
#' considerations such as background processing and normalization are
#' consistent across the dataset. Information reflecting experimental design is
#' provided through GDS subsets.
#'
#' @references
#' * <https://www.ncbi.nlm.nih.gov/geo/info/download.html>
#' * <https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi>
#' * <https://www.ncbi.nlm.nih.gov/geo/info/soft.html#format>
#' * [Programmatic access to GEO FTP site](https://ftp.ncbi.nlm.nih.gov/geo/README.txt)
#' @examples
#' gse <- geo("GSE10", gse_matrix = FALSE, odir = tempdir())
#' gpl <- geo("gpl98", odir = tempdir())
#' gsm <- geo("GSM1", odir = tempdir())
#' gds <- geo("GDS10", odir = tempdir())
#' if (require("Biobase")) {
#'     gse_matix <- geo("GSE10", odir = tempdir())
#' }
#'
#' @export
geo <- function(ids, amount = NULL, gse_matrix = TRUE, pdata_from_soft = TRUE,
                add_gpl = NULL, ftp_over_https = TRUE,
                handle_opts = list(), odir = getwd()) {
    ids <- check_ids(ids)
    odir <- dir_create(odir, recursive = TRUE)
    geo_type <- substr(ids, 1L, 3L)[1L]
    if (geo_type == "GSE" && gse_matrix) {
        check_bioc_installed("Biobase", "to build ExpressionSet")
        out_list <- get_gse_matrix(
            ids,
            odir = odir,
            pdata_from_soft = pdata_from_soft,
            add_gpl = add_gpl,
            ftp_over_https = ftp_over_https,
            handle_opts = handle_opts
        )
    } else {
        amount <- check_amount(amount)
        out_list <- get_geo_soft(
            ids,
            geo_type = geo_type,
            amount = amount,
            ftp_over_https = ftp_over_https,
            handle_opts = handle_opts,
            odir = odir
        )
    }
    return_object_or_list(out_list, ids)
}
