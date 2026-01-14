file_url_and_fname <- function(accession, famount, scope = "self",
                               ftp_over_https = TRUE) {
    rust_call(
        "geo_file_url_and_fname",
        accession, famount, scope, ftp_over_https
    )
}

#' Return a character vector of file paths
#' @noRd
download_url_directory <- function(accession, format, pattern = NULL,
                                   ftp_over_https = TRUE,
                                   handle_opts = list(), odir = getwd()) {
    url_list <- lapply(
        accession, list_directory_url,
        format = format, handle_opts = handle_opts,
        ftp_over_https = ftp_over_https
    )
    if (!is.null(pattern)) {
        url_list <- lapply(url_list, str_subset, pattern = pattern)
    }
    ofile_list <- lapply(url_list, function(urls) {
        # urls may be NULL or character(0L)
        if (length(urls) == 0L) return(NULL) # styler: off
        file.path(odir, basename(urls))
    })
    download_inform(
        unlist(url_list, recursive = FALSE, use.names = FALSE),
        unlist(ofile_list, recursive = FALSE, use.names = FALSE),
        handle_opts = handle_opts
    )
    ofile_list
}

list_directory_url <- function(accession, format, ftp_over_https,
                               handle_opts = list()) {
    url <- geo_url(accession, format = format, ftp_over_https = ftp_over_https)

    # connect to remote dir ---------------------------------
    handle_opts <- setup_handle_opts(handle_opts)
    handle_opts$dirlistonly <- TRUE
    handle_opts$noprogress <- TRUE
    handle_opts$multi_timeout <- NULL
    handle_opts$multiplex <- NULL
    curl_handle <- curl::new_handle()
    curl::handle_setopt(curl_handle, .list = handle_opts)
    url_connection <- tryCatch(
        curl::curl(url, "rb", handle = curl_handle),
        error = function(err) {
            cli::cli_abort(
                "Failed to open {.url {url}} for {.field {accession}}",
                parent = err
            )
        }
    )
    on.exit(close(url_connection))

    # find files --------------------------------------------
    if (is.null(ftp_over_https) || ftp_over_https) {
        # use HTTPS to connect GEO FTP site
        # See https://github.com/seandavi/GEOquery/blob/master/R/getGEOSuppFiles.R
        xml_doc <- xml2::read_html(url_connection)
        fnames <- xml2::xml_text(xml2::xml_find_all(xml_doc, "//a/@href"))
    } else {
        fnames <- readLines(url_connection)
    }
    fnames <- grep("^G", fnames, value = TRUE)

    # build urls for all found files ------------------------
    if (length(fnames)) {
        urls <- file.path(url, fnames)
    } else {
        urls <- NULL
        cli::cli_alert_warning(sprintf(
            "No {.field %s} file found for {.val %s}",
            format, accession
        ))
    }
    urls
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
            "Found {.val {sum(existed)}} file{?s} already downloaded"
        )
        urls <- urls[!existed]
        ofiles <- ofiles[!existed]
    }
    if (length(urls)) {
        cli::cli_inform("Downloading {.val {length(urls)}} file{?s}")
        handle_opts <- setup_handle_opts(handle_opts)
        if (is.null(handle_opts$noprogress)) {
            handle_opts$progress <- interactive()
        } else {
            handle_opts$progress <- !handle_opts$noprogress
        }
        handle_opts$multi_timeout <- handle_opts$multi_timeout %||% Inf
        status <- rlang::inject(curl::multi_download(
            urls = urls, destfiles = ofiles, resume = FALSE,
            !!!handle_opts
        ))
        # FTP: 200L, 206L, 416L, 226L
        # ADB: 200L, 206L, 416L
        success <- !is.na(status$success) & status$success &
            status$status_code == 200L
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

setup_handle_opts <- function(handle_opts) {
    handle_opts$httpheader <- handle_opts$httpheader %||%
        utils::getFromNamespace("format_request_headers", "curl")(
            list("User-Agent" = "geokit")
        )
    handle_opts$followlocation <- handle_opts$followlocation %||% TRUE
    handle_opts$connecttimeout <- handle_opts$connecttimeout %||% 60L
    # this is recommended by GEO FTP site
    # since we don't upload files, we just set buffersize only.
    handle_opts$buffersize <- handle_opts$buffersize %||% 33554432L
    handle_opts$upload_buffersize <- handle_opts$upload_buffersize %||%
        33554432L
    handle_opts$ftp_use_epsv <- handle_opts$ftp_use_epsv %||% TRUE
    handle_opts
}
