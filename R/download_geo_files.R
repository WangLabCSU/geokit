#' Return a character vector of file paths
#' @noRd
download_geo_suppl_or_gse_matrix_files <- function(ids, dest_dir, file_type, pattern = NULL, handle_opts = list(), ftp_over_https = FALSE, msg_id = sprintf("{.strong %s} {.field %s}", substr(ids[1L], 1L, 3L), file_type)) {
    url_list <- lapply(ids, list_geo_file_url,
        file_type = file_type, handle_opts = handle_opts,
        ftp_over_https = ftp_over_https
    )
    if (!is.null(pattern)) {
        url_list <- lapply(url_list, str_subset, pattern = pattern)
    }
    file_path_list <- lapply(url_list, function(urls) {
        # urls may be NULL or character(0L)
        if (length(urls)) {
            file.path(dest_dir, basename(urls))
        } else {
            NULL
        }
    })
    download_inform(
        unlist(url_list, recursive = FALSE, use.names = FALSE),
        unlist(file_path_list, recursive = FALSE, use.names = FALSE),
        site = "ftp",
        handle_opts = handle_opts,
        ftp_over_https = ftp_over_https,
        msg_id = msg_id
    )
    file_path_list
}

#' For GPL data, if we only need datatable data, we firstly try to download
#' `annot` file in FTP site and then download "data" text file if it failed
#' If we need full amount of data, we try to download it in ACC site since file
#' in ACC site is much smaller than in FTP site.
#' @param amount "data" or "full"
#' @noRd
download_gpl_files <- function(ids, dest_dir = getwd(), amount = "data", handle_opts = list(), ftp_over_https = FALSE) {
    amount <- match.arg(amount, c("data", "full"))
    if (amount == "data") {
        download_status <- download_with_ftp(
            ids = ids, dest_dir = dest_dir,
            file_type = "annot",
            handle_opts = handle_opts,
            ftp_over_https = ftp_over_https,
            fail = FALSE,
            msg_id = "{.strong GPL} {.field annot}"
        )
        out <- download_status$destfiles
        if (any(!download_status$is_success)) {
            cli::cli_alert_info(
                "{.field annot} file in FTP site for {.val {ids[!download_status$is_success]}} is not available, so will use {.field {amount}} amount file from GEO Accession Site instead" # nolint
            )
            out[!download_status$is_success] <- download_with_acc(
                ids = ids[!download_status$is_success], dest_dir = dest_dir,
                scope = "self", amount = amount, format = "text",
                handle_opts = handle_opts,
                msg_id = sprintf("{.strong GPL} {.field %s} amount", amount)
            )
        }
    } else {
        download_status <- download_with_acc(
            ids = ids, dest_dir = dest_dir,
            scope = "self", amount = amount, format = "text",
            handle_opts = handle_opts,
            fail = FALSE,
            msg_id = sprintf("{.strong GPL} {.field %s} amount", amount)
        )
        out <- download_status$destfiles
        if (any(!download_status$is_success)) {
            cli::cli_alert_info(
                "{.field {amount}} amount file in ACC site for {.val {ids[!download_status$is_success]}} is not available, so will use {.field soft} format from GEO FTP Site instead" # nolint
            )
            out[!download_status$is_success] <- download_with_ftp(
                ids = ids[!download_status$is_success], dest_dir = dest_dir,
                file_type = "soft",
                handle_opts = handle_opts,
                ftp_over_https = ftp_over_https,
                msg_id = "{.strong GPL} {.field soft}"
            )
        }
    }
    out
}

#' For GSE files, try FTP site only, soft file in ACC site for GSE entitty is
#' not full of all records
#' @noRd
download_gse_soft_files <- function(ids, dest_dir = getwd(), handle_opts = list(), ftp_over_https = FALSE) {
    download_with_ftp(
        ids = ids, dest_dir = dest_dir,
        file_type = "soft",
        handle_opts = handle_opts,
        ftp_over_https = ftp_over_https,
        msg_id = "{.strong GSE} {.field soft}"
    )
}

#' For GSM files, Only try ACC site
#' @noRd
download_gsm_files <- function(ids, dest_dir = getwd(), handle_opts = list()) {
    download_with_acc(
        ids = ids, dest_dir = dest_dir,
        scope = "self", amount = "full", format = "text",
        handle_opts = handle_opts,
        msg_id = "{.strong GSM} {.field full} amount"
    )
}

#' For GDS files, Only try FTP site
#' @noRd
download_gds_files <- function(ids, dest_dir = getwd(), handle_opts = list(), ftp_over_https = FALSE) {
    download_with_ftp(
        ids = ids, dest_dir = dest_dir,
        file_type = "soft",
        handle_opts = handle_opts,
        ftp_over_https = ftp_over_https,
        msg_id = "{.strong GDS} {.field soft}"
    )
}

