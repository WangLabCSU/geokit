#' Retrieve GEO SOFT file from NCBI GEO
#'
#' @inheritParams geo_show
#' @param handle_opts A list of named options / headers to be set in the
#'  [`multi_download`][curl::multi_download].
#' @param odir Destination directory for downloads. Defaults to the current
#' working directory.
#' @return A [GEOSoft][GEOSoft-class] object
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
                     ftp_over_https = NULL, handle_opts = list(),
                     odir = getwd()) {
    odir <- dir_create(odir, recursive = TRUE)
    olist <- geo_soft_impl(
        accession,
        famount = famount, scope = scope,
        ftp_over_https = ftp_over_https,
        handle_opts = handle_opts,
        odir = odir
    )
    return_object_or_list(olist, accession)
}

geo_soft_impl <- function(accession, famount = NULL, scope = NULL,
                          ftp_over_https = NULL,
                          handle_opts = list(), odir = getwd()) {
    paths <- download_soft(
        accession,
        famount = famount, scope = scope,
        ftp_over_https = ftp_over_https,
        handle_opts = handle_opts,
        odir = odir
    )
    entity_list <- parse_soft_rust(paths)
    lapply(entity_list, parse_entity_list)
}

#' @importFrom rlang caller_env
download_soft <- function(accession, famount, scope, ftp_over_https,
                          handle_opts, odir = getwd(), call = caller_env()) {
    urls_and_fnames <- file_url_and_fname(
        accession, famount, scope, ftp_over_https
    )
    downloaded <- download_inform(
        .subset2(urls_and_fnames, "urls"),
        file.path(odir, .subset2(urls_and_fnames, "fnames")),
        handle_opts = handle_opts
    )
    .subset2(downloaded, "paths")
}

parse_entity_list <- function(entity_list) {
    # Only one entity: For Samples
    if (length(entity_list) == 1L) {
        parse_soft_entity(.subset2(entity_list, 1L))
    } else { # Multiple entities: For DataSets, Series and Platforms
        # The first entity is DATABASE
        rcd_type <- .subset2(.subset2(entity_list, 2L), "rcd_type")
        if (rcd_type == "DATASET") { # For DataSets
            parse_gds_entity(entity_list)
        } else if (rcd_type == "SERIES") { # For Series
            parse_gse_entity(entity_list)
        } else if (rcd_type == "PLATFORM") { # For Platforms
            parse_gpl_entity(entity_list)
        } else {
            cli::cli_abort(c(
                "Undefined behavior: {.field rcd_type} is not one of 'DATASET', 'SERIES' or 'PLATFORM'.",
                i = "Please report this issue."
            ))
        }
    }
}

parse_gpl_entity <- function(list) {
    rcd_types <- vapply(list, function(record) {
        .subset2(record, "rcd_type")
    }, character(1L), USE.NAMES = FALSE)
    platforms <- .subset(list, rcd_types == "PLATFORM")
    if (length(platforms) != 1L) {
        cli::cli_abort("{.field Platforms} should contain only one single platform")
    }
    platform <- .subset2(platforms, 1L)

    gsm <- lapply(
        .subset(list, rcd_types == "SAMPLE"),
        parse_soft_entity
    )
    gse <- lapply(
        .subset(list, rcd_types == "SERIES"),
        parse_soft_entity
    )
    platform$metadata <- merge_metadata(
        .subset(list, !rcd_types %in% c("SAMPLE", "SERIES"))
    )

    # build the object
    platform <- parse_soft_entity(platform, "GEOPlatform")
    gsm(platform) <- gsm
    gse(platform) <- gse
    platform
}

parse_gse_entity <- function(list) {
    rcd_types <- vapply(list, function(record) {
        .subset2(record, "rcd_type")
    }, character(1L), USE.NAMES = FALSE)

    series_list <- .subset(list, rcd_types == "SERIES")
    if (length(series_list) != 1L) {
        cli::cli_abort("{.field Series} should contain only one single series")
    }
    series <- .subset2(series_list, 1L)

    gsm <- lapply(
        .subset(list, rcd_types == "SAMPLE"),
        parse_soft_entity
    )
    gpl <- lapply(
        .subset(list, rcd_types == "PLATFORM"),
        parse_soft_entity
    )
    series$metadata <- merge_metadata(
        .subset(list, !rcd_types %in% c("SAMPLE", "PLATFORM"))
    )
    # build the object
    series <- parse_soft_entity(series, "GEOSeries")
    gsm(series) <- gsm
    gpl(series) <- gpl
    series
}

