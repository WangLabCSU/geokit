#' Parse key-value pairs
#' 
#' Lots of GSEs now use `"characteristics_ch*"` for key-value pairs of
#' annotation.  If that is the case, this simply cleans those up and transforms
#' the keys to column names and the values to column values. This function is
#' just like `set*` function in `data.table`, it will modify `data` in place, So
#' we don't have to assign value. `data` should be a data.table. 
#' 
#' @param data a data.table, this function will modify `data` in place.
#' @param columns a character vector, these columns in `data` will be parsed. If
#' `NULL`, all columns started with `"characteristics_ch"` will be used.
#' @param con the connection string which paired key-value, usually `":"`.
#' @param split Just like the `split` parameter in [strsplit][base::strsplit].
#' Default is `"(\\s*+);(\\s*+)"`.
#' 
#' @details A characteristics annotation column is usually contains multiple
#' key-value items, so we should first split these columns by `split` and then
#' extract `key-value` pairs. A new column will be added whose name is the `key`
#' and value is the character vector `value` in `key-value` pair. This function
#' will modify `data` in place, So we needn't assign value.
#' 
#' @return modified data invisibly
#' 
#' @examples 
#'  gse53987 <- rgeo::get_geo(
#'      "gse53987", tempdir(),
#'      gse_matrix = TRUE, add_gpl = FALSE
#'  )
#'  gse53987_smp_info <- Biobase::pData(gse53987)
#'  data.table::setDT(gse53987_smp_info)
#'  gse53987_smp_info[, characteristics_ch1 := stringr::str_replace_all(
#'      characteristics_ch1,
#'      "gender|race|pmi|ph|rin|tissue|disease state",
#'      function(x) paste0("; ", x)
#'  )]
#'  rgeo::set_char(gse53987_smp_info)
#' 
#' @export 
set_char <- function(data, columns = NULL, con = ":", split = "(\\s*+);(\\s*+)") {
    if (!data.table::is.data.table(data)) rlang::abort(
        "`data` should be a data.table"
    )
    if (!rlang::is_scalar_character(con)) rlang::abort(
        "`con` should be a single string"
    )
    if (!rlang::is_scalar_character(split)) rlang::abort(
        "`split` should be a single string"
    )
    rlang::try_fetch(
        parse_gse_matrix_sample_characteristics(
             sample_dt = data,
             characteristics_cols = columns,
             con = con,
             split = split
        ),
        warn_cannot_parse_characteristics = function(cnd) {
            rlang::abort(
                c(
                    "Cannot parse characteristic column correctly", 
                    paste0("There remains more than one `", con,
                    "` characters after splitting `columns` by `", 
                    split, "`"),
                    "Please check if `con` and `split` parameters can parse `columns`."
                )
            )
        }
    )
    invisible(data)
}

# Lots of GSEs now use 'characteristics_ch1' and 'characteristics_ch2' for
# key-value pairs of annotation. If that is the case, this simply cleans those
# up and transforms the keys to column names and the values to column values.
# This function will modify `sample_dt` in place, So we needn't assign value.
# `sample_dt` should be a data.table
parse_gse_matrix_sample_characteristics <- function(sample_dt, characteristics_cols = NULL, con = ":", split = "(\\s*+);(\\s*+)") {
    if (is.null(characteristics_cols)) {
        characteristics_cols <- grep(
            "^characteristics_ch",
            colnames(sample_dt),
            value = TRUE, perl = TRUE
        )
    }
    if (length(characteristics_cols)) {
        for (.characteristic_col in characteristics_cols) {
            characteristic_dt <- sample_dt[
                , data.table::tstrsplit(
                    as.character(.characteristic_col),
                    split = split,
                    perl = TRUE, fill = NA_character_
                ),
                env = list(
                    .characteristic_col = .characteristic_col
                )
            ][, .SD, .SDcols = function(x) {
                any(grepl(con, x, perl = TRUE, fixed = FALSE))
            }]
            if (ncol(characteristic_dt)) {
                is_more_than_one_connection_chr <- vapply(
                    characteristic_dt,
                    function(x) any(lengths(str_extract_all(x, con)) > 1L),
                    logical(1L)
                )
                if (any(is_more_than_one_connection_chr)) {
                    rlang::warn(
                        c(
                            "Cannot parse characteristic column correctly", "Please use `set_char` function to convert it manually if necessary!",
                            paste0(
                                "Details see `", .characteristic_col,
                                "` column in `phenoData`"
                            )
                        ),
                        class = "warn_cannot_parse_characteristics"
                    )
                    next
                }
                lapply(characteristic_dt, function(x) {
                    # the first element contain the name of this key-value pair
                    # And the second is the value of the key-value pair
                    .characteristic_list <- data.table::transpose(
                        str_split(x, paste0("(\\s*+)", con, "(\\s*+)"))
                    )
                    .characteristic_name <- unique(.characteristic_list[[1L]])
                    .characteristic_name <- paste0(
                        # Since the names of these columns starting by "chr",
                        # we should extract the second "ch\\d?+"
                        str_extract_all(
                            .characteristic_col, "ch\\d?+"
                        )[[1L]][[2L]], "_",
                        # Omit NA value and only extract the first element
                        .characteristic_name[
                            !is.na(.characteristic_name)
                        ][[1L]]
                    )
                    # Add this key-value pair to original data.table
                    sample_dt[
                        ,
                        (.characteristic_name) := .characteristic_list[[2L]]
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
