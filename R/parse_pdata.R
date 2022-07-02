#' Parse key-value pairs in GEO series soft file
#'
#' Lots of GSEs now use `"characteristics_ch*"` meta header data for key-value
#' pairs of annotation. If that is the case, this simply cleans the GSM
#' `GEODataTable` @meta slot up and transforms the keys to column names and the
#' values to column values.
#'
#' @param gsm_list a list of GEODataTable, especially for @gsm slot in a
#' `GEOSeries` object.
#'
#' @return a data.frame whose rows are samples and columns are the sample infos
#'
#' @examples
#' gse201530_soft <- rgeo::get_geo(
#'     "GSE201530",
#'     dest_dir = tempdir(),
#'     gse_matrix = FALSE
#' )
#' rgeo::parse_pdata(rgeo::gsm(gse201530_soft))
#' @export
parse_pdata <- function(gsm_list) {
    test_gsm_list <- is.list(gsm_list) && all(vapply(
        gsm_list, function(x) {
            methods::is(x, "GEODataTable") && all(
                grepl("^Sample_", names(meta(x)), perl = TRUE)
            )
        }, logical(1L)
    ))
    if (!test_gsm_list) {
        rlang::abort(
            "gsm_list should be a list of GEODataTable, especially for @gsm slot in a GEOSeries object."
        )
    }
    res <- parse_gse_soft_sample_characteristics(gsm_list)
    data.table::setDF(res, rownames = res[["geo_accession"]])
    res
}

parse_gse_soft_sample_characteristics <- function(gsm_list) {
    sample_meta_list <- lapply(gsm_list, function(geodatatable) {
        sample_meta_data <- meta(geodatatable)
        if (any(lengths(sample_meta_data) > 1L)) {
            sample_meta_data[lengths(sample_meta_data) > 1L] <- lapply(
                sample_meta_data[lengths(sample_meta_data) > 1L],
                function(data) list(data)
            )
        }
        data.table::setDT(sample_meta_data)
        sample_meta_data
    })
    sample_meta_dt <- data.table::rbindlist(
        sample_meta_list,
        use.names = TRUE, fill = TRUE, idcol = FALSE
    )
    data.table::setnames(
        sample_meta_dt,
        function(x) sub("^Sample_", "", x, perl = TRUE)
    )
    # We select columns with names starting with "characteristics_ch" and there
    # are at least one element whose all sub-elements contains character ":",
    # For GEO use ":" string to separate Key-value pairs.
    characteristics_cols <- grepl(
        "^characteristics_ch",
        colnames(sample_meta_dt),
        perl = TRUE
    ) & vapply(
        sample_meta_dt, function(list_col) {
            any(vapply(list_col, function(x) {
                all(grepl(":", x, perl = TRUE, fixed = FALSE))
            }, logical(1L)))
        },
        logical(1L)
    )
    characteristics_cols <- colnames(sample_meta_dt)[characteristics_cols]

    if (length(characteristics_cols)) {
        is_more_than_one_connection_chr <- sample_meta_dt[
            , lapply(.SD, function(x) {
                vapply(x, function(sub_element) {
                    any(lengths(str_extract_all(sub_element, ":")) > 1L)
                }, logical(1L))
            }),
            .SDcols = characteristics_cols
        ]
        any_more_than_one_connection_chr <- vapply(
            is_more_than_one_connection_chr,
            function(x) any(x), logical(1L)
        )
        if (any(any_more_than_one_connection_chr)) {
            # column names with more than one ":"
            warn_column_names <- characteristics_cols[
                any_more_than_one_connection_chr
            ]
            rlang::warn(
                c(
                    "More than one characters \":\" found in meta characteristics data`: ",
                    paste0(
                        "Details see: ", warn_column_names, " column in returned data."
                    ),
                    "Please use `set_pdata` or `parse_pdata` function to convert it manually if necessary!"
                )
            )
        }
        for (.characteristic_col in characteristics_cols) {
            .temp_characteristic_list <- parse_name_value_pairs(
                sample_meta_dt[[.characteristic_col]], sep = ":"
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
            vapply(x, function(x) paste0(x, collapse = "; "), character(1L))
        }),
        .SDcols = list_column_names
    ]
}
