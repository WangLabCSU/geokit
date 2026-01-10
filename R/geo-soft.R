#' Retrieve GEO SOFT file from NCBI GEO
#'
#' @inheritParams geo_show
#' @param handle_opts A list of named options / headers to be set in the
#'  [`multi_download`][curl::multi_download].
#' @param odir Destination directory for downloads. Defaults to the current
#' working directory.
#' @return A [GEODatatalbe-class] object
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
#' oligonucleotide probesets, ORFs, antibodies) or the list of elements that may
#' be detected and quantified in that experiment (e.g., SAGE tags, peptides).
#' Each Platform record is assigned a unique and stable GEO accession number
#' (GPLxxx). A Platform may reference many Samples/Series that have been
#' submitted by multiple submitters.
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
#' @examples
#' gse <- geo_soft("GSE10", odir = tempdir())
#' gpl <- geo_soft("gpl98", odir = tempdir())
#' gsm <- geo_soft("GSM1", odir = tempdir())
#' gds <- geo_soft("GDS10", odir = tempdir())
#'
#' @export
geo_soft <- function(accession, famount = NULL, scope = NULL,
                     ftp_over_https = NULL,
                     handle_opts = list(), odir = getwd()) {
    odir <- dir_create(odir, recursive = TRUE)
    downloaded <- download_soft(
        accession,
        famount = famount, scope = scope,
        ftp_over_https = ftp_over_https,
        handle_opts = handle_opts,
        odir = odir
    )
    olist <- parse_soft_multiple(.subset2(downloaded, "paths"))
    return_object_or_list(olist, accession)
}

parse_soft_multiple <- function(paths) {
    cli::cli_progress_bar(
        format = "{cli::pb_spin} Parsing {.field {ids[cli::pb_current]}} soft file | {cli::pb_current}/{cli::pb_total}",
        format_done = "Parsing {.val {cli::pb_total}} {.field soft} file{?s} in {cli::pb_elapsed}",
        total = length(paths),
        clear = FALSE
    )
    olist <- vector("list", length(paths))
    for (i in seq_along(paths)) {
        cli::cli_progress_update()
        olist[[i]] <- parse_soft_rust(.subset(paths, i))
    }
    olist
}

#' @importFrom rlang caller_env
download_soft <- function(accession, famount, scope, ftp_over_https,
                          handle_opts, odir = getwd(), call = caller_env()) {
    urls_and_fnames <- rust_call(
        "geo_soft_url_and_fname",
        accession, famount, scope, ftp_over_https
    )
    download_inform(
        .subset2(urls_and_fnames, "urls"),
        file.path(odir, .subset2(urls_and_fnames, "fnames")),
        handle_opts = handle_opts
    )
}
