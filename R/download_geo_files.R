#' Return a character vector of file paths
#' @noRd
download_geo_suppl_or_gse_matrix_files <- function(ids, dest_dir, file_type, pattern = NULL, handle_opts = list(), ftp_over_https = FALSE, msg_id = sprintf("%s %s", substring(ids[1L], 1L, 3L), format_field(file_type))) {
    url_list <- lapply(ids, list_geo_file_url,
        file_type = file_type, handle_opts = handle_opts,
        ftp_over_https = ftp_over_https
    )
    if (!is.null(pattern)) {
        url_list <- lapply(url_list, grep,
            pattern = pattern,
            perl = TRUE, value = TRUE
        )
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
            msg_id = sprintf("%s annot", format_field("GPL"))
        )
        out <- download_status$destfiles
        if (any(!download_status$is_success)) {
            rlang::inform(
                sprintf(
                    "%s file in FTP site for %s is not available, so will use %s amount file from GEO Accession Site instead",
                    format_field("annot"),
                    oxford_comma(format_val(ids[!download_status$is_success])),
                    format_field(amount)
                )
                # nolint
            )
            out[!download_status$is_success] <- download_with_acc(
                ids = ids[!download_status$is_success], dest_dir = dest_dir,
                scope = "self", amount = amount, format = "text",
                handle_opts = handle_opts,
                msg_id = sprintf("%s %s amount", format_field("GPL"), amount)
            )
        }
    } else {
        download_status <- download_with_acc(
            ids = ids, dest_dir = dest_dir,
            scope = "self", amount = amount, format = "text",
            handle_opts = handle_opts,
            fail = FALSE,
            msg_id = sprintf("%s %s amount", format_field("GPL"), amount)
        )
        out <- download_status$destfiles
        if (any(!download_status$is_success)) {
            rlang::inform(
                sprintf(
                    "%s amount file in ACC site for %s is not available, so will use %s format from GEO FTP Site instead",
                    format_field(amount),
                    oxford_comma(format_val(ids[!download_status$is_success])),
                    format_field("soft")
                )
            )
            out[!download_status$is_success] <- download_with_ftp(
                ids = ids[!download_status$is_success], dest_dir = dest_dir,
                file_type = "soft",
                handle_opts = handle_opts,
                ftp_over_https = ftp_over_https,
                msg_id = sprintf("%s soft", format_field("GPL"))
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
        msg_id = sprintf("%s soft", format_field("GSE"))
    )
}

#' For GSM files, Only try ACC site
#' @noRd
download_gsm_files <- function(ids, dest_dir = getwd(), handle_opts = list()) {
    download_with_acc(
        ids = ids, dest_dir = dest_dir,
        scope = "self", amount = "full", format = "text",
        handle_opts = handle_opts,
        msg_id = sprintf("%s full amount", format_field("GSM"))
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
        msg_id = sprintf("%s soft", format_field("GDS"))
    )
}

#' Return a character vector, the length of it is the same with `ids`.
#' @noRd
download_with_ftp <- function(ids, dest_dir, file_type = "soft", handle_opts = list(), fail = TRUE, ftp_over_https = FALSE, msg_id = format_field(file_type)) {
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

download_with_acc <- function(ids, dest_dir, scope = "self", amount = "full", format = "text", handle_opts = list(), fail = TRUE, msg_id = sprintf("%s amount", format_field(amount))) {
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
            rlang::abort(
                sprintf(
                    "Cannot open %s for %s",
                    format_url(url), format_field(id)
                ),
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
    file_names <- grep("^G", file_names, perl = TRUE, value = TRUE)

    # build urls for all found files ------------------------
    if (length(file_names)) {
        file_urls <- file.path(url, file_names)
    } else {
        file_urls <- NULL
        rlang::warn(
            sprintf(
                "No %s file found for %s",
                format_field(file_type), format_val(id)
            )
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
        rlang::inform(
            sprintf(
                "Finding %s %s files already downloaded: %s",
                format_val(sum(is_existed)), msg_id,
                oxford_comma(format_file(basename(file_paths[is_existed])))
            )
        )
        urls <- urls[!is_existed]
        file_paths <- file_paths[!is_existed]
    }
    if (length(urls)) {
        rlang::inform(sprintf(
            "Downloading %s %s files from %s",
            format_val(length(urls)), msg_id,
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
                rlang::abort(c(
                    sprintf(
                        "Cannot download %s files",
                        format_val(n_failed_files)
                    ),
                    "i" = sprintf(
                        "failed url: %s",
                        oxford_comma(format_url(urls[!is_success]))
                    ),
                    "!" = sprintf(
                        "status code: %s",
                        oxford_comma(format_val(status$status_code[!is_success]))
                    ),
                    x = sprintf(
                        "error message: %s",
                        oxford_comma(format_val(status$error[!is_success]))
                    )
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
