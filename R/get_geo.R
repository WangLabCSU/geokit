#' Get a GEO object from GEO FTP site
#'
#' This function is the main user-level function in the `rgeo` package.  It
#' directs the downloading and parsing of GEO files into an R data
#' structure.
#'
#' Use `get_geo` functions to download and parse information available from
#' [NCBI GEO](http://www.ncbi.nlm.nih.gov/geo). Here are some details about what
#' is avaible from GEO.  All entity types are handled by `get_geo` and
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
#' @param ids A character vector representing the GEO entity for downloading
#' and parsing. ('GDS505','GSE2','GSM2','GPL96' eg.).
#' @param dest_dir The destination directory for any downloads. Defaults to
#' current working dir.
#' @param gse_matrix A logical value indicates whether to retrieve Series Matrix
#' files when fetching a `GSE` GEO identity. When set to `TRUE`, an
#' [ExpressionSet][Biobase::ExpressionSet] Object will be returned
#' @param pdata_from_soft A logical value indicates whether derive `phenoData`
#' from GSE series soft file when parsing
#' [ExpressionSet][Biobase::ExpressionSet] Object. Defaults to `TRUE`, if
#' `FALSE`, `phenoData` will be parsed directly from GEO series matrix file,
#' which is what `GEOquery` do, in this way, `characteristics_ch*` column
#' sometimes cannot be parsed correctly.
#' @param add_gpl A logical value indicates whether to add **platform**
#' information (namely the [featureData][Biobase::featureData] slot in
#' [ExpressionSet][Biobase::ExpressionSet] Object) when fetching a `GSE` GEO
#' entity with `gse_matrix` option `TRUE`. Default is `NULL`, which means the
#' internal will try to map the GPL accession ID into a Bioconductor annotation
#' package firstly, if it succeed, the [annotation][Biobase::eSet] slot in the
#' returned [ExpressionSet][Biobase::ExpressionSet] object will be set to the
#' found Bioconductor annotation package and the `add_gpl` will be set to
#' `FALSE`, otherwise, to `TRUE`.
#' @return An object of the appropriate class (GDS, GPL, GSM, or GSE) is
#' returned. For `GSE` entity, if `gse_matrix` parameter is `FALSE`, an
#' [GEOSeries-class] object is returned and if `gse_matrix` parameter is `TRUE`,
#' a ExpressionSet][Biobase::ExpressionSet] Object or a list of
#' [ExpressionSet][Biobase::ExpressionSet] Objects is returned with one element
#' for each Series Matrix file associated with the GSE accesion. And for other
#' GEO entity, a [GEOSoft-class] object is returned.
#' @section Warning : Some of the files that are downloaded, particularly those
#' associated with GSE entries from GEO are absolutely ENORMOUS and parsing
#' them can take quite some time and memory. So, particularly when working
#' with large GSE entries, expect that you may need a good chunk of memory and
#' that coffee may be involved when parsing....
#' @references
#' * <https://www.ncbi.nlm.nih.gov/geo/info/download.html>
#' * <https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi>
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
get_geo <- function(ids, dest_dir = getwd(), gse_matrix = TRUE, pdata_from_soft = TRUE, add_gpl = NULL) {
    ids <- toupper(ids)
    check_ids(ids)
    if (!dir.exists(dest_dir)) {
        dir.create(dest_dir, recursive = TRUE)
    }
    get_geo_multi(
        ids = ids, dest_dir = dest_dir,
        gse_matrix = gse_matrix,
        pdata_from_soft = pdata_from_soft,
        add_gpl = add_gpl
    )
}

