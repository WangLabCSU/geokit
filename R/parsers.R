#' For all parsers used in `get_geo.R`, return a list
#' @noRd
parse_gse_matrix <- function(file_text, gse_sample_data = NULL) {
    # extract series matrix data
    matrix_data <- read_data_table(file_text)
    matrix_data <- as.matrix(matrix_data, names(matrix_data)[[1L]])
    meta_data <- parse_gse_matrix_meta(file_text)

    # fetch phenoData
    if (is.null(gse_sample_data)) {
        parse_gse_matrix_sample_characteristics(meta_data$Sample)
        data.table::setDF(
            meta_data$Sample,
            rownames = as.character(meta_data$Sample[["geo_accession"]])
        )
        pheno_data <- Biobase::AnnotatedDataFrame(
            data = meta_data$Sample[colnames(matrix_data), , drop = FALSE]
        )
    } else {
        gse_sample_data <- parse_gse_soft_sample_characteristics(
            gse_sample_data[colnames(matrix_data)]
        )
        data.table::setDF(
            gse_sample_data,
            rownames = gse_sample_data[["geo_accession"]]
        )
        pheno_data <- Biobase::AnnotatedDataFrame(
            data = gse_sample_data[colnames(matrix_data), , drop = FALSE]
        )
    }

    # fetch experiment data
    experiment_data <- Biobase::MIAME(
        name = meta_data$Series$contact_name %||% "",
        title = meta_data$Series$title,
        contact = meta_data$Series$contact_email %||% "",
        pubMedIds = meta_data$Series$pubmed_id %||% "",
        abstract = meta_data$Series$summary %||% "",
        url = if (!is.null(meta_data$Series$web_link)) {
            meta_data$Series$web_link
        } else if (!is.null(meta_data$Series$geo_accession)) {
            paste0(
                "https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=",
                meta_data$Series$geo_accession
            )
        } else {
            "https://www.ncbi.nlm.nih.gov/geo/"
        },
        other = meta_data$Series
    )
    # fetch GPL accession
    gpl_id <- meta_data$Sample[[str_which(
        colnames(meta_data$Sample), "platform_id",
        ignore.case = TRUE
    )]][[1L]]

    list(
        assayData = matrix_data,
        phenoData = pheno_data,
        experimentData = experiment_data,
        annotation = gpl_id
    )
}

#' @param entity_type One of "sample", "platform" or "all". If all, metadata
#'   will be extracted, otherwise, metadata will always be `NULL`.
#' @param only_meta Whether to extracte metadata only, if `TRUE`, entity_type
#'   must be "all".
#' @noRd
parse_gse_soft <- function(file_text, entity_type = "all", only_meta = FALSE) {
    if (entity_type == "all") {
        entity_indices <- str_which(file_text, "^\\^(SAMPLE|PLATFORM)")
        if (length(entity_indices)) {
            soft_meta <- parse_meta(
                file_text[seq_len(entity_indices[[1L]] - 1L)]
            )
        } else {
            soft_meta <- parse_meta(file_text)
        }
        if (only_meta) {
            return(soft_meta)
        }
    } else {
        soft_meta <- NULL
        entity_marker <- paste0(
            "^\\^", switch(entity_type,
                sample = "SAMPLE",
                platform = "PLATFORM"
            )
        )
        entity_indices <- str_which(file_text, entity_marker)
    }
    soft_data_list <- vector(mode = "list", length = length(entity_indices))
    # For every entity data, the data is seperated by "=" into name-value pairs
    # Don't use `data.table::tstrsplit`, as it will split string into three or
    # more element.
    entity <- data.table::transpose(
        str_split_fixed(file_text[entity_indices], "\\s*=\\s*")
    )
    names(soft_data_list) <- entity[[2L]]
    seq_line_temp <- c(entity_indices, length(file_text))
    cli::cli_progress_bar(
        format = "{cli::pb_spin} Parsing series {.field soft} entity {.field {accession}} | {cli::pb_current}/{cli::pb_total}", # nolint
        format_done = "Parsing {.val {cli::pb_total}} entit{?y/ies} in {cli::pb_elapsed}",
        total = length(entity_indices),
        clear = FALSE
    )
    for (i in seq_along(entity_indices)) {
        accession <- entity[[2L]][[i]]
        cli::cli_progress_update()
        entity_data <- parse_gpl_or_gsm_soft(file_text[
            seq_line_temp[[i]]:(seq_line_temp[[i + 1L]] - 1L)
        ])
        soft_data_list[[i]] <- methods::new(
            "GEOSoft",
            meta = entity_data$meta,
            columns = entity_data$columns,
            datatable = entity_data$data_table,
            accession = accession
        )
    }
    soft_data_list <- split(
        soft_data_list,
        factor(entity[[1L]], levels = c("^SAMPLE", "^PLATFORM")),
        drop = FALSE
    )
    list(
        meta = soft_meta,
        gsm = soft_data_list[["^SAMPLE"]],
        gpl = soft_data_list[["^PLATFORM"]]
    )
}

