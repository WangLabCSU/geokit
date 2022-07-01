#' Return a character vector of file paths
#' @noRd
download_geo_suppl_or_gse_matrix_files <- function(id, dest_dir, file_type) {
    urls <- list_geo_file_url(id = id, file_type)
    file_paths <- file.path(dest_dir, basename(urls))
    download_inform(urls, file_paths, method = "ftp")
}

#' For GPL or GSE files, try FTP site first, if it failed, try ACC site
#' @noRd
download_gpl_or_gse_soft_file <- function(id, dest_dir = getwd()) {
    geo_type <- substr(id, 1L, 3L)
    rlang::try_fetch(
        download_with_ftp(
            id = id, dest_dir = dest_dir,
            file_type = switch(geo_type,
                GPL = "annot",
                GSE = "soft"
            )
        ),
        error = function(error) {
            rlang::inform(
                paste0("\nAnnotation file in FTP site for ", id, " is not available, so will use data format from GEO Accession Site instead.")
            )
            download_with_acc(
                id = id, dest_dir = dest_dir,
                scope = "self", amount = "full", format = "text"
            )
        }
    )
}

#' For GSM files, Only try ACC site
#' @noRd
download_gsm_file <- function(id, dest_dir = getwd()) {
    download_with_acc(
        id = id, dest_dir = dest_dir,
        scope = "self", amount = "full", format = "text"
    )
}

#' For GDS files, Only try FTP site
#' @noRd
download_gds_file <- function(id, dest_dir = getwd()) {
    download_with_ftp(
        id = id, dest_dir = dest_dir,
        file_type = "soft"
    )
}

#' Return a character vector, the length of it is the same with `ids`.
#' @noRd
download_with_ftp <- function(id, dest_dir, file_type = "soft") {
    url <- build_geo_ftp_url(id = id, file_type = file_type)
    download_inform(url,
        file.path(dest_dir, basename(url)),
        method = "ftp"
    )
}
download_with_acc <- function(id, dest_dir, scope = "self", amount = "data", format = "text") {
    url <- build_geo_acc_url(
        id = id, scope = scope, amount = amount, format = format
    )
    file_name <- switch(format,
        text = "txt",
        html = "html",
        xml = "xml"
    )
    download_inform(url,
        file.path(dest_dir, paste(id, file_name, sep = ".")),
        method = "acc"
    )
}

list_file_helper <- function(url) {
    xml_doc <- xml2::read_html(url)
    # file_names <- str_extract_all(
    #     xml2::xml_text(xml_doc),
    #     "G\\S++"
    # )
    # if (identical(length(file_names), 1L) && !length(file_names[[1L]])) {
    #     return(NULL)
    # }

    # use HTTPS to connect GEO FTP site
    # See https://github.com/seandavi/GEOquery/blob/master/R/getGEOSuppFiles.R
    file_names <- grep(
        "^G",
        xml2::xml_text(xml2::xml_find_all(
            xml_doc, "//a/@href"
        )),
        perl = TRUE, value = TRUE
    )
    if (!length(file_names)) {
        return(NULL)
    }
    file.path(url, file_names)
}
list_geo_file_url <- function(id, file_type) {
    url <- build_geo_ftp_url(id, file_type)
    file_urls <- list_file_helper(url)
    if (is.null(file_urls)) {
        rlang::inform(
            paste0("No ", file_type, " file found for ", id, ".")
        )
    }
    file_urls
}

#' Download utils function with good message.
#' @noRd
download_inform <- function(urls, file_paths, method = "ftp") {
    mapply(
        function(url, file_path) {
            if (!file.exists(file_path)) {
                rlang::inform(
                    paste0(
                        "Downloading ",
                        basename(file_path),
                        " from ",
                        switch(method,
                            ftp = "FTP site",
                            acc = "GEO Accession Site"
                        ),
                        ":"
                    )
                )
                h <- curl::new_handle()
                # For we use HTTPs to link GEO FTP site,
                # No need to follow GEO FTP buffersie recommendations
                # if (identical(method, "ftp")) {
                #     curl::handle_setopt(
                #         h,
                #         buffersize = 33554432L,
                #         upload_buffersize = 33554432L
                #     )
                # }
                curl::handle_setopt(h, timeout_ms = 120L * 1000L)
                file_path <- curl::curl_download(
                    url, file_path,
                    mode = switch(method,
                        ftp = "wb",
                        acc = "w"
                    ),
                    quiet = FALSE,
                    handle = h
                )
                cat("\n")
                file_path
            } else {
                rlang::inform(
                    paste0(
                        "Using locally cached version of ",
                        basename(file_path),
                        " found here: ",
                        file_path
                    )
                )
                file_path
            }
        }, urls, file_paths,
        SIMPLIFY = TRUE, USE.NAMES = FALSE
    )
}