#' @noRd
get_geo_multi <- function(ids, dest_dir = getwd(), gse_matrix = TRUE, pdata_from_soft = TRUE, add_gpl = NULL) {
    res <- lapply(ids, function(id) {
        rlang::try_fetch(
            get_geo_unit(
                id,
                dest_dir = dest_dir,
                gse_matrix = gse_matrix,
                pdata_from_soft = pdata_from_soft,
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

get_geo_unit <- function(id, dest_dir = getwd(), gse_matrix = TRUE, pdata_from_soft = TRUE, add_gpl = NULL) {
    geo_type <- substr(id, 1L, 3L)
    if (identical(geo_type, "GSE") && gse_matrix) {
        get_gse_matrix(
            id,
            dest_dir = dest_dir,
            pdata_from_soft = pdata_from_soft,
            add_gpl = add_gpl
        )
    } else {
        get_geo_soft(id, geo_type = geo_type, dest_dir = dest_dir)
    }
}

get_gse_matrix <- function(id, dest_dir = getwd(), pdata_from_soft = TRUE, add_gpl = NULL) {
    file_paths <- download_geo_suppl_or_gse_matrix_files(
        id = id, dest_dir = dest_dir,
        file_type = "matrix"
    )
    # For GEO series soft files, there is only one file corresponding to all
    # GSE matrix fiels, so we should extract the sample data firstly, and then
    # split it into pieces.
    if (pdata_from_soft) {
        gse_soft_file_path <- download_gse_soft_file(id, dest_dir)
        gse_soft_file_text <- read_lines(gse_soft_file_path)
        gse_sample_data <- suppressMessages(
            parse_gse_soft(
                gse_soft_file_text,
                entity_type = "sample"
            )[["gsm"]]
        )
    }
    # For each GSE matrix file, we construct a `ExpressionSet` object
    res <- lapply(file_paths, function(file) {
        construct_gse_matrix_expressionset(
            file_text = read_lines(file),
            pdata_from_soft = pdata_from_soft,
            gse_sample_data = gse_sample_data,
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

construct_gse_matrix_expressionset <- function(file_text, pdata_from_soft, gse_sample_data, add_gpl, dest_dir) {
    expressionset_elements <- parse_gse_matrix(
        file_text = file_text,
        pdata_from_soft = pdata_from_soft
    )
    if (pdata_from_soft) {
        gse_sample_data <- parse_gse_soft_sample_characteristics(
            gse_sample_data[colnames(expressionset_elements$assayData)]
        )
        data.table::setDF(
            gse_sample_data,
            rownames = gse_sample_data[["geo_accession"]]
        )
        expressionset_elements$phenoData <- Biobase::AnnotatedDataFrame(
            data = gse_sample_data[
                colnames(expressionset_elements$assayData), ,
                drop = FALSE
            ]
        )
    }

    if (is.null(add_gpl)) {
        if (has_bioc_annotation_pkg(expressionset_elements$annotation)) {
            rlang::inform(
                c(
                    paste0(
                        "Found Bioconductor annotation package for ",
                        expressionset_elements$annotation
                    ),
                    "Setting `add_gpl` to `FALSE`",
                    "You can overwrite this behaviour by setting `add_gpl` to `TRUE` manually."
                )
            )
            expressionset_elements$annotation <- gpl2bioc(
                expressionset_elements$annotation
            )
            add_gpl <- FALSE
        } else {
            rlang::inform(
                c(
                    paste0(
                        "Cannot map ", expressionset_elements$annotation,
                        " to a Bioconductor annotation package"
                    ),
                    "Setting `add_gpl` to `TRUE`"
                )
            )
            add_gpl <- TRUE
        }
    }

    if (add_gpl) {
        gpl_file_path <- download_gpl_file(
            expressionset_elements$annotation,
            dest_dir,
            amount = "data"
        )
        gpl_file_text <- read_lines(gpl_file_path)
        gpl_data <- parse_gpl_or_gsm_soft(gpl_file_text)
        if (!is.null(gpl_data$data_table)) {
            # NCBI GEO uses case-insensitive matching between platform
            # IDs and series ID Refs
            feature_data <- gpl_data$data_table[
                match(
                    tolower(rownames(expressionset_elements$assayData)),
                    tolower(rownames(gpl_data$data_table))
                ), ,
                drop = FALSE
            ]
            rownames(feature_data) <- rownames(expressionset_elements$assayData)
            feature_data <- Biobase::AnnotatedDataFrame(
                feature_data,
                varMetadata = gpl_data$columns
            )
        } else {
            feature_data <- Biobase::AnnotatedDataFrame(
                data.frame(
                    row.names = rownames(expressionset_elements$assayData)
                )
            )
        }
        expressionset_elements <- c(
            expressionset_elements,
            featureData = feature_data
        )
    }
    rlang::exec(Biobase::ExpressionSet, !!!expressionset_elements)
}

# For GPL, GSM, and GDS entity, return a `GEOSoft` object
# For GSE entity, return a `GEOSeries` object
get_geo_soft <- function(id, geo_type, dest_dir = getwd()) {
    file_path <- switch(geo_type,
        GSM = download_gsm_file(id, dest_dir = dest_dir),
        GPL = download_gpl_file(
            id,
            dest_dir = dest_dir, amount = "full"
        ),
        GSE = download_gse_soft_file(id, dest_dir = dest_dir),
        GDS = download_gds_file(id, dest_dir = dest_dir)
    )
    file_text <- read_lines(file_path)
    soft_data <- switch(geo_type,
        GSM = ,
        GPL = parse_gpl_or_gsm_soft(file_text),
        GSE = parse_gse_soft(file_text, entity_type = "all"),
        GDS = parse_gds_soft(file_text)
    )
    switch(geo_type,
        GSM = ,
        GPL = ,
        GDS = methods::new(
            "GEOSoft",
            meta = soft_data$meta,
            columns = soft_data$columns,
            datatable = soft_data$data_table,
            accession = id
        ),
        GSE = methods::new(
            "GEOSeries",
            meta = soft_data$meta,
            gsm = soft_data$gsm,
            gpl = soft_data$gpl,
            accession = id
        )
    )
}