# For GPL and GSM entity, they share the same file structure
parse_gpl_or_gsm_soft <- function(file_text, only_meta = FALSE) {
    # parse meta data
    meta_data <- parse_meta(file_text)
    if (only_meta) {
        return(meta_data)
    }

    # parse data table data - which is the feature data
    data_table <- read_data_table(file_text)
    data.table::setnames(data_table, make.unique)
    if (nrow(data_table)) {
        # GEO uses 'TAG' instead of 'ID' for SAGE GSE/GPL entries,
        # but it is always the first column;
        # some dataset may contain duplicated feature names,
        # collapse other column by it.
        if (anyDuplicated(data_table[[1L]])) {
            data_table <- data_table[
                , lapply(.SD, function(x) {
                    paste(unique(x), collapse = "; ")
                }),
                by = names(data_table)[[1L]]
            ]
        }
        data.table::setDF(data_table, rownames = as.character(data_table[[1L]]))
    } else {
        data.table::setDF(data_table)
    }

    # parse column data
    column_data <- parse_columns(file_text, colnames(data_table))
    list(
        data_table = data_table,
        meta = meta_data,
        columns = column_data
    )
}

#' @importFrom data.table merge.data.table
parse_gds_soft <- function(file_text, only_meta = FALSE) {
    subset_lines <- str_which(file_text, "^!subset")
    # parse meta data
    meta_data <- parse_meta(file_text[-subset_lines])
    if (only_meta) {
        return(meta_data)
    }

    # parse data_table data
    data_table <- read_data_table(file_text[-subset_lines])
    if (nrow(data_table)) {
        data.table::setDF(data_table, rownames = as.character(data_table[[1L]]))
    } else {
        data.table::setDF(data_table)
    }

    # parse column data
    column_data <- parse_columns(file_text[-subset_lines], colnames(data_table))
    data.table::setDT(column_data, keep.rownames = "V1")

    subset_data <- parse_gds_subset(file_text[subset_lines])
    # Merge subset data into column data
    column_data <- merge(
        column_data,
        subset_data,
        by = "V1",
        all.x = TRUE, sort = FALSE
    )
    column_data <- column_data[colnames(data_table), on = "V1"]
    column_data <- as.data.frame(column_data[, !1L], column_data$V1)
    list(
        data_table = data_table,
        meta = meta_data,
        columns = column_data
    )
}

#' @importFrom data.table %chin%
parse_gse_matrix_meta <- function(file_text) {
    meta_groups <- c("Series", "Sample")
    names(meta_groups) <- meta_groups
    meta_data <- lapply(meta_groups, function(group) {
        meta_text <- str_subset(file_text, paste0("^!", group, "_"))
        meta_data <- parse_meta(meta_text)
        rlang::set_names(
            meta_data,
            function(x) str_replace(x, paste0("^", group, "_"), "")
        )
    })
    data.table::setDT(meta_data$Sample)
    for (x in c("sample_id", "pubmed_id", "platform_id")) {
        if (x %chin% names(meta_data$Series)) {
            meta_data$Series[[x]] <- str_split(meta_data$Series[[x]], ";?+ ")[[1L]]
        }
    }
    meta_data
}

parse_gds_subset <- function(subset_file_text) {
    subset_data <- read_meta(subset_file_text, "equality")
    subset_data <- parse_line_sep_by_equality(subset_data)
    data.table::setDT(subset_data)
    # For GDS subset data, there'll be four column, the subset_sample_id
    # correspond to `colnames(data_table)` but these ids are collapsed and some
    # are duplicated, so we should unnest it and then collapse other columns
    # group by `subset_sample_id`
    subset_data[
        , unlist(
            str_split(subset_sample_id, ","),
            use.names = FALSE
        ),
        by = c(
            "subset_dataset_id",
            "subset_description",
            "subset_type"
        )
    ][, lapply(.SD, paste0, collapse = "; "), by = V1]
}