parse_gds_entity <- function(list) {
    ensure_only_metadata(list, "DATASET")
    datasets <- .subset(list, vapply(list, function(data) {
        .subset2(data, "rcd_type") == "DATASET"
    }, logical(1L), USE.NAMES = FALSE))
    datasets_groups <- vapply(datasets, function(subset) {
        .subset2(subset, "rcd_name")
    }, character(1L), USE.NAMES = FALSE)
    datasets_groups <- factor(datasets_groups, unique(datasets_groups))
    if (!is_all_same(datasets_groups)) {
        cli::cli_abort("{.field Datasets} should contain only one single dataset")
    }
    # the same dataset will be distributed into multiple entities
    # But they should contain only one column, header and datatable data.
    dataset <- .subset2(datasets, 1L)
    for (other in .subset(datasets, -1L)) {
        if (length(.subset2(dataset, "columns")) &&
            length(.subset2(other, "columns"))) {
            cli::cli_abort("Datasets should contain only one columns data.")
        }
        dataset$columns <- c(
            .subset2(dataset, "columns"),
            .subset2(other, "columns")
        )
        if (length(.subset2(dataset, "header")) &&
            length(.subset2(other, "header"))) {
            cli::cli_abort("Datasets should contain only one one header.")
        }
        dataset$header <- c(
            .subset2(dataset, "header"),
            .subset2(other, "header")
        )
        if (length(.subset2(dataset, "datatable")) &&
            length(.subset2(other, "datatable"))) {
            cli::cli_abort("Datasets should contain only one data table.")
        }
        if (length(.subset2(other, "datatable"))) {
            dataset$datatable <- .subset2(other, "datatable")
        }
    }
    dataset$metadata <- merge_metadata(list)

    # build the object
    parse_soft_entity(dataset)
}

ensure_only_metadata <- function(list, filter = NULL) {
    for (record in list) {
        if (!is.null(filter) && .subset2(record, "rcd_type") == filter) {
            next
        }
        if (length(.subset2(record, "datatable")) ||
            length(.subset2(record, "columns"))) {
            msg <- sprintf(
                "Undefined behavior: {.field %s} should not contain {.field columns} or {.field datatable}.",
                .subset2(record, "rcd_type")
            )
            if (!is.null(filter)) {
                msg <- paste(msg, sprintf("Only {.field %s} can have these fields.", filter))
            }
            msg <- c(msg, i = "Please report this issue.")
            cli::cli_abort(msg)
        }
    }
}

parse_soft_entity <- function(list, class = NULL) {
    rcd_name <- .subset2(list, "rcd_name")
    rcd_type <- .subset2(list, "rcd_type")
    metadata <- .subset2(list, "metadata")

    # Special concerns for Series matrix
    if (!is.null(metadata$Series_geo_accession)) {
        rcd_type <- rcd_type %||% "Series_Matrix"
        rcd_name <- rcd_name %||% metadata$Series_geo_accession
    }
    columns <- .subset2(list, "columns")
    datatable <- .subset2(list, "datatable")
    if (length(header <- .subset2(list, "header"))) {
        if (length(datatable) == 0L) {
            datatable <- vector("list", length(header))
        }
        names(datatable) <- header
    }
    methods::new(
        class %||% "GEOSoft",
        rcd_type = rcd_type,
        rcd_name = rcd_name,
        metadata = metadata,
        columns = quickdf(list(labelDescription = columns), names(columns)),
        datatable = quickdf(datatable),
        accession = rcd_name
    )
}

merge_metadata <- function(list) {
    # merge metadata
    metadata <- lapply(list, function(record) .subset2(record, "metadata"))
    metadata_groups <- vapply(
        list,
        function(record) .subset2(record, "rcd_type"),
        character(1L),
        USE.NAMES = FALSE
    )
    metadata_groups <- factor(metadata_groups, unique(metadata_groups))
    lapply(split(seq_along(metadata), metadata_groups), function(groups_index) {
        metadata_group <- .subset(metadata, groups_index)
        metadata_group <- .subset(metadata_group, lengths(metadata_group) > 0L)
        if (length(metadata_group) == 1L) {
            .subset2(metadata_group, 1L)
        } else {
            # for multiple metadatas, we add names to it
            names(metadata_group) <- vapply(
                seq_along(groups_index), function(i) {
                    record <- .subset2(list, .subset(groups_index, i))
                    .subset2(record, "rcd_name") %||%
                        paste(
                            .subset2(record, "rcd_type"),
                            i,
                            sep = "_"
                        )
                },
                character(1L),
                USE.NAMES = FALSE
            )
            metadata_group
        }
    })
}

quickdf <- function(l, rownames = NULL) {
    class(l) <- "data.frame"
    if (is.null(rownames)) {
        if (length(l) > 0L) {
            attr(l, "row.names") <- .set_row_names(length(.subset2(l, 1L)))
        } else {
            attr(l, "row.names") <- .set_row_names(0L)
        }
    } else {
        attr(l, "row.names") <- rownames
    }
    l
}
