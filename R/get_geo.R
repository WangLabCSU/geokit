#' Get a GEO object from GEO FTP site
#'
#' This function is the main user-level function in the `rgeo` package.  It
#' directs the downloading and parsing of GEO files into an R data
#' structure.
#'
#' get_geo functions to download and parse information available from [NCBI
#' GEO](http://www.ncbi.nlm.nih.gov/geo). Here are some details about what
#' is avaible from GEO.  All entity types are handled by get_geo and essentially
#' any information in the GEO SOFT format is reflected in the resulting data
#' structure.
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
#' @param ids A character vector representing the GEO identity for downloading
#' and parsing. ('GDS505','GSE2','GSM2','GPL96' eg.). Currently, `rgeo` only
#' support GSE identity.
#' @param dest_dir The destination directory for any downloads.  Defaults to
#' current working dir.
#' @param add_gpl A logical value indicates whether to add **platform**
#' information (namely the [featureData][Biobase::featureData] slot in
#' [ExpressionSet][Biobase::ExpressionSet] Object) when fetching a `GSE` GEO
#' identity with `gse_matrix` option `TRUE`.
#' @return An object of the appropriate class (GDS, GPL, GSM, or GSE) is
#' returned. If the gse_matrix (`TRUE`) option is used with a `GSE` GEO
#' identity, then a [ExpressionSet][Biobase::ExpressionSet] Object or a list of
#' [ExpressionSet][Biobase::ExpressionSet] Objects is
#' returned, one for each SeriesMatrix file associated with the GSE accesion.
#' @section Warning : Some of the files that are downloaded, particularly those
#' associated with GSE entries from GEO are absolutely ENORMOUS and parsing
#' them can take quite some time and memory.  So, particularly when working
#' with large GSE entries, expect that you may need a good chunk of memory and
#' that coffee may be involved when parsing....
#' @references
#' * <https://www.ncbi.nlm.nih.gov/geo/info/download.html>
#' * <https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi>
#' * [Programmatic access to GEO FTP site](https://ftp.ncbi.nlm.nih.gov/geo/README.txt)
#' @keywords IO database
#' @rdname get_geo
#' @examples
#' gse <- get_geo("GSE10", tempdir())
#'
#' @export
get_geo <- function(ids, dest_dir = getwd(), add_gpl = TRUE) {
    ids <- toupper(ids)
    check_ids(ids)
    get_geo_multi(
        ids = ids, dest_dir = dest_dir,
        gse_matrix = TRUE,
        add_gpl = add_gpl
    )
}

#' @param gse_matrix A logical value indicates whether to retrieve Series Matrix
#' files when fetching a `GSE` GEO identity. When set to `TRUE`, a
#' [ExpressionSet][Biobase::ExpressionSet] Object will be returned
#' @noRd 
get_geo_multi <- function(ids, dest_dir = getwd(), gse_matrix = TRUE, add_gpl = TRUE) {
    res <- lapply(ids, function(id) {
        rlang::try_fetch(
            get_geo_switch(
                id,
                dest_dir = dest_dir,
                gse_matrix = gse_matrix,
                add_gpl = add_gpl
            ),
            error = function(err) {
                rlang::abort(
                    paste0("Error when fetching GEO data of ", id, "."),
                    parent = err
                )
            }
        )
    })
    if (identical(length(res), 1L)) {
        res[[1L]]
    } else {
        names(res) <- ids
        res
    }
}

get_geo_switch <- function(id, dest_dir = getwd(), gse_matrix = TRUE, add_gpl = TRUE) {
    switch(unique(substr(id, 1L, 3L)),
        GSE = if (gse_matrix) {
            get_gse_matrix(id, dest_dir = dest_dir, add_gpl = add_gpl)
        } else {
            "series"
        },
        GPL = get_gpl(id, dest_dir = dest_dir),
        GSM = "samples",
        GDS = "datasets"
    )
}

get_gse_matrix <- function(id, dest_dir = getwd(), add_gpl = TRUE) {
    file_paths <- download_geo_suppl_or_gse_matrix_files(
        id = id, dest_dir = dest_dir,
        file_type = "matrix"
    )
    res <- lapply(file_paths, function(file) {
        gse_matrix_data <- parse_gse_matrix(read_lines(file))
        rlang::exec(
            "construct_gse_matrix_expressionset",
            !!!gse_matrix_data,
            add_gpl = add_gpl,
            dest_dir = dest_dir
        )
    })
    if (identical(length(res), 1L)) {
        res[[1L]]
    } else {
        names(res) <- basename(file_paths)
        res
    }
}

construct_gse_matrix_expressionset <- function(matrix_data, pheno_data, experiment_data, gpl_id, add_gpl, dest_dir) {
    construct_param_list <- list(
        assayData = matrix_data,
        phenoData = pheno_data,
        experimentData = experiment_data,
        annotation = gpl_id
    )
    if (add_gpl) {
        gpl_file_path <- download_gpl_file(gpl_id, dest_dir)
        gpl_file_text <- read_lines(gpl_file_path)
        gpl_data <- parse_gpl(gpl_file_text)
        if (!is.null(gpl_data$data_table)) {
            # NCBI GEO uses case-insensitive matching between platform
            # IDs and series ID Refs
            feature_data <- gpl_data$data_table[
                match(
                    tolower(rownames(matrix_data)),
                    tolower(rownames(gpl_data$data_table))
                ), ,
                drop = FALSE
            ]
            rownames(feature_data) <- rownames(matrix_data)
            feature_data <- Biobase::AnnotatedDataFrame(
                feature_data,
                varMetadata = data.frame(
                    labelDescription = unname(
                        gpl_data$column[colnames(feature_data)]
                    ),
                    row.names = colnames(feature_data)
                )
            )
        } else {
            feature_data <- Biobase::AnnotatedDataFrame(
                data.frame(row.names = rownames(matrix_data))
            )
        }
        construct_param_list <- c(
            construct_param_list,
            featureData = feature_data
        )
    }
    expr <- rlang::call2(
        "ExpressionSet",
        !!!construct_param_list,
        .ns = "Biobase"
    )
    rlang::eval_bare(expr)
}

get_gpl <- function(id, dest_dir = getwd()) {
    file_path <- download_gpl_file(id, dest_dir)
    file_text <- read_lines(file_path)
    gpl_data <- parse_gpl(file_text)
    if (!is.null(gpl_data$data_table)) {
        Biobase::AnnotatedDataFrame(
            gpl_data$data_table,
            varMetadata = data.frame(
                labelDescription = unname(
                    gpl_data$column[colnames(gpl_data$data_table)]
                ),
                row.names = colnames(gpl_data$data_table)
            )
        )
    } else {
        NULL
    }
}
