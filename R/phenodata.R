#' Parse key-value pairs in GEO series matrix file
#'
#' Lots of GSEs now use `"characteristics_ch*"` for key-value pairs of
#' annotation. If that is the case, this simply cleans those up and transforms
#' the keys to column names and the values to column values.
#'
#' @param data A data.frame like object, tibble and data.table are also okay.
#' @param columns A character vector, should be ended with "(ch\\d*)(\\.\\d*)?".
#'  these columns in `data` will be parsed. If `NULL`, all columns started with
#'  `"characteristics_ch"` will be used.
#' @param sep A string separating paired key-value, usually `":"`.
#' @param split Passed to [strsplit][base::strsplit] function. Default is ";"`.
#'
#' @details A characteristics annotation column usually contains multiple
#' key-value items, so we should first split these columns by `split` and then
#' extract `key-value` pairs. A new column will be added whose name is the first
#' group in the "(ch\\d*)(\\.\\d*)?$" regex pattern of the orginal column name
#' connected with `key` element in `key-value` pair by string "_" and the new
#' column value is the character vector of `value` element in all `key-value`
#' pair.
#'
#' @return A modified data.frame.
#'
#' @examples
#' gse53987 <- rgeo::get_geo(
#'     "gse53987", tempdir(),
#'     gse_matrix = TRUE, add_gpl = FALSE,
#'     pdata_from_soft = FALSE
#' )
#' gse53987_smp_info <- Biobase::pData(gse53987)
#' gse53987_smp_info$characteristics_ch1 <- stringr::str_replace_all(
#'     gse53987_smp_info$characteristics_ch1,
#'     "gender|race|pmi|ph|rin|tissue|disease state",
#'     function(x) paste0("; ", x)
#' )
#' gse53987_smp_info <- rgeo::parse_pdata(gse53987_smp_info)
#' gse53987_smp_info[grepl(
#'     "^ch1_|characteristics_ch1", names(gse53987_smp_info)
#' )]
#' @export
parse_pdata <- function(data, columns = NULL, sep = ":", split = ";") {
    if (!inherits(data, "data.frame")) {
        cli::cli_abort("{.arg data} must be a {.cls data.frame}")
    }
    kept_rownames <- rownames(data)
    data <- data.table::as.data.table(data, keep.rownames = FALSE)
    if (!rlang::is_scalar_character(sep)) {
        cli::cli_abort("{.arg sep} must be a single string")
    }
    if (!rlang::is_scalar_character(split)) {
        cli::cli_abort("{.arg split} must be a single string")
    }
    tryCatch(
        parse_gse_matrix_sample_characteristics(
            sample_dt = data,
            characteristics_cols = columns,
            sep = sep,
            split = split
        ),
        warn_cannot_parse_characteristics = function(cnd) {
            cli::cli_abort(c(
                "There remains more than one {.arg sep} ({.val {sep}}) characters after splitting {.arg columns} by {.arg split} ({.val {split}})",
                i = "Please check if {.arg sep} and {.arg split} parameters can parse {.arg columns}."
            ), parent = cnd)
        }
    )
    # As the modification in place of data.table will prevent print methods
    # A simple method is just use `[` function.
    data.table::setDF(data, rownames = kept_rownames)
}

