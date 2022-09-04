#' Return a character vector of file paths
#' @noRd
download_geo_suppl_or_gse_matrix_files <- function(id, dest_dir, file_type, pattern = NULL) {
    urls <- list_geo_file_url(id = id, file_type)
    if (!is.null(pattern)) {
        urls <- urls[grepl(pattern = pattern, x = basename(urls), perl = TRUE)]
        if (!length(urls)) return(NULL)
    }
    file_paths <- file.path(dest_dir, basename(urls))
    download_inform(urls, file_paths, site = "ftp", mode = "wb")
}

#' For GPL data, if we only need datatable data, we firstly try to download
#' `annot` file in FTP site and then download "data" text file if it failed
#' If we need full amount of data, we try to download it in ACC site since file
#' in ACC site is much smaller than in FTP site.
#' @param amount "data" or "full"
#' @noRd
download_gpl_file <- function(id, dest_dir = getwd(), amount = "data") {
    amount <- match.arg(amount, c("data", "full"))
    switch(amount,
        data = rlang::try_fetch(
            download_with_ftp(
                id = id, dest_dir = dest_dir,
                file_type = "annot"
            ),
            error = function(error) {
                rlang::inform(
                    paste0(
                        "\nannot file in FTP site for ", id,
                        " is not available, so will use data amount of SOFT file from GEO Accession Site instead."
                    )
                )
                download_with_acc(
                    id = id, dest_dir = dest_dir,
                    scope = "self", amount = amount, format = "text"
                )
            }
        ),
        full = rlang::try_fetch(
            download_with_acc(
                id = id, dest_dir = dest_dir,
                scope = "self", amount = amount, format = "text"
            ),
            error = function(error) {
                rlang::inform(
                    paste0(
                        "\nfull amount of SOFT file in ACC site for ", id,
                        " is not available, so will use soft format from GEO FTP Site instead."
                    )
                )
                download_with_ftp(
                    id = id, dest_dir = dest_dir,
                    file_type = "soft"
                )
            }
        )
    )
}

#' For GSE files, try FTP site only, soft file in ACC site for GSE entitty is
#' not full of all records
#' @noRd
download_gse_soft_file <- function(id, dest_dir = getwd()) {
    download_with_ftp(
        id = id, dest_dir = dest_dir,
        file_type = "soft"
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
        site = "ftp", mode = "wb"
    )
}
download_with_acc <- function(id, dest_dir, scope = "self", amount = "full", format = "text") {
    url <- build_geo_acc_url(
        id = id, scope = scope, amount = amount, format = format
    )
    file_name <- switch(format,
        text = "txt",
        xml = "xml",
        html = "html"
    )
    download_inform(url,
        file.path(dest_dir, paste(id, file_name, sep = ".")),
        site = "acc", mode = "w"
    )
}

list_file_helper <- function(url) {
    url_connection <- curl::curl(
        url,
        handle = geo_handle()
    )
    open(url_connection, "rb")
    on.exit(close(url_connection))

    xml_doc <- xml2::read_html(url_connection)
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
download_inform <- function(urls, file_paths, site, mode) {
    mapply(
        function(url, file_path) {
            if (!file.exists(file_path)) {
                rlang::inform(
                    paste0(
                        "Downloading ",
                        basename(file_path),
                        " from ",
                        switch(site,
                            ftp = "FTP site",
                            acc = "GEO Accession Site"
                        ),
                        ":"
                    )
                )
                # h <- curl::new_handle()
                # For we use HTTPs to link GEO FTP site,
                # No need to follow GEO FTP buffersie recommendations
                # if (identical(method, "ftp")) {
                #     curl::handle_setopt(
                #         h,
                #         buffersize = 33554432L,
                #         upload_buffersize = 33554432L
                #     )
                # }
                # curl::handle_setopt(h, timeout = 120L, connecttimeout = 60)
                file_path <- curl::curl_download(
                    url, file_path,
                    mode = mode, quiet = FALSE,
                    handle = geo_handle()
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

geo_handle <- function() {
    curl::new_handle(
        timeout = 120L, connecttimeout = 60L
    )
}
