#' For all parsers used in `get_geo.R`, return a list
#' @noRd
parse_gse_matrix <- function(file_text) {

    # extract series matrix data
    matrix_data <- read_data_table(file_text)
    data.table::setDF(matrix_data)
    matrix_data <- as.matrix(column_to_rownames(matrix_data, 1))
    meta_data <- parse_gse_matrix_meta(file_text)
    # Construct ExpressionSet Object element
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
    # if it exist, fetch GPL feature data and experiment data
    gpl_id <- unique(meta_data$Sample[[grep(
        "platform_id", colnames(meta_data$Sample),
        ignore.case = TRUE, value = FALSE
    )]])

    list(
        matrix_data = matrix_data,
        pheno_data = pheno_data,
        experiment_data = experiment_data,
        gpl_id = gpl_id
    )
}

parse_gse_soft <- function(file_text) {
    entity_indices <- grep(
        "^\\^(SAMPLE|PLATFORM)", file_text,
        perl = TRUE
    )
    rlang::inform(
        sprintf("Found %d entities...", length(entity_indices))
    )
    soft_meta <- parse_meta(file_text[seq_len(entity_indices[[1]] - 1L)])
    soft_data_list <- vector(mode = "list", length = length(entity_indices))
    entity <- data.table::tstrsplit(
        file_text[entity_indices],
        split = "\\s*=\\s*"
    )
    names(soft_data_list) <- entity[[2]]
    seq_line_temp <- c(entity_indices, length(file_text))
    for (i in seq_along(entity_indices)) {
        accession <- entity[[2]][[i]]
        rlang::inform(
            sprintf(
                "%s (%d of %d entities)",
                accession, i, length(entity_indices)
            )
        )
        entity_data <- parse_soft(file_text[
            seq_line_temp[[i]]:(seq_line_temp[[i + 1L]] - 1L)
        ])
        soft_data_list[[i]] <- methods::new(
            switch(entity[[1]][[i]],
                `^SAMPLE` = "GSM",
                `^PLATFORM` = "GPL"
            ),
            meta = entity_data$meta,
            columns = entity_data$columns,
            datatable = entity_data$data_table,
            accession = accession
        )
    }
    soft_data_list <- split(
        soft_data_list,
        factor(entity[[1]], levels = c("^SAMPLE", "^PLATFORM")),
        drop = FALSE
    )
    list(
        meta = soft_meta,
        gsm = soft_data_list[["^SAMPLE"]],
        gpl = soft_data_list[["^PLATFORM"]]
    )
}

parse_soft <- function(file_text) {

    # parse GPL data table data - which is the feature data
    data_table <- read_data_table(file_text)
    if (nrow(data_table)) {
        # GEO uses 'TAG' instead of 'ID' for SAGE GSE/GPL entries,
        # but it is always the first column;
        # some dataset may contain duplicated feature names,
        # collapse other column by it.
        if (anyDuplicated(data_table[[1]])) {
            data_table <- data_table[
                , lapply(.SD, function(x) {
                    paste(unique(x), collapse = "; ")
                }),
                by = c(names(data_table)[[1]])
            ]
        }
        data.table::setDF(data_table)
        rownames(data_table) <- data_table[[1]]
    } else {
        data.table::setDF(data_table)
    }

    # parse meta data and column data
    meta_data <- parse_meta(file_text)
    column_data <- parse_column(file_text)
    list(
        data_table = data_table,
        meta = meta_data,
        columns = column_data
    )
}

# Lots of GSEs now use 'characteristics_ch1' and 'characteristics_ch2' for
# key-value pairs of annotation. If that is the case, this simply cleans those
# up and transforms the keys to column names and the values to column values.
# This function will modify `sample_dt` in place, So we needn't assign value.
parse_gse_matrix_sample_characteristics <- function(sample_dt) {
    characteristics_cols <- grep(
        "^characteristics_ch",
        colnames(sample_dt),
        value = TRUE, perl = TRUE
    )
    if (length(characteristics_cols)) {
        sample_dt[
            , (characteristics_cols) := lapply(.SD, as.character),
            .SDcols = characteristics_cols
        ]
        for (.characteristic_col in characteristics_cols) {
            characteristic_dt <- sample_dt[
                , data.table::tstrsplit(
                    .characteristic_col,
                    split = "(\\s*+);(\\s*+)",
                    perl = TRUE, fill = NA_character_
                ),
                env = list(.characteristic_col = .characteristic_col)
            ][, .SD, .SDcols = function(x) {
                any(grepl(":", x, perl = TRUE))
            }]
            if (ncol(characteristic_dt)) {
                lapply(characteristic_dt, function(x) {
                    # the first element contain the name of this key-value pair
                    # And the second is the value of the key-value pair
                    .characteristic_list <- data.table::tstrsplit(
                        x,
                        split = "(\\s*+):(\\s*+)",
                        perl = TRUE, fill = NA_character_
                    )
                    .characteristic_name <- unique(.characteristic_list[[1]])
                    .characteristic_name <- paste0(
                        # Since the names of these columns starting by "chr",
                        # we should extract the second "ch\\d?+"
                        str_extract_all(
                            .characteristic_col, "ch\\d?+"
                        )[[1]][[2]], "_",
                        # Omit NA value and only extract the first element
                        .characteristic_name[
                            !is.na(.characteristic_name)
                        ][[1]]
                    )
                    # Add this key-value pair to original data.table
                    sample_dt[
                        ,
                        (.characteristic_name) := .characteristic_list[[2]]
                    ]
                    data.table::setcolorder(
                        sample_dt,
                        neworder = .characteristic_name,
                        before = .characteristic_col
                    )
                })
            }
        }
    }
}

