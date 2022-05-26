#' Return a character vector of file paths
#' @noRd
download_geo_suppl_or_gse_matrix_files <- function(id, dest_dir, file_type) {
    urls <- list_geo_file_url(id = id, file_type)
    file_paths <- file.path(dest_dir, basename(urls))
    download_inform(urls, file_paths, method = "ftp")
}

#' For GPL files, try FTP site first, if it failed, try ACC site
#' @noRd
download_gpl_file <- function(id, dest_dir = getwd()) {
    rlang::try_fetch(
        download_with_ftp(
            id = id, dest_dir = dest_dir,
            file_type = "annot"
        ),
        error = function(error) {
            rlang::inform(
                paste0("Annotation file in FTP site for ", id, " is not available, so will use data table from GEO Accession Display Bar instead.")
            )
            download_with_acc(
                id = id, dest_dir = dest_dir,
                scope = "self", amount = "data", format = "text"
            )
        }
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

#' @importFrom xml2 read_html xml_text xml_find_all
list_file_helper <- function(url) {
    xml_doc <- xml2::read_html(url)
    # file_name <- str_extract_all(
    #     xml2::xml_text(xml_doc),
    #     "G\\S++"
    # )
    # if (identical(length(file_name), 1L) && !length(file_name[[1L]])) {
    #     return(NULL)
    # }

    # use HTTPS to connect GEO FTP site
    # See https://github.com/seandavi/GEOquery/blob/master/R/getGEOSuppFiles.R
    file_name <- grep(
        "^G",
        xml2::xml_text(xml2::xml_find_all(
            xml_doc, "//a/@href"
        )),
        perl = TRUE, value = TRUE
    )
    if (!length(file_name)) {
        return(NULL)
    }
    file.path(url, file_name)
}
list_geo_file_url <- function(id, file_type) {
    url <- build_geo_ftp_url(id, file_type)
    res <- list_file_helper(url)
    if (is.null(res)) {
        rlang::inform(
            paste0("No ", file_type, " file found for ", id, ".")
        )
    }
    res
}

#' Download utils function with good message.
#' @importFrom curl curl_download new_handle handle_setopt
#' @noRd
download_inform <- function(urls, file_paths, method = "ftp") {
    mapply(
        function(url, file_path) {
            if (!file.exists(file_path)) {
                if (!dir.exists(dirname(file_path))) {
                    dir.create(dirname(file_path), recursive = TRUE)
                }
                rlang::inform(paste0("Downloading ", basename(url), ":"))
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
                curl::curl_download(
                    url, file_path,
                    mode = switch(method,
                        ftp = "wb",
                        acc = "w"
                    ),
                    quiet = FALSE,
                    handle = h
                )
            } else {
                rlang::inform(
                    paste0(
                        "Using locally cached version of ", basename(url),
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