# Lots of GSEs now use 'characteristics_ch1' and 'characteristics_ch2' for
# key-value pairs of annotation. If that is the case, this simply cleans those
# up and transforms the keys to column names and the values to column values.
# This function will modify `sample_dt` in place, So we needn't assign value.
# `sample_dt` should be a data.table
parse_gse_matrix_sample_characteristics <- function(sample_dt, characteristics_cols = NULL, sep = ":", split = ";") {
    if (is.null(characteristics_cols)) {
        characteristics_cols <- str_subset(
            colnames(sample_dt), "^characteristics_ch"
        )
    } else {
        characteristics_cols <- str_subset(
            characteristics_cols, "ch\\d*(\\.\\d*)?$"
        )
    }
    if (length(characteristics_cols)) {
        split <- paste0("(\\s*+)", split, "(\\s*+)")
        for (.characteristic_col in characteristics_cols) {
            characteristic_list <- str_split(
                sample_dt[[as.character(.characteristic_col)]], split
            )
            characteristic_list <- lapply(characteristic_list, function(x) {
                str_subset(x, sep)
            })
            have_more_than_one_sep <- vapply(
                characteristic_list,
                function(x) any(lengths(str_extract_all(x, sep)) > 1L),
                logical(1L)
            )
            if (any(have_more_than_one_sep)) {
                cli::cli_warn(
                    c(
                        "Cannot parse characteristic column correctly",
                        i = "Details see {.val { .characteristic_col }} column in {.field phenoData}",
                        i = "Please use {.fun parse_pdata} or {.fun parse_gsm_list} function to convert it manually if necessary!"
                    ),
                    class = "warn_cannot_parse_characteristics"
                )
                next
            }
            .temp_characteristic_list <- parse_name_value_pairs(
                characteristic_list,
                sep = sep
            )
            if (length(.temp_characteristic_list)) {
                .characteristic_name <- paste0(
                    # we extract the last "ch\\d*" pattern as the column
                    # name, which is the first group defined by parentheses.
                    # This is just the second column of `str_match`.
                    # Sometimes there may be a "\\.\\d*" tail
                    str_match(.characteristic_col, "(ch\\d*)(\\.\\d*)?$")[
                        , 2L,
                        drop = TRUE
                    ],
                    "_",
                    names(.temp_characteristic_list)
                )
                # Add this key-value pair to original data.table
                sample_dt[
                    ,
                    (.characteristic_name) := .temp_characteristic_list
                ]
                data.table::setcolorder(
                    sample_dt,
                    neworder = .characteristic_name,
                    before = .characteristic_col
                )
            }
        }
    }
    sample_dt
}

#' Parse key-value pairs in GEO series soft file
#'
#' Lots of GSEs now use `"characteristics_ch*"` meta header data for key-value
#' pairs of annotation. If that is the case, this simply cleans the GSM
#' `GEOSoft` @meta slot up and transforms the keys to column names and the
#' values to column values.
#'
#' @param gsm_list A list of GEOSoft, especially for @gsm slot in a `GEOSeries`
#'   object.
#'
#' @return a data.frame whose rows are samples and columns are the sample infos
#'
#' @examples
#' gse201530_soft <- rgeo::get_geo(
#'     "GSE201530",
#'     dest_dir = tempdir(),
#'     gse_matrix = FALSE
#' )
#' rgeo::parse_gsm_list(rgeo::gsm(gse201530_soft))
#' @export
parse_gsm_list <- function(gsm_list) {
    test_gsm_list <- is.list(gsm_list) && all(vapply(
        gsm_list, function(x) {
            methods::is(x, "GEOSoft") &&
                all(startsWith(names(meta(x)), "Sample_"))
        }, logical(1L)
    ))
    if (!test_gsm_list) {
        cli::cli_abort(
            "{.arg gsm_list} must be a list of {.cls GEOSoft} object, especially for {.field @gsm} slot in a GEOSeries object."
        )
    }
    res <- parse_gse_soft_sample_characteristics(gsm_list)
    set_rownames(res, "geo_accession")
}

