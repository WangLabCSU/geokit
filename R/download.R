#' Return a character vector of file paths
#' @noRd
download_suppl_or_gse_matrix_files <- function(ids, odir, formats,
                                               pattern = NULL,
                                               handle_opts = list(),
                                               ftp_over_https = TRUE,
                                               file_label = NULL) {
    url_list <- lapply(
        ids, list_geo_file_url,
        formats = formats, handle_opts = handle_opts,
        ftp_over_https = ftp_over_https
    )
    if (!is.null(pattern)) {
        url_list <- lapply(url_list, str_subset, pattern = pattern)
    }
    file_path_list <- lapply(url_list, function(urls) {
        # urls may be NULL or character(0L)
        if (length(urls)) {
            file.path(odir, basename(urls))
        } else {
            NULL
        }
    })
    file_label <- file_label %||%
        sprintf("{.strong %s} {.field %s}", geo_gtype(ids[1L]), formats)
    download_inform(
        unlist(url_list, recursive = FALSE, use.names = FALSE),
        unlist(file_path_list, recursive = FALSE, use.names = FALSE),
        handle_opts = handle_opts,
        file_label = file_label,
        site_label = "ftp",
        ftp = !isTRUE(ftp_over_https)
    )
    file_path_list
}

list_geo_file_url <- function(accession, formats, handle_opts = list(),
                              ftp_over_https) {
    url <- geo_url(
        accession = accession, format = formats,
        ftp_over_https = ftp_over_https
    )

    # connect to remote dir ---------------------------------
    if (!ftp_over_https) {
        handle_opts <- set_ftp_handle_opts(handle_opts)
        handle_opts$ftp_use_epsv <- TRUE
        handle_opts$dirlistonly <- TRUE
    }
    handle_opts$noprogress <- TRUE
    curl_handle <- curl::new_handle()
    curl::handle_setopt(curl_handle, .list = handle_opts)
    url_connection <- tryCatch(
        curl::curl(url, "rb", handle = curl_handle),
        error = function(err) {
            cli::cli_abort("Cannot open {.url {url}} for {.field {id}}",
                parent = err
            )
        }
    )
    on.exit(close(url_connection))

    # find files --------------------------------------------
    if (ftp_over_https) {
        # use HTTPS to connect GEO FTP site
        # See https://github.com/seandavi/GEOquery/blob/master/R/getGEOSuppFiles.R
        xml_doc <- xml2::read_html(url_connection)
        file_names <- xml2::xml_text(xml2::xml_find_all(xml_doc, "//a/@href"))
    } else {
        file_names <- readLines(url_connection)
    }
    file_names <- str_subset(file_names, "^G")

    # build urls for all found files ------------------------
    if (length(file_names)) {
        file_urls <- file.path(url, file_names)
    } else {
        file_urls <- NULL
        cli::cli_alert_warning("No {.field {formats}} file found for {.val {id}}")
    }
    file_urls
}

#' For GSM files, Only try ACC site
#' @noRd
download_gsm <- function(accession, scope = "self", amount = "data",
                         handle_opts = list(), odir = getwd(),
                         file_label = NULL) {
    file_label <- file_label %||%
        sprintf("{.strong GSM} {.field %s} amount", amount)
    download_with_acc(
        accession,
        scope = scope, amount = amount, format = "text",
        handle_opts = handle_opts, odir = odir,
        file_label = file_label
    )
}

#' Return a character vector, the length of it is the same with `ids`.
#' @noRd
download_with_ftp <- function(accession, format = "soft",
                              ftp_over_https = TRUE,
                              handle_opts = list(), odir = getwd(),
                              file_label = NULL, fail = TRUE) {
    file_label <- file_label %||% sprintf("{.field %s}", format)
    urls <- geo_url(
        accession = accession, format = format,
        ftp_over_https = ftp_over_https
    )
    download_inform(
        urls,
        file.path(odir, basename(urls)),
        handle_opts = handle_opts,
        fail = fail,
        file_label = file_label,
        site_label = "ftp",
        ftp = !isTRUE(ftp_over_https)
    )
}

download_with_acc <- function(accession, scope = "self", amount = "full",
                              format = "text", handle_opts = list(),
                              odir = getwd(), fail = TRUE,
                              file_label = NULL) {
    file_label <- file_label %||% sprintf("{.field %s} amount", amount)
    urls <- geo_url(
        accession = accession, format = format,
        scope = scope, amount = amount
    )
    fileext <- switch(format,
        text = "txt",
        xml = "xml",
        html = "html"
    )
    download_inform(
        urls,
        file.path(
            odir,
            paste(paste(accession, amount, sep = "_"), fileext, sep = ".")
        ),
        handle_opts = handle_opts,
        fail = fail,
        file_label = file_label,
        site_label = "acc",
        ftp = FALSE
    )
}

#' Download utils function with good message.
#' @return If fail is `TRUE`, always return a character path if downloading
#'   succeed, otherwise, stop with error message. If fail is `FALSE`, always
#'   return a list.
#' @noRd
download_inform <- function(urls, ofiles, handle_opts, error = TRUE) {
    out <- list(
        urls = urls, paths = ofiles,
        success = rep_len(TRUE, length(urls))
    )
    existed <- file.exists(ofiles)
    if (any(existed)) {
        cli::cli_inform(
            "Finding {.val {sum(existed)}} file{?s} already downloaded"
        )
        urls <- urls[!existed]
        ofiles <- ofiles[!existed]
    }
    if (length(urls)) {
        cli::cli_inform("Downloading {.val {length(urls)}} file{?s}")
        handle_opts$progress <- handle_opts$progress %||% interactive()
        handle_opts$multi_timeout <- handle_opts$multi_timeout %||% Inf
        handle_opts <- setup_handle(handle_opts)
        status <- rlang::inject(curl::multi_download(
            urls = urls, destfiles = ofiles, resume = FALSE,
            !!!handle_opts
        ))
        success <- !is.na(status$success) & status$success
        removed <- !success & file.exists(ofiles)
        if (any(removed)) file.remove(ofiles[removed])
        if (!all(success) && error) {
            n_failed_files <- sum(!success) # nolint
            cli::cli_abort(c(
                "Failed to download {.val {n_failed_files}} file{?s}",
                "i" = "url{?s}: {.url {urls[!success]}}",
                "!" = "status {cli::qty(n_failed_files)} code{?s}: {.val {status$status_code[!success]}}",
                x = "error {cli::qty(n_failed_files)} message{?s}: {.val {status$error[!success]}}"
            ))
        }
        out$success[!existed] <- success
    }
    out
}

setup_handle <- function(handle_opts) {
    handle_opts$connecttimeout <- handle_opts$connecttimeout %||% 60L
    # this is recommended by GEO FTP site
    # since we don't upload files, we just set buffersize only.
    handle_opts$buffersize <- handle_opts$buffersize %||% 33554432L
    handle_opts$upload_buffersize <- handle_opts$upload_buffersize %||%
        33554432L
    handle_opts
}
