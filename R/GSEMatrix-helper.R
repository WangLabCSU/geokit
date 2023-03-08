get_gse_matrix <- function(id, dest_dir = getwd(), pdata_from_soft = TRUE, add_gpl = NULL, curl_handle = NULL) {
    file_paths <- download_geo_suppl_or_gse_matrix_files(
        id = id, dest_dir = dest_dir,
        file_type = "matrix"
    )
    # For GEO series soft files, there is only one file corresponding to all
    # GSE matrix fiels, so we should extract the sample data firstly, and then
    # split it into pieces.
    if (pdata_from_soft) {
        gse_soft_file_path <- download_gse_soft_file(id, dest_dir,
            curl_handle = curl_handle
        )
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
            dest_dir = dest_dir,
            curl_handle = curl_handle
        )
    })
    if (length(res) == 1L) {
        res[[1L]]
    } else {
        names(res) <- basename(file_paths)
        res
    }
}

construct_gse_matrix_expressionset <- function(file_text, pdata_from_soft, gse_sample_data, add_gpl, dest_dir, curl_handle) {
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

    if (!add_gpl) {
        expressionset_elements$annotation <- gpl2bioc(
            expressionset_elements$annotation
        )
    } else {
        gpl_file_path <- download_gpl_file(
            expressionset_elements$annotation,
            dest_dir,
            amount = "data",
            curl_handle = curl_handle
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