#' There are four different types of line that are recognized in SOFT. The
#' presence of any one of three characters in the first character position in
#' the line indicates three of the line types, and the absence of any of these
#' indicates the fourth line type. The four line-type characters and
#' descriptions of what they indicate are:
#' | Symbol | Description |             Line type              |
#' | :----: | :---------: | :--------------------------------: |
#' |   ^    | caret lines |       entity indicator line        |
#' |   !    | bang lines  |       entity attribute line        |
#' |   #    | hash lines  | data table header description line |
#' |  n/a   | data lines  |           data table row           |
#' @noRd

# Column should start by "#" and contain "=" string to split this character into
# names and values; For line seperated by "=", every row represents a item. But
# every item in `columns` data should only own a value of length one, so we
# collapse it.
#' @return a data.frame
#' @noRd
parse_columns <- function(file_text, target_rownames) {
    column_data <- read_column(file_text)
    column_data <- parse_line_sep_by_equality(column_data)
    labelDescription <- vapply(column_data[target_rownames], function(x) {
        if (is.null(x)) {
            NA_character_
        } else if (length(x) > 1L) {
            paste0(x, collapse = "; ")
        } else {
            x
        }
    }, character(1L), USE.NAMES = FALSE)
    # Sometimes column_data may contain character vectors with length greater
    # than 1L and the last value of which is a blank string ""; after above
    # transformation, a tail "; " will be inserted in this element, So we just
    # remove the tail "; " string.
    labelDescription <- str_replace(labelDescription, ";\\s*$", "")
    labelDescription <- data.table::fifelse(
        labelDescription == "",
        NA_character_, labelDescription,
        na = NA_character_
    )
    data.frame(
        labelDescription = labelDescription,
        row.names = target_rownames
    )
}

# Meta data is split into two types differentiated by string "="
# For lines containg "=" character, This is the same with `column` data
# For lines without "=" character, the first column should be the names of these
# meta data
#' @return a list
#' @noRd
parse_meta <- function(file_text) {
    line_with_equality <- str_detect(file_text, "^[^\\t]*=")
    # For lines seperated by "="
    meta_sep_by_equality <- read_meta(file_text[line_with_equality], "equality")
    meta_sep_by_equality <- parse_line_sep_by_equality(meta_sep_by_equality)

    # For lines seperated by "\t"
    meta_sep_by_table <- read_meta(file_text[!line_with_equality])
    meta_sep_by_table <- parse_line_sep_by_table(
        meta_sep_by_table
    )
    meta_data <- c(meta_sep_by_equality, meta_sep_by_table)
    meta_data <- meta_data[
        !(duplicated(meta_data) & duplicated(names(meta_data)))
    ]
    meta_data %||% list()
}

# Line Starting with "!" or "#"
# For line seperated by "=", every row represents a item.
# Don't use `data.table::tstrsplit`, as it will split string into three or
# more pieces
parse_line_sep_by_equality <- function(dt) {
    if (!nrow(dt)) {
        return(NULL)
    }
    name_value_pairs <- data.table::transpose(
        str_split_fixed(dt[[1L]], "\\s*=\\s*")
    )
    split(
        name_value_pairs[[2L]],
        factor(str_replace(name_value_pairs[[1L]], "^[#!]\\s*+", ""))
    )
}

# Line starting with "!"
# For line seperated by "\t", the element of every row stand for a item
# So for duplicated rows IDs (the first column), we should collapse it.
parse_line_sep_by_table <- function(dt) {
    if (!nrow(dt) || ncol(dt) == 1L) {
        return(NULL)
    }
    dt[, V1 := factor(str_replace(V1, "^!\\s*+", ""))]
    meta_list <- split(
        dt[, lapply(.SD, paste0, collapse = ""), by = "V1"],
        by = "V1", drop = TRUE,
        keep.by = FALSE
    )
    lapply(meta_list, function(x) {
        unlist(x, recursive = FALSE, use.names = FALSE)
    })
}

read_data_table <- function(file_text) {
    read_text(
        text = str_subset(file_text, "^[\\^!#]", invert = TRUE),
        sep = "\t", header = TRUE, blank.lines.skip = TRUE,
        check.names = FALSE
    )
}
read_meta <- function(file_text, meta_type = "table") {
    read_text(
        text = str_subset(file_text, "^!\\w*"),
        sep = switch(meta_type,
            table = "\t",
            equality = ""
        ),
        colClasses = switch(meta_type,
            table = NULL,
            equality = "character"
        ),
        header = FALSE, blank.lines.skip = TRUE,
        check.names = FALSE
    )
}
read_column <- function(file_text) {
    read_text(
        text = str_subset(file_text, "^#\\w[^\\t]*="),
        sep = "", header = FALSE, blank.lines.skip = TRUE,
        colClasses = "character",
        check.names = FALSE
    )
}
