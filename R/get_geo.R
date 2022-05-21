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
                    "Annotation for ", id, " is not available, so will use GPL SOFT instead"
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
}

extract_geo_meta_data <- function(file_text) {
    .metadata <- data.table::fread(
        text = file_text[
            grepl("^!\\w*?_", file_text, fixed = FALSE)
        ], sep = "\t", header = FALSE, blank.lines.skip = TRUE,
        na.strings = c("NA", "null", "NULL", "Null")
    )
    .metadata <- .metadata[, V1 := sub("^!\\w*?_", "", V1)]
    data.table::dcast(
        data.table::melt(
            .metadata,
            id.vars = "V1",
            variable.name = "variable"
        ), variable ~ V1,
        fun.aggregate = paste0, collapse = "; "
    )[, .SD, .SDcols = !"variable"]
}

extract_geo_column_annot <- function(file_text) {
    .annot_data <- data.table::fread(
        text = file_text[
            grepl("^#.*=", file_text, fixed = FALSE)
        ], sep = "\t", header = FALSE, blank.lines.skip = TRUE,
        na.strings = c("NA", "null", "NULL", "Null")
    )
    .annot_data <- .annot_data[, V1 := sub("^#", "", V1)]
    
}

extract_geo_gse_meta_data <- function(file_text) {
    meta_data <- c("Series", "Sample")
    names(meta_data) <- meta_data
    meta_data <- lapply(meta_data, extract_geo_meta_data)
    data.table::setDF(meta_data$Sample)
    rownames(meta_data$Sample) <- meta_data$Sample[["geo_accession"]]
    meta_data$Series <- as.list(meta_data$Series)
    if ("sample_id" %in% names(meta_data$Series)) {
        meta_data$Series$sample_id <- strsplit(
            meta_data$Series$sample_id,
            split = " |; ", fixed = FALSE
        )[[1]]
    }
    meta_data
}
