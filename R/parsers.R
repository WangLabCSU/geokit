parse_soft_rust <- function(path, reuse_buffer = TRUE) {
    entity_list <- rust_call("geo_parse_soft", path, reuse_buffer)
    # Only one entity: For Samples
    if (length(entity_list) == 1L) {
        parse_soft_datatable(.subset2(entity_list, 1L))
    } else { # Multiple entities: For DataSets and Series
        # The first entity is DATABASE
        rcd_type <- .subset2(.subset2(entity_list, 2L), "rcd_type")
        if (rcd_type == "DATASET") { # For DataSets
            parse_gds_soft_rust(entity_list)
        } else if (rcd_type == "SERIES") { # For Series
            parse_gse_soft_rust(entity_list)
        } else if (rcd_type == "PLATFORM") { # For Platforms
            parse_gpl_soft_rust(entity_list)
        } else {
            cli::cli_abort(c(
                "Undefined behavior: {.field rcd_type} is not one of 'DATASET', 'SERIES' or 'PLATFORM'.",
                i = "Please report this issue."
            ))
        }
    }
}

parse_gpl_soft_rust <- function(list) {
    rcd_types <- vapply(list, function(record) {
        .subset2(record, "rcd_type")
    }, character(1L), USE.NAMES = FALSE)
    gsm <- lapply(
        .subset(list, rcd_types == "SAMPLE"),
        parse_soft_datatable
    )
    gse <- lapply(
        .subset(list, rcd_types == "SERIES"),
        parse_soft_datatable
    )
    metadata <- merge_metadata(
        .subset(list, !rcd_types %in% c("SAMPLE", "SERIES"))
    )

    # the same dataset will be distributed into multiple entities
    # But they should contain only one column, header and datatable data.
    platforms <- .subset(list, vapply(list, function(data) {
        .subset2(data, "rcd_type") == "PLATFORM"
    }, logical(1L), USE.NAMES = FALSE))
    if (length(platforms) != 1L) {
        cli::cli_abort("{.field Platforms} should contain only one single platform")
    }
    platform <- .subset2(platforms, 1L)
    platform$metadata <- metadata

    # build the object
    platform <- parse_soft_datatable(platform, "GEOPlatform")
    gsm(platform) <- gsm
    gse(platform) <- gse
    platform
}

parse_gse_soft_rust <- function(list) {
    rcd_types <- vapply(list, function(record) {
        .subset2(record, "rcd_type")
    }, character(1L), USE.NAMES = FALSE)

    series_list <- .subset(list, rcd_types == "SERIES")
    if (length(series_list) != 1L) {
        cli::cli_abort("{.field Series} should contain only one single series")
    }
    ensure_only_metadata(series_list)
    series <- .subset2(series_list, 1L)

    gsm <- lapply(
        .subset(list, rcd_types == "SAMPLE"),
        parse_soft_datatable
    )
    gpl <- lapply(
        .subset(list, rcd_types == "PLATFORM"),
        parse_soft_datatable
    )
    metadata <- merge_metadata(
        .subset(list, !rcd_types %in% c("SAMPLE", "PLATFORM"))
    )

    rcd_name <- .subset2(series, "rcd_name")
    methods::new(
        "GEOSeries",
        rcd_type = .subset2(series, "rcd_type"),
        rcd_name = rcd_name,
        metadata = metadata,
        gsm = gsm,
        gpl = gpl,
        accession = rcd_name
    )
}

parse_gds_soft_rust <- function(list) {
    ensure_only_metadata(list, "DATASET")
    # the same dataset will be distributed into multiple entities
    # But they should contain only one column, header and datatable data.
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
    parse_soft_datatable(dataset)
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

parse_soft_datatable <- function(list, class = NULL) {
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
        class %||% "GEODatatable",
        rcd_type = rcd_type,
        rcd_name = rcd_name,
        metadata = metadata,
        columns = quickdf(list(labelDescription = columns), names(columns)),
        datatable = quickdf(datatable),
        accession = rcd_name
    )
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