parse_gse_soft_sample_characteristics <- function(gsm_list) {
    sample_meta_list <- lapply(gsm_list, function(gsm_geosoft) {
        sample_meta_data <- meta(gsm_geosoft)
        if (any(lengths(sample_meta_data) > 1L)) {
            sample_meta_data[lengths(sample_meta_data) > 1L] <- lapply(
                sample_meta_data[lengths(sample_meta_data) > 1L], list
            )
        }
        data.table::setDT(sample_meta_data)
    })
    sample_meta_dt <- data.table::rbindlist(
        sample_meta_list,
        use.names = TRUE, fill = TRUE, idcol = FALSE
    )
    data.table::setnames(
        sample_meta_dt,
        function(x) str_replace(x, "^Sample_", "")
    )
    # We select columns with names starting with "characteristics_ch" and at
    # least 50% of the elements in the column contains character ":",
    # For GEO use ":" string to separate Key-value pairs.
    characteristics_cols <- startsWith(
        colnames(sample_meta_dt), "characteristics_ch"
    )
    column_have_sep <- sample_meta_dt[, vapply(.SD, function(list_col) {
        have_sep <- vapply(list_col, function(x) {
            all(str_detect(x, ":", fixed = TRUE), na.rm = TRUE)
        }, logical(1L))
        mean(have_sep, na.rm = TRUE) >= 0.5
    }, logical(1L)), .SDcols = characteristics_cols]
    characteristics_cols <- colnames(sample_meta_dt)[
        characteristics_cols[column_have_sep]
    ]

    if (length(characteristics_cols)) {
        any_more_than_one_seps <- sample_meta_dt[
            , vapply(.SD, function(list_col) {
                # for a column with characteristics
                # we check if any elements have more than one ":"
                have_more_than_one_seps <- vapply(
                    list_col, function(x) {
                        any(lengths(str_extract_all(x, ":")) > 1L)
                    }, logical(1L)
                )
                any(have_more_than_one_seps)
            }, logical(1L)),
            .SDcols = characteristics_cols
        ]
        if (any(any_more_than_one_seps)) {
            # column names with more than one ":"
            warn_column_names <- characteristics_cols[any_more_than_one_seps] # nolint
            cli::cli_warn(
                c(
                    "More than one characters {.val :} found in meta characteristics data",
                    i = "Details see: {.val {warn_column_names}} column in returned data.",
                    i = "Please use {.fun parse_pdata} or combine {.fun strsplit} and {.fun parse_gsm_list} function to convert it manually if necessary!"
                )
            )
        }
        for (.characteristic_col in characteristics_cols) {
            .temp_characteristic_list <- parse_name_value_pairs(
                sample_meta_dt[[.characteristic_col]],
                sep = ":"
            )
            if (length(.temp_characteristic_list)) {
                .characteristic_name <- paste0(
                    # we extract the last "ch\\d*" pattern as the column
                    # name, which is the first group defined by parentheses.
                    # This is just the second column of `str_match`.
                    # Sometimes there may be a "\\.\\d*" tail
                    str_match(.characteristic_col, "(ch\\d*)(\\.\\d*)?$")[
                        , 2L,
                        drop = TRUE
                    ],
                    "_",
                    names(.temp_characteristic_list)
                )
                sample_meta_dt[
                    ,
                    (.characteristic_name) := .temp_characteristic_list
                ]
                data.table::setcolorder(
                    sample_meta_dt,
                    neworder = .characteristic_name,
                    before = .characteristic_col
                )
            }
        }
    }
    list_column_names <- names(
        sample_meta_dt[, .SD, .SDcols = is.list]
    )
    sample_meta_dt[
        , (list_column_names) := lapply(.SD, function(x) {
            vapply(x, paste0, character(1L), collapse = "; ")
        }),
        .SDcols = list_column_names
    ]
}

# parse key-value pairs separeted by ":". For a list of key-value pairs
# characters (like: `list(c("a:1", "b:2"), c("a:3", "b:4"))`), this function
# simply cleans those up and transforms the list into a list object, the names
# of returned value is the unique keys in the pairs, the element of the returned
# list is the values in the paris.
# See: `parse_name_value_pairs(list(c("a:1", "b:2"), c("a:3", "b:4")))`
#' @return a list, every element of which corresponds to each key-value pairs
#' group by key in the paris.
#' @noRd
parse_name_value_pairs <- function(pair_list, sep = ":") {
    .characteristic_list <- lapply(pair_list, function(x) {
        if (!length(x)) {
            return(data.table::data.table())
        }
        # Don't use `data.table::tstrsplit`, as it will split string into three
        # or more elements.
        name_value_pairs <- data.table::transpose(
            str_split_fixed(x, paste0("(\\s*+)", sep, "(\\s*+)")),
            fill = NA_character_
        )
        if (length(name_value_pairs) < 2L) {
            out <- rep_len(NA_character_, length(name_value_pairs[[1L]]))
        } else {
            out <- name_value_pairs[[2L]]
        }
        out <- as.list(out)
        data.table::setattr(out, "names", name_value_pairs[[1L]])
        data.table::setDT(out)
        out
    })
    characteristic_dt <- data.table::rbindlist(
        .characteristic_list,
        use.names = TRUE, fill = TRUE
    )
    data.table::setnames(characteristic_dt, make.unique)
    # parse text into corresponding atomic vector mode
    lapply(characteristic_dt, function(x) {
        read_text(
            text = x, sep = "", header = FALSE,
            strip.white = TRUE, blank.lines.skip = FALSE, fill = TRUE
        )[[1L]]
    })
}
