#' Parse key-value pairs in the metadata of GEO Sample SOFT file
#'
#' Lots of GSEs now use `"characteristics_ch*"` meta header data for key-value
#' pairs of annotation. If that is the case, this simply cleans the **GEOSoft**
#' `@@metadata` slot up and transforms the keys to column names and the values
#' to column values.
#'
#' @param x A [GEOSeries][GEOSeries-class] object, a list of
#' [GEOSoft][GEOSoft-class] from the `@@gsm` slot of a `GEOSeries` object, or a
#' data frame from Series matrix file data table.
#' @param ... Additional arguments passed on to methods.
#' @param fields A character vector which fields should be parsed.
#' @param sep A single byte string defined the pairing separator.
#' @return A data.frame whose rows are samples and columns are the sample infos
#' @examples
#' gse201530_soft <- geo_soft("GSE201530", odir = tempdir())
#' parse_sample_data(gse201530_soft)
#' @export
parse_sample_data <- function(x, ...) {
    UseMethod("parse_sample_data")
}

#' @export
#' @rdname parse_sample_data
parse_sample_data.GEOSeries <- function(x, ...) {
    parse_sample_data.list(gsm(x), ...)
}

#' @export
#' @rdname parse_sample_data
parse_sample_data.data.frame <- function(x, ..., fields = NULL, sep = ":") {
    # parse the characteristics
    if (is.null(fields)) {
        # We select columns with names starting with "characteristics_ch" and at
        # least 50% of the elements in the column contains character ":",
        # For GEO use ":" string to separate Key-value pairs.
        cols <- startsWith(colnames(x), "characteristics_ch")
        column_with_sep <- vapply(which(cols), function(col) {
            list_col <- .subset2(x, col)
            have_sep <- vapply(list_col, function(x) {
                all(grepl(sep, x, fixed = TRUE), na.rm = TRUE)
            }, logical(1L), USE.NAMES = FALSE)
            mean(have_sep, na.rm = TRUE) >= 0.5
        }, logical(1L), USE.NAMES = FALSE)
        fields <- colnames(x)[cols[column_with_sep]]
    }
    if (length(fields) == 0L) {
        return(set_rownames(x, "geo_accession"))
    }
    characteristics <- parse_characteristics(x, fields, sep = sep)
    for (characteristic_col in names(characteristics)) {
        characteristic_data <- .subset2(characteristics, characteristic_col)
        point <- which(colnames(x) == characteristic_col)
        ordered_cols <- c(
            colnames(x)[seq_len(point)],
            colnames(characteristic_data),
            colnames(x)[-seq_len(point)]
        )
        x <- cbind(x, characteristic_data)[, ordered_cols, drop = FALSE]
    }
    set_rownames(x, "geo_accession")
}

#' @export
#' @rdname parse_sample_data
parse_sample_data.list <- function(x, ...) {
    test_gsm_list <- is.list(x) && all(vapply(
        x, function(x) {
            methods::is(x, "GEOSoft") &&
                all(startsWith(names(metadata(x)), "Sample_"))
        },
        logical(1L),
        USE.NAMES = FALSE
    ))
    if (!test_gsm_list) {
        cli::cli_abort(paste(
            "{.arg x} must be a list of {.cls GEOSoft} object,",
            "especially for {.field @gsm} slot in a GEOSeries object."
        ))
    }
    metadata <- lapply(x, function(data) {
        meta_data <- metadata(data)
        if (any(lengths(meta_data) > 1L)) {
            meta_data[lengths(meta_data) > 1L] <- lapply(
                meta_data[lengths(meta_data) > 1L], list
            )
        }
        data.table::setDT(meta_data)
    })
    metadata <- data.table::rbindlist(
        metadata,
        use.names = TRUE, fill = TRUE, idcol = FALSE
    )
    data.table::setnames(metadata, function(x) sub("^Sample_", "", x))
    data.table::setDF(metadata)
    parse_sample_data.data.frame(metadata, ...)
}

parse_characteristics <- function(data, characteristic_cols, sep = ":") {
    any_more_than_one_seps <- vapply(characteristic_cols, function(col) {
        list_col <- .subset2(data, col)
        # for a column with characteristics
        # we check if any elements have more than one ":"
        have_more_than_one_seps <- vapply(
            list_col, function(x) {
                any(lengths(str_extract_all(x, sep)) > 1L)
            }, logical(1L),
            USE.NAMES = FALSE
        )
        any(have_more_than_one_seps)
    }, logical(1L), USE.NAMES = FALSE)

    if (any(any_more_than_one_seps)) {
        # column names with more than one ":"
        warn_names <- characteristic_cols[any_more_than_one_seps] # nolint
        cli::cli_warn(c(
            sprintf("Multiple occurrences of {.val %s} found in metadata characteristics", sep),
            i = "See column{?s} {.val {warn_names}} for details."
        ))
    }
    characteristics <- lapply(characteristic_cols, function(col) {
        data <- parse_key_value_elements(.subset2(data, col), sep = ":")
        if (nrow(data) && ncol(data)) {
            # we extract the last "ch\\d*" pattern as the column
            # name, which is the first group defined by parentheses.
            # This is just the second column of `str_match`.
            # Sometimes there may be a "\\.\\d*" tail
            new_names <- paste0(
                str_match(col, "(ch\\d*)(\\.\\d*)?(_\\d*)?$")[
                    , 2L,
                    drop = TRUE
                ],
                "_",
                colnames(data)
            )
            colnames(data) <- new_names
            data
        } else {
            NULL
        }
    })
    names(characteristics) <- characteristic_cols
    characteristics <- characteristics[
        !vapply(characteristics, is.null, logical(1L), USE.NAMES = FALSE)
    ]
    characteristics
}
