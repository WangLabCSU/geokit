#' Parse key-value pairs in GEO series matrix file
#'
#' Lots of GSEs now use `"characteristics_ch*"` for key-value pairs of
#' annotation. If that is the case, this simply cleans those up and transforms
#' the keys to column names and the values to column values. This function is
#' just like `set*` function in `data.table`, it will modify `data` in place, So
#' we don't have to assign value. `data` should be a data.table.
#'
#' @param data a data.table, this function will modify `data` in place.
#' @param columns a character vector, should be ended with "(ch\\d*)(\\.\\d*)?".
#' these columns in `data` will be parsed. If `NULL`, all columns started with
#' `"characteristics_ch"` will be used.
#' @param sep the string separating paired key-value, usually `":"`.
#' @param split Passed to [strsplit][base::strsplit] function.  Default is
#' `"(\\s*+);(\\s*+)"`.
#'
#' @details A characteristics annotation column is usually contains multiple
#' key-value items, so we should first split these columns by `split` and then
#' extract `key-value` pairs. A new column will be added whose name is the first
#' group in the "(ch\\d*)(\\.\\d*)?$" regex pattern of the orginal column name
#' connected with `key` element in `key-value` pair by string "_" and the new
#' column value is the character vector of `value` element in all `key-value`
#' pair. This function will modify `data` in place, So we don't have to assign
#' value.
#'
#' @return modified data invisibly
#'
#' @examples
#' gse53987 <- rgeo::get_geo(
#'     "gse53987", tempdir(),
#'     gse_matrix = TRUE, add_gpl = FALSE,
#'     pdata_from_soft = FALSE
#' )
#' gse53987_smp_info <- Biobase::pData(gse53987)
#' data.table::setDT(gse53987_smp_info)
#' gse53987_smp_info[, characteristics_ch1 := stringr::str_replace_all(
#'     characteristics_ch1,
#'     "gender|race|pmi|ph|rin|tissue|disease state",
#'     function(x) paste0("; ", x)
#' )]
#' rgeo::set_pdata(gse53987_smp_info)
#' gse53987_smp_info[
#'     , .SD,
#'     .SDcols = patterns("^ch1_|characteristics_ch1")
#' ]
#'
#' @export
set_pdata <- function(data, columns = NULL, sep = ":", split = "(\\s*+);(\\s*+)") {
    if (!data.table::is.data.table(data)) {
        rlang::abort(
            "`data` should be a data.table"
        )
    }
    if (!rlang::is_scalar_character(sep)) {
        rlang::abort(
            "`sep` should be a single string"
        )
    }
    if (!rlang::is_scalar_character(split)) {
        rlang::abort(
            "`split` should be a single string"
        )
    }
    rlang::try_fetch(
        parse_gse_matrix_sample_characteristics(
            sample_dt = data,
            characteristics_cols = columns,
            sep = sep,
            split = split
        ),
        warn_cannot_parse_characteristics = function(cnd) {
            rlang::abort(
                c(
                    paste0(
                        "There remains more than one \"", sep,
                        "\" characters after splitting `columns` by \"",
                        split, "\""
                    ),
                    "Please check if `sep` and `split` parameters can parse `columns`."
                ),
                parent = cnd
            )
        }
    )
    # As the modification in place of data.table will prevent print methods
    # A simple method is just use `[` function.
    invisible(data[])
}

# Lots of GSEs now use 'characteristics_ch1' and 'characteristics_ch2' for
# key-value pairs of annotation. If that is the case, this simply cleans those
# up and transforms the keys to column names and the values to column values.
# This function will modify `sample_dt` in place, So we needn't assign value.
# `sample_dt` should be a data.table
parse_gse_matrix_sample_characteristics <- function(sample_dt, characteristics_cols = NULL, sep = ":", split = "(\\s*+);(\\s*+)") {
    if (is.null(characteristics_cols)) {
        characteristics_cols <- grep(
            "^characteristics_ch",
            colnames(sample_dt),
            value = TRUE, perl = TRUE
        )
    } else {
        characteristics_cols <- grep(
            "ch\\d*(\\.\\d*)?$",
            characteristics_cols,
            value = TRUE, perl = TRUE
        )
    }
    if (length(characteristics_cols)) {
        for (.characteristic_col in characteristics_cols) {
            characteristic_list <- strsplit(
                sample_dt[[as.character(.characteristic_col)]],
                split = split, perl = TRUE
            )
            characteristic_list <- lapply(characteristic_list, function(x) {
                grep(sep, x, perl = TRUE, value = TRUE)
            })
            is_more_than_one_sep_chr <- vapply(
                characteristic_list,
                function(x) any(lengths(str_extract_all(x, sep)) > 1L),
                logical(1L)
            )
            if (any(is_more_than_one_sep_chr)) {
                rlang::warn(
                    c(
                        "Cannot parse characteristic column correctly",
                        paste0(
                            "Details see `", .characteristic_col,
                            "` column in `phenoData`"
                        )
                    ),
                    class = "warn_cannot_parse_characteristics"
                )
                rlang::warn(
                    "Please use `set_pdata` or `parse_pdata` function to convert it manually if necessary!"
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
}
