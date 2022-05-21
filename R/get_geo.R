get_geo_gse <- function(ids, dest_dir = getwd()) {
    file_path_list <- download_geo_suppl_files_or_gse_matrix(
        ids = ids, dest_dir = dest_dir,
        file_type = "matrix"
    )
    res <- lapply(file_path_list, function(file_paths) {
        lapply(file_paths, parse_geo_gse)
    })
    if (identical(length(res), 1L)) res[[1]] else res
}

parse_geo_gse <- function(file) {
    file_text <- read_lines(file)

    # extract series matrix data
    .matrix_data <- data.table::fread(
        text = file_text[!grepl("^!", file_text, fixed = FALSE)],
        sep = "\t", header = TRUE, blank.lines.skip = TRUE,
        na.strings = c("NA", "null", "NULL", "Null")
    )
    data.table::setDF(.matrix_data)
    .matrix_data <- as.matrix(column_to_rownames(.matrix_data, 1))

    # extract series and sample meta data
    meta_data <- extract_geo_gse_meta_data(file_text)

    # fetch GPL data
    gpl_id <- unique(meta_data$Sample[[grep(
        "platform_id", colnames(meta_data$Sample),
        ignore.case = TRUE, value = TRUE
    )]])
    gpl_data <- get_geo_gpl(gpl_id)[[1]]

    Biobase::ExpressionSet(
        assayData = .matrix_data,
        phenoData = Biobase::AnnotatedDataFrame(
            data = meta_data$Sample[colnames(.matrix_data), , drop = FALSE]
        ),
        featureData = gpl_data$fdata[
            rownames(.matrix_data), ,
            drop = FALSE
        ],
        experimentData = Biobase::MIAME(
            other = c(meta_data$Series, gpl_data$gpl_meta)
        ),
        annotation = gpl_id
    )
}

get_geo_gpl <- function(ids, dest_dir = getwd()) {
    lapply(ids, function(id) {
        file_path <- tryCatch(
            download_geo_files(
                ids = id, dest_dir = dest_dir,
                file_type = "annot"
            ),
            error = function(error) {
                rlang::inform(
                    "Annotation for ", id, " is not available, so will use GPL SOFT file instead."
                )
                download_geo_files(
                    ids = id, dest_dir = dest_dir,
                    file_type = "soft"
                )
            }
        )
        parse_geo_gpl(file_path)
    })
}

parse_geo_gpl <- function(file) {
    file_text <- read_lines(file)

    # extract feature data
    .fdata <- data.table::fread(
        text = file_text[!grepl("^[!#]", file_text, fixed = FALSE)],
        sep = "\t", header = TRUE, blank.lines.skip = TRUE,
        na.strings = c("NA", "null", "NULL", "Null")
    )
    data.table::setDF(.fdata)
    rownames(.fdata) <- .fdata[["ID"]]

    # extract meta data and column data
    .column_data <- extract_geo_meta_and_column_data(
        file_text = file_text, pattern = "^#\\w*?",
        sub_pattern = "#"
    )
    .meta_data <- extract_geo_meta_and_column_data(
        file_text = file_text, pattern = "^!\\w*?",
        sub_pattern = "!"
    )
    list(
        fdata = Biobase::AnnotatedDataFrame(
            data = .fdata,
            varMetadata = data.frame(
                labelDescription = unname(.column_data[colnames(.fdata)]),
                row.names = colnames(.fdata)
            )
        ),
        gpl_meta = .meta_data
    )
}

extract_geo_meta_and_column_data <- function(file_text, pattern = "^(!|#)\\w*?", sub_pattern = NULL) {
    .metadata <- data.table::fread(
        text = file_text[
            grepl(pattern, file_text, fixed = FALSE)
        ], sep = "\t", header = FALSE, blank.lines.skip = TRUE,
        na.strings = c("NA", "null", "NULL", "Null")
    )
    # if there only have one column, it should contain "=" string to split this
    # character into names and values, Otherwise, the first column should be the
    # names of these meta data
    if (identical(ncol(.metadata), 1L)) {
        .metadata <- .metadata[[1]][
            grepl("=", .metadata[[1]], perl = TRUE)
        ]
        meta_data <- data.table::tstrsplit(.metadata, "\\s*=\\s*", perl = TRUE)
        if (is.null(sub_pattern)) sub_pattern <- "^(!|#)"
        structure(meta_data[[2]], names = sub(sub_pattern, "", meta_data[[1]]))
    } else {
        if (is.null(sub_pattern)) sub_pattern <- pattern
        .metadata <- .metadata[, V1 := sub(pattern, "", V1)]
        data.table::dcast(
            data.table::melt(
                .metadata,
                id.vars = "V1",
                variable.name = "variable"
            ), variable ~ V1,
            fun.aggregate = paste0, collapse = "; "
        )[, .SD, .SDcols = !"variable"]
    }
}

extract_geo_gse_meta_data <- function(file_text) {
    meta_data <- c("Series", "Sample")
    names(meta_data) <- meta_data
    meta_data <- lapply(
        meta_data, function(x) {
            extract_geo_meta_and_column_data(
                file_text,
                pattern = paste0("^!", x, "_")
            )
        }
    )
    data.table::setDF(meta_data$Sample)
    rownames(meta_data$Sample) <- meta_data$Sample[["geo_accession"]]
    meta_data$Series <- as.list(meta_data$Series)
    for (x in c("sample_id", "pubmed_id", "platform_id")) {
        if (x %in% names(meta_data$Series)) {
            meta_data$Series[[x]] <- strsplit(
                meta_data$Series[[x]],
                split = ";?+ ", fixed = FALSE
            )[[1]]
        }
    }
    meta_data
}
