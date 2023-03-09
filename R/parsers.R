#' For all parsers used in `get_geo.R`, return a list
#' @noRd
parse_gse_matrix <- function(file_text, pdata_from_soft) {
    # extract series matrix data
    matrix_data <- read_data_table(file_text)
    data.table::setDF(matrix_data)
    matrix_data <- as.matrix(column_to_rownames(matrix_data, 1L))
    meta_data <- parse_gse_matrix_meta(
        file_text,
        pdata_from_soft = pdata_from_soft
    )

    # fetch phenoData and experiment data
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
    pheno_data <- Biobase::AnnotatedDataFrame(
        data = meta_data$Sample[colnames(matrix_data), , drop = FALSE]
    )
    # fetch GPL accession
    gpl_id <- unique(meta_data$Sample[[grep(
        "platform_id", colnames(meta_data$Sample),
        ignore.case = TRUE, value = FALSE
    )]])

    list(
        assayData = matrix_data,
        phenoData = pheno_data,
        experimentData = experiment_data,
        annotation = gpl_id
    )
}

#' @param entity_type One of "sample", "platform" or "all".
#' @noRd
parse_gse_soft <- function(file_text, entity_type = "all", only_meta = FALSE) {
    meta_idx <- grep("^\\^(SAMPLE|PLATFORM)", file_text,
        perl = TRUE, value = FALSE
    )
    soft_meta <- parse_meta(file_text[seq_len(meta_idx[[1L]] - 1L)])
    if (only_meta) {
        return(list(meta = soft_meta, gsm = NULL, gpl = NULL))
    }
    if (entity_type == "all") {
        entity_indices <- meta_idx
    } else {
        entity_marker <- paste0(
            "^\\^", switch(entity_type,
                sample = "SAMPLE",
                platform = "PLATFORM"
            )
        )
        entity_indices <- grep(entity_marker, file_text,
            perl = TRUE, value = FALSE
        )
    }
    rlang::inform(sprintf("Found %d entities...", length(entity_indices)))
    soft_data_list <- vector(mode = "list", length = length(entity_indices))
    # For every entity data, the data is seperated by "=" into name-value pairs
    # Don't use `data.table::tstrsplit`, as it will split string into three or
    # more element.
    entity <- data.table::transpose(
        str_split(file_text[entity_indices], "\\s*=\\s*")
    )
    names(soft_data_list) <- entity[[2L]]
    seq_line_temp <- c(entity_indices, length(file_text))
    for (i in seq_along(entity_indices)) {
        accession <- entity[[2L]][[i]]
        rlang::inform(
            sprintf(
                "%s (%d of %d entities)",
                accession, i, length(entity_indices)
            )
        )
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
        return(list(data_table = NULL, meta = meta_data, columns = NULL))
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
                by = c(names(data_table)[[1L]])
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
    subset_lines <- grep(
        "^!subset", file_text,
        perl = TRUE, value = FALSE
    )
    # parse meta data
    meta_data <- parse_meta(file_text[-subset_lines])
    if (only_meta) {
        return(list(data_table = NULL, meta = meta_data, columns = NULL))
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
    data.table::setDF(column_data)
    column_data <- column_to_rownames(column_data, "V1")[
        colnames(data_table), ,
        drop = FALSE
    ]
    list(
        data_table = data_table,
        meta = meta_data,
        columns = column_data
    )
}

parse_gse_matrix_meta <- function(file_text, pdata_from_soft) {
    meta_groups <- c("Series", "Sample")
    names(meta_groups) <- meta_groups
    meta_data <- lapply(
        meta_groups, function(group) {
            meta_text <- grep(
                paste0("^!", group, "_"), file_text,
                value = TRUE,
                fixed = FALSE, perl = TRUE
            )
            meta_data <- parse_meta(meta_text)
            rlang::set_names(
                meta_data,
                function(x) sub(paste0("^", group, "_"), "", x, perl = TRUE)
            )
        }
    )
    data.table::setDT(meta_data$Sample)
    if (!pdata_from_soft) {
        parse_gse_matrix_sample_characteristics(meta_data$Sample)
    }
    data.table::setDF(
        meta_data$Sample,
        rownames = as.character(meta_data$Sample[["geo_accession"]])
    )
    for (x in c("sample_id", "pubmed_id", "platform_id")) {
        if (x %in% names(meta_data$Series)) {
            meta_data$Series[[x]] <- strsplit(
                meta_data$Series[[x]],
                split = ";?+ ", fixed = FALSE,
                perl = TRUE
            )[[1L]]
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
            strsplit(subset_sample_id, ",", perl = TRUE),
            use.names = FALSE
        ),
        by = c(
            "subset_dataset_id",
            "subset_description",
            "subset_type"
        )
    ][, lapply(.SD, function(x) paste0(x, collapse = "; ")), by = V1]
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
    labelDescription <- sub(
        ";\\s*$", "", labelDescription,
        perl = TRUE
    )
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
    line_with_equality <- grepl(
        "^[^\\t]*=", file_text,
        fixed = FALSE, perl = TRUE
    )
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
        str_split(dt[[1L]], "\\s*=\\s*")
    )
    split(
        name_value_pairs[[2L]],
        factor(sub("^[#!]\\s*+", "", name_value_pairs[[1L]], perl = TRUE))
    )
}

# Line starting with "!"
# For line seperated by "\t", the element of every row stand for a item
# So for duplicated rows IDs (the first column), we should collapse it.
parse_line_sep_by_table <- function(dt) {
    if (!nrow(dt) || ncol(dt) == 1L) {
        return(NULL)
    }
    dt[, V1 := factor(sub("^!\\s*+", "", V1, perl = TRUE))]
    meta_list <- split(
        dt[, lapply(.SD, paste0, collapse = ""), by = "V1"],
        by = "V1", drop = TRUE,
        keep.by = FALSE
    )
    lapply(meta_list, function(x) {
        unlist(x, recursive = FALSE, use.names = FALSE)
    })
}

na_string <- c("NA", "null", "NULL", "Null")
read_data_table <- function(file_text) {
    read_text(
        text = grep("^[\\^!#]", file_text,
            value = TRUE, fixed = FALSE, perl = TRUE, invert = TRUE
        ),
        sep = "\t", header = TRUE, blank.lines.skip = TRUE,
        na.strings = na_string, check.names = FALSE
    )
}
read_meta <- function(file_text, meta_type = "table") {
    read_text(
        text = grep("^!\\w*", file_text,
            value = TRUE, fixed = FALSE, perl = TRUE
        ),
        sep = switch(meta_type,
            table = "\t",
            equality = ""
        ),
        colClasses = switch(meta_type,
            table = NULL,
            equality = "character"
        ),
        header = FALSE, blank.lines.skip = TRUE,
        na.strings = na_string, check.names = FALSE
    )
}
read_column <- function(file_text) {
    read_text(
        text = grep("^#\\w[^\\t]*=", file_text,
            value = TRUE, fixed = FALSE, perl = TRUE
        ),
        sep = "", header = FALSE, blank.lines.skip = TRUE,
        na.strings = na_string,
        colClasses = "character",
        check.names = FALSE
    )
}
