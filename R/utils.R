`%||%` <- function(x, y) if (is.null(x)) y else x

is_all_same <- function(x) rust_call("is_all_same", x)

parse_soft_rust <- function(path, format = "standard",
                            reuse_buffer = FALSE, pprof_file = NULL) {
    if (is.null(pprof_file)) {
        rust_call("geo_parse_soft", path, format, reuse_buffer)
    } else {
        # Require add feature: pprof
        rust_call(
            "pprof_geo_parse_soft",
            path,
            format,
            reuse_buffer,
            pprof_file
        )
    }
}

# parse key-value pairs separeted by ":". For a list of key-value pairs
# characters (like: `list(c("a:1", "b:2"), c("a:3", "b:4"))`), this function
# simply cleans those up and transforms the list into a data frame, the names of
# returned value is the unique keys in the pairs, the element of the returned
# list is the values in the paris.
# See: `parse_key_value_elements(list(c("a:1", "b:2"), c("a:3", "b:4")))`
parse_key_value_elements <- function(elements, sep = ":", arg = caller_arg(sep),
                                     call = caller_env()) {
    separator <- charToRaw(sep)
    if (length(separator) != 1L) {
        cli::cli_abort("{.arg {arg}} must be a single byte string", call = call)
    }
    out <- rust_call(
        "parse_key_value_elements",
        as.list(elements), as.integer(separator)
    )
    quickdf(out)
}

return_object_or_list <- function(x, names = NULL) {
    if (length(x) == 1L) {
        .subset2(x, 1L)
    } else {
        if (!is.null(names)) names(x) <- names
        x
    }
}

read_internal <- function(file = NULL) {
    if (is.null(file)) {
        dir(pkg_extdata())
    } else {
        readRDS(pkg_extdata(file, mustWork = TRUE))
    }
}

set_rownames <- function(x, var = 1L) {
    if (nrow(x)) {
        data.table::setDF(x, rownames = as.character(x[[var]]))
    } else {
        data.table::setDF(x)
    }
}

column_to_rownames <- function(x, var = 1L) {
    data.table::setDF(x[, .SD, .SDcols = !var], # nolint
        rownames = as.character(x[[var]])
    )
}

dir_create <- function(path, ...) {
    if (!dir.exists(path) &&
        !dir.create(path = path, showWarnings = FALSE, ...)) {
        cli::cli_abort("Cannot create directory {.path {path}}")
    }
    invisible(path)
}

check_bioc_installed <- function(pkg, reason = NULL, ...) {
    rlang::check_installed(
        pkg,
        reason = reason,
        ...,
        action = function(pkgs, ...) {
            if (is_installed("pak")) {
                getExportedValue("pak", "pkg_install")(pkgs, ask = FALSE, ...)
            } else if (is_installed("BiocManager")) {
                getExportedValue("BiocManager", "install")(pkgs, ...)
            } else {
                choosed <- utils::menu(
                    c("pak", "BiocManager"),
                    title = paste(
                        "Would you like to install `pak`/`BiocManager`",
                        "in order to install", oxford_and(pkgs)
                    )
                )
                if (choosed == 1L) {
                    utils::install.packages("pak")
                    getExportedValue("pak", "pkg_install")(
                        pkgs, ask = FALSE, ...
                    )
                } else if (choosed == 2L) {
                    utils::install.packages("BiocManager")
                    getExportedValue("BiocManager", "install")(pkgs, ...)
                } else {
                    invokeRestart("abort")
                }
            }
        }
    )
}

#' @importFrom rlang caller_arg caller_env
assert_accession <- function(accession, arg = caller_arg(accession),
                             call = caller_env()) {
    if (!is_all_same(geo_gtype(accession))) {
        cli::cli_abort(
            "All {.arg {arg}} values must have the same GEO type.",
            call = call
        )
    }
}

wrap_cat <- function(label, names, indent = 0L, exdent = 2L) {
    label <- sprintf("%s:", label)
    total <- length(names)

    ext <- if (total == 0L) {
        "none"
    } else if (total <= 6L) {
        paste(names, collapse = " ")
    } else {
        paste(
            paste(names[1:3], collapse = " "),
            "...",
            paste(names[(total - 1L):total], collapse = " "),
            sprintf("(%d total)", total),
            sep = " "
        )
    }
    cat(strwrap(
        paste(label, ext, sep = " "),
        indent = indent, exdent = exdent
    ), sep = "\n")
}

RUST_CALL <- .Call

#' @keywords internal
rust_method <- function(class, method, ...) {
    rust_call(sprintf("%s__%s", class, method), ...)
}

#' @keywords internal
rust_call <- function(.NAME, ..., call = caller_env()) {
    # call the function
    out <- RUST_CALL(sprintf("wrap__%s", .NAME), ...)

    # propagate error from rust --------------------
    if (!inherits(out, "extendr_result")) return(out) # styler: off
    if (!is.null(err <- .subset2(out, "err"))) {
        rlang::abort(err, call = call)
    }
    .subset2(out, "ok")
}
