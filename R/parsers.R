#' all parsers return a list
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

parse_gpl <- function(file_text) {

    # parse GPL data table data - which is the feature data
    data_table <- read_data_table(file_text)
    if (!nrow(data_table)) {
        return(NULL)
    }
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
    # parse meta data and column data
    meta_data <- parse_meta(file_text)
    column_data <- parse_column(file_text)
    list(
        data_table = data_table,
        meta = meta_data,
        column = column_data
    )
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

# Column should contain "=" string to split this character into names and
# values; return a character vector
parse_column <- function(file_text) {
    data <- read_column(file_text)
    if (!nrow(data)) {
        return(NULL)
    } else {
        column_text <- data[[1]]
    }
    column_text <- column_text[
        grepl("=", column_text, perl = TRUE)
    ]
    column_text <- data.table::tstrsplit(
        column_text, "\\s*=\\s*",
        perl = TRUE
    )
    structure(
        column_text[[2L]],
        names = sub("^#", "", column_text[[1L]], perl = TRUE)
    )
}
# the first column should be the names of these meta data; return a list
parse_meta <- function(file_text) {
    data <- read_meta(file_text)
    if (!nrow(data) || identical(ncol(data), 1L)) {
        return(NULL)
    }
    data <- data[, V1 := sub("^!", "", V1, perl = TRUE)]
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
        text = grep("^#\\w.*=", file_text,
            value = TRUE,
            fixed = FALSE, perl = TRUE
        ),
        sep = "\t", header = FALSE, blank.lines.skip = TRUE,
        na.strings = na_string
    )
}
