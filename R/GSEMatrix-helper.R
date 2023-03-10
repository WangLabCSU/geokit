get_gse_matrix <- function(ids, dest_dir = getwd(), pdata_from_soft = TRUE, add_gpl = NULL, handle_opts = list()) {
    file_paths_list <- download_geo_suppl_or_gse_matrix_files(
        ids = ids, dest_dir = dest_dir,
        file_type = "matrix",
        handle_opts = handle_opts
    )
    arg_list <- list(id = ids, file_paths = file_paths_list)
    if (pdata_from_soft) {
        cli::cli_inform("Downloading {.val {length(ids)}} series soft file{?s}")
        gse_soft_file_paths <- download_gse_soft_files(
            ids, dest_dir,
            handle_opts = handle_opts
        )
        cli::cli_inform("Parsing {.val {length(ids)}} series soft file{?s}")
        gse_sample_data_list <- lapply(gse_soft_file_paths, function(x) {
            gse_soft_file_text <- read_lines(x)
            suppressMessages(parse_gse_soft(
                gse_soft_file_text,
                entity_type = "sample"
            )[["gsm"]])
        })
        arg_list <- c(arg_list, list(gse_sample_data = gse_sample_data_list))
    }
    bar_id <- cli::cli_progress_bar(
        format = "{cli::pb_spin} Parsing {.field {ids[cli::pb_current]}} | {cli::pb_current}/{cli::pb_total}",
        format_done = "Total parsing time: {cli::pb_elapsed_clock}",
        clear = FALSE,
        total = length(ids)
    )
    .mapply(
        function(id, file_paths, gse_sample_data = NULL) {
            cli::cli_progress_update(id = bar_id)
            # For GEO series soft files, there is only one file corresponding to
            # all GSE matrix fiels, so we should extract the sample data
            # firstly, and then split it into pieces.

            # For each GSE matrix file, we construct a `ExpressionSet` object
            out_list <- lapply(file_paths, function(file) {
                construct_gse_matrix_expressionset(
                    file_text = read_lines(file),
                    pdata_from_soft = pdata_from_soft,
                    gse_sample_data = gse_sample_data,
                    add_gpl = add_gpl,
                    dest_dir = dest_dir,
                    handle_opts = handle_opts
                )
            })
            if (length(out_list) == 1L) {
                out_list[[1L]]
            } else {
                names(out_list) <- basename(file_paths)
                out_list
            }
        }, arg_list, NULL
    )
}

construct_gse_matrix_expressionset <- function(file_text, pdata_from_soft, gse_sample_data, add_gpl, dest_dir, handle_opts) {
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
            cli::cli_alert_info("Found Bioconductor annotation package for {.val {expressionset_elements$annotation}}")
            add_gpl <- FALSE
        } else {
            cli::cli_alert_info("Cannot map {.val {expressionset_elements$annotation}} to a Bioconductor annotation package")
            add_gpl <- TRUE
        }
    }

    if (!add_gpl) {
        expressionset_elements$annotation <- gpl2bioc(
            expressionset_elements$annotation
        )
    } else {
        gpl_file_path <- download_gpl_files(
            expressionset_elements$annotation,
            dest_dir,
            amount = "data",
            handle_opts = handle_opts
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
            list(featureData = feature_data)
        )
    }
    do.call(Biobase::ExpressionSet, expressionset_elements)
}