parse_gse_matrix_meta <- function(file_text) {
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
    parse_gse_matrix_sample_characteristics(meta_data$Sample)
    data.table::setDF(meta_data$Sample)
    rownames(meta_data$Sample) <- meta_data$Sample[["geo_accession"]]
    for (x in c("sample_id", "pubmed_id", "platform_id")) {
        if (x %in% names(meta_data$Series)) {
            meta_data$Series[[x]] <- strsplit(
                meta_data$Series[[x]],
                split = ";?+ ", fixed = FALSE,
                perl = TRUE
            )[[1]]
        }
    }
    meta_data
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
# names and values;
#' @return a data.frame
#' @noRd
parse_column <- function(file_text) {
    column_data <- read_column(file_text)
    column_data <- parse_line_with_equality_extractor(column_data)
    data.frame(
        Description = unname(column_data),
        row.names = names(column_data)
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
    # For lines containg "=" character
    meta_with_equal <- read_meta(file_text[line_with_equality])
    meta_with_equal <- parse_line_with_equality_extractor(meta_with_equal)
    if (!is.null(meta_with_equal)) meta_with_equal <- as.list(meta_with_equal)

    # For lines without "=" character
    meta_without_equal <- read_meta(file_text[!line_with_equality])
    meta_without_equal <- parse_line_without_equality_extractor(
        meta_without_equal
    )
    meta_data <- c(meta_with_equal, meta_without_equal)
    meta_data <- meta_data[
        !(duplicated(meta_data) & duplicated(names(meta_data)))
    ]
    meta_data %||% list()
}

# Line Starting with "!" or "#"
parse_line_with_equality_extractor <- function(dt) {
    if (!nrow(dt)) {
        return(NULL)
    } else {
        data_chr <- dt[[1]]
    }
    data_list <- data.table::tstrsplit(
        data_chr,
        split = "\\s*=\\s*",
        perl = TRUE
    )
    structure(
        data_list[[2L]],
        names = sub("^[#!]\\s*+", "", data_list[[1L]], perl = TRUE)
    )
}

parse_line_without_equality_extractor <- function(dt) {
    if (!nrow(dt) || identical(ncol(dt), 1L)) {
        return(NULL)
    }
    data <- dt[
        , V1 := sub("^!\\s*+", "", V1, perl = TRUE)
    ]
    data <- data.table::dcast(
        data.table::melt(
            data,
            id.vars = "V1",
            variable.name = "variable"
        ),
        variable ~ V1,
        fun.aggregate = paste0, collapse = "; "
    )[, .SD, .SDcols = !"variable"]
    as.list(data)
}

na_string <- c("NA", "null", "NULL", "Null")
read_data_table <- function(file_text) {
    data.table::fread(
        text = file_text[
            !grepl("^[\\^!#]", file_text, fixed = FALSE, perl = TRUE)
        ], sep = "\t", header = TRUE, blank.lines.skip = TRUE,
        na.strings = na_string
    )
}
read_meta <- function(file_text) {
    data.table::fread(
        text = grep("^!\\w*", file_text,
            value = TRUE,
            fixed = FALSE, perl = TRUE
        ), sep = "\t", header = FALSE, blank.lines.skip = TRUE,
        na.strings = na_string
    )
}
read_column <- function(file_text) {
    data.table::fread(
        text = grep("^#\\w[^\\t]*=", file_text,
            value = TRUE,
            fixed = FALSE, perl = TRUE
        ),
        sep = "\t", header = FALSE, blank.lines.skip = TRUE,
        na.strings = na_string
    )
}
