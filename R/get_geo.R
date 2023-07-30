#' Get a GEO object from GEO FTP site
#'
#' This function is the main user-level function in the `rgeo` package. It
#' implements the downloading and parsing of GEO files.
#'
#' Use `get_geo` functions to download and parse information available from
#' [NCBI GEO](http://www.ncbi.nlm.nih.gov/geo). Here are some details about what
#' is avaible from GEO. All entity types are handled by `get_geo` and
#' essentially any information in the GEO SOFT format is reflected in the
#' resulting data structure.
#'
#' From the GEO website:
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
#' @param ids A character vector representing the GEO entity for downloading and
#'  parsing. All ids must in the same GEO identity (`c("GDS505", "GDS606")` are
#'  all GEO DataSets, `c("GSE2", "GSE22")` are all GEO series eg.).
#' @param dest_dir The destination directory for any downloads. Defaults to
#'  current working dir.
#' @param gse_matrix A logical value indicates whether to retrieve Series Matrix
#'  files when handling a `GSE` GEO entity. When set to `TRUE`, an
#'  [ExpressionSet][Biobase::ExpressionSet] Object will be returned.
#' @param pdata_from_soft A logical value indicates whether derive `phenoData`
#'  from GSE series soft file when parsing
#'  [ExpressionSet][Biobase::ExpressionSet] Object. Defaults to `TRUE`.
#'  Sometimes soft file can be in large size, you can disable the downloading of
#'  soft file by setting pdata_from_soft into `FALSE`. if `FALSE`, `phenoData`
#'  will be parsed directly from GEO series matrix file, which is what
#'  `GEOquery` do, in this way, `characteristics_ch*` column sometimes cannot be
#'  parsed correctly. 
#' @param add_gpl A logical value indicates whether to add **platform** (namely
#'  the [featureData][Biobase::featureData] slot in the
#'  [ExpressionSet][Biobase::ExpressionSet] Object) information when handling a
#'  `GSE` GEO entity with `gse_matrix` option `TRUE`. `add_gpl` is set to `NULL`
#'  by default, which means the internal will try to map the GPL accession ID
#'  into a Bioconductor annotation package firstly, if it succeed, the
#'  [annotation][Biobase::eSet] slot in the returned
#'  [ExpressionSet][Biobase::ExpressionSet] object will be set to the found
#'  Bioconductor annotation package and the `add_gpl` will be set to `FALSE`,
#'  otherwise, `add_gpl` will be set to `TRUE`.
#' @param ftp_over_https A scalar logical value indicates whether to connect GEO
#'  FTP site with https traffic. If `TRUE`, will download FTP files from
#'  <https://ftp.ncbi.nlm.nih.gov/geo>, which is used by GEOquery, otherwise,
#'  will use <ftp://ftp.ncbi.nlm.nih.gov/geo> directly.
#' @param handle_opts A list of named options / headers to be set in the
#'  [handle][curl::new_handle]. 
#' @return An object of the appropriate class (GDS, GPL, GSM, or GSE) is
#'  returned. For `GSE` entity, if `gse_matrix` parameter is `FALSE`, an
#'  [GEOSeries-class] object is returned and if `gse_matrix` parameter is
#'  `TRUE`, a [ExpressionSet][Biobase::ExpressionSet] Object or a list of
#'  [ExpressionSet][Biobase::ExpressionSet] Objects is returned with every
#'  element correspongding to each Series Matrix file associated with the GSE
#'  accesion. And for other GEO entity, a [GEOSoft-class] object is returned.
#' @references
#' * <https://www.ncbi.nlm.nih.gov/geo/info/download.html>
#' * <https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi>
#' * <https://www.ncbi.nlm.nih.gov/geo/info/soft.html#format>
#' * [Programmatic access to GEO FTP site](https://ftp.ncbi.nlm.nih.gov/geo/README.txt)
#' @keywords IO database
#' @rdname get_geo
#' @examples
#' gse_matix <- get_geo("GSE10", tempdir())
#' gse <- get_geo("GSE10", tempdir(), gse_matrix = FALSE)
#' gpl <- get_geo("gpl98", tempdir())
#' gsm <- get_geo("GSM1", tempdir())
#' gds <- get_geo("GDS10", tempdir())
#'
#' @export
get_geo <- function(ids, dest_dir = getwd(), gse_matrix = TRUE, pdata_from_soft = TRUE, add_gpl = NULL, ftp_over_https = TRUE, handle_opts = list(connecttimeout = 60L)) {
    ids <- toupper(ids)
    check_ids(ids)
    if (!dir.exists(dest_dir)) {
        dir.create(dest_dir, recursive = TRUE)
    }
    geo_type <- substring(ids, 1L, 3L)[1L]
    if (geo_type == "GSE" && gse_matrix) {
        out_list <- get_gse_matrix(
            ids,
            dest_dir = dest_dir,
            pdata_from_soft = pdata_from_soft,
            add_gpl = add_gpl,
            ftp_over_https = ftp_over_https,
            handle_opts = handle_opts
        )
    } else {
        out_list <- get_geo_soft(ids,
            geo_type = geo_type, dest_dir = dest_dir,
            ftp_over_https = ftp_over_https,
            handle_opts = handle_opts
        )
    }

    if (length(out_list) == 1L) {
        out_list[[1L]]
    } else {
        names(out_list) <- ids
        out_list
    }
}
