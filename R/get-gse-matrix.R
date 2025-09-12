get_gse_matrix <- function(ids, odir = getwd(), pdata_from_soft = TRUE,
                           add_gpl = NULL, ftp_over_https = FALSE,
                           handle_opts = list()) {
    file_paths_list <- download_suppl_or_gse_matrix_files(
        ids = ids,
        odir = odir,
        file_type = "matrix",
        ftp_over_https = ftp_over_https,
        handle_opts = handle_opts
    )
    arg_list <- list(id = ids, file_paths = file_paths_list)
    if (pdata_from_soft) {
        gse_soft_file_paths <- download_gse_soft_files(
            ids,
            odir = odir,
            ftp_over_https = ftp_over_https,
            handle_opts = handle_opts
        )
        gse_sample_data_list <- lapply(gse_soft_file_paths, function(x) {
            cli::cli_alert("Parsing series {.field soft} file {.file {basename(x)}}")
            parse_gse_soft(read_lines(x), entity_type = "sample")[["gsm"]]
        })
        cli::cli_alert_success(
            "Parsing {.val {length(gse_soft_file_paths)}} series {.field soft} file{?s} successfully!"
        )
        arg_list <- c(arg_list, list(gse_sample_data = gse_sample_data_list))
    }

    # parsing GSE metrix files --------------------------------------
    # pass id in order to update message
    es_elements_list <- .mapply(function(id, file_paths, ...) {
        cli::cli_alert(
            "Parsing {.val {length(file_paths)}} series {.field matrix} file{?s} of {.field {id}}"
        )
        # For GEO series soft files, there is only one file corresponding to
        # all GSE matrix fiels, so we should extract the sample data
        # firstly, and then split it into pieces.
        # For each GSE matrix file, we extract the `ExpressionSet` elements
        names(file_paths) <- basename(file_paths)
        lapply(file_paths, function(file_path) {
            parse_gse_matrix(file_text = read_lines(file_path), ...)
        })
    }, arg_list, NULL)
    cli::cli_alert_success("Parsing {.val {length(ids)}} {.strong GSE} series matrix successfully!")

    # adding featureData and contructing ExpressionSet object
    cli::cli_alert("Constructing {.cls ExpressionSet}")
    lapply(es_elements_list, function(es_elements) {
        es_list <- lapply(es_elements, function(es_element) {
            if (is.null(add_gpl) || !add_gpl) {
                bioc_pkg <- gpl2bioc_pkg(es_element$annotation)
                if (!is.na(bioc_pkg)) {
                    es_element$annotation <- bioc_pkg
                } else if (is.null(add_gpl)) {
                    add_gpl <- TRUE
                }
            }
            if (isTRUE(add_gpl)) {
                es_element <- c(
                    es_element, list(
                        featureData = download_and_parse_annotation(
                            annotation = es_element$annotation,
                            assay = es_element$assayData,
                            odir = odir,
                            ftp_over_https = ftp_over_https,
                            handle_opts = handle_opts
                        )
                    )
                )
            }
            rlang::inject(Biobase::ExpressionSet(!!!es_element))
        })
        return_object_or_list(es_list)
    })
}

download_and_parse_annotation <- function(annotation, assay, odir,
                                          ftp_over_https, handle_opts) {
    gpl_file_path <- download_gpl_files(
        annotation,
        amount = "data",
        handle_opts = handle_opts,
        ftp_over_https = ftp_over_https,
        odir = odir
    )
    gpl_data <- parse_gpl_or_gsm_soft(read_lines(gpl_file_path))
    if (nrow(gpl_data$data_table)) {
        feature_data <- set_rownames(gpl_data$data_table)
        # NCBI GEO uses case-insensitive matching between platform
        # IDs and series ID Refs
        feature_data <- feature_data[
            data.table::chmatch(
                tolower(rownames(assay)),
                tolower(rownames(feature_data))
            ), ,
            drop = FALSE
        ]
        rownames(feature_data) <- rownames(assay)
        Biobase::AnnotatedDataFrame(feature_data,
            varMetadata = column_to_rownames(gpl_data$columns)
        )
    } else {
        Biobase::AnnotatedDataFrame(
            data.frame(row.names = rownames(assay)),
            varMetadata = column_to_rownames(gpl_data$columns)
        )
    }
}