#' Return a character vector, the length of it is the same with `ids`.
#' @noRd
download_with_ftp <- function(ids, dest_dir, file_type = "soft", handle_opts = list(), fail = TRUE, ftp_over_https = FALSE, msg_id = sprintf("{.field %s}", file_type)) {
    urls <- build_geo_ftp_url(
        ids = ids, file_type = file_type,
        ftp_over_https = ftp_over_https
    )
    download_inform(urls,
        file.path(dest_dir, basename(urls)),
        site = "ftp",
        handle_opts = handle_opts,
        fail = fail,
        msg_id = msg_id,
        ftp_over_https = ftp_over_https
    )
}

download_with_acc <- function(ids, dest_dir, scope = "self", amount = "full", format = "text", handle_opts = list(), fail = TRUE, msg_id = sprintf("{.field %s} amount", amount)) {
    urls <- build_geo_acc_url(
        ids = ids, scope = scope, amount = amount, format = format
    )
    file_ext <- switch(format,
        text = "txt",
        xml = "xml",
        html = "html"
    )
    download_inform(urls,
        file.path(dest_dir, paste(ids, file_ext, sep = ".")),
        site = "acc",
        handle_opts = handle_opts,
        fail = fail,
        msg_id = msg_id
    )
}

list_geo_file_url <- function(id, file_type, handle_opts = list(), ftp_over_https) {
    url <- build_geo_ftp_url(
        ids = id, file_type = file_type,
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
        cli::cli_alert_warning(
            "No {.field {file_type}} file found for {.val {id}}"
        )
    }
    file_urls
}

#' Download utils function with good message.
#' @return If fail is `TRUE`, always return a character path if downloading
#'   successed, otherwise, stop with error message. If fail is `FALSE`, always
#'   return a list.
#' @noRd
download_inform <- function(urls, file_paths, site, msg_id = "", handle_opts = list(), fail = TRUE, ftp_over_https = FALSE) {
    out <- list(
        urls = urls, destfiles = file_paths,
        is_success = rep_len(TRUE, length(urls))
    )
    is_existed <- file.exists(file_paths)
    if (any(is_existed)) {
        cli::cli_inform(sprintf(
            "Finding {.val {sum(is_existed)}} %s file{?s} already downloaded: {.file {basename(file_paths[is_existed])}}", msg_id # nolint
        ))
        urls <- urls[!is_existed]
        file_paths <- file_paths[!is_existed]
    }
    if (length(urls)) {
        cli::cli_inform(sprintf(
            "Downloading {.val {length(urls)}} %s file{?s} from %s", msg_id,
            switch(site,
                ftp = "FTP site",
                acc = "GEO Accession Site"
            )
        ))
        if (site == "ftp" && !ftp_over_https) {
            handle_opts <- set_ftp_handle_opts(handle_opts)
            successful_code <- c(200L, 206L, 416L, 226L)
        } else {
            successful_code <- c(200L, 206L, 416L)
        }
        arg_list <- c(
            list(
                urls = urls, destfiles = file_paths, resume = FALSE,
                progress = interactive(), timeout = Inf
            ),
            handle_opts
        )
        status <- do.call(curl::multi_download, arg_list)
        is_success <- is_download_success(status, successful_code)
        is_need_deleted <- !is_success & file.exists(file_paths)
        if (any(is_need_deleted)) {
            file.remove(file_paths[is_need_deleted])
        }
        if (fail) {
            if (!all(is_success)) {
                n_failed_files <- sum(!is_success) # nolint
                cli::cli_abort(c(
                    "Cannot download {.val {n_failed_files}} file{?s}",
                    "i" = "url{?s}: {.url {urls[!is_success]}}",
                    "!" = "status {cli::qty(n_failed_files)} code{?s}: {.val {status$status_code[!is_success]}}",
                    x = "error {cli::qty(n_failed_files)} message{?s}: {.val {status$error[!is_success]}}"
                ))
            }
        } else {
            out$is_success[!is_existed] <- is_success
        }
    }
    if (fail) {
        out$destfiles
    } else {
        out
    }
}

# this is recommended by GEO FTP site
# since we don't upload files, we just set beffersize only.
set_ftp_handle_opts <- function(handle_opts) {
    if (is.null(handle_opts$buffersize)) {
        handle_opts$buffersize <- 33554432L
    }
    # if (is.null(handle_opts$upload_buffersize)) {
    #     handle_opts$upload_buffersize <- 33554432L
    # }
    handle_opts
}

#' @param status A data frame returned by [multi_download][curl::multi_download]
#' @noRd
is_download_success <- function(status, successful_code) {
    status$success & !is.na(status$success) &
        status$status_code %in% successful_code
}
