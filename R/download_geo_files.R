#' Return a character vector, the length of it is the same with `ids`.
#' @noRd
download_geo_file <- function(id, dest_dir, file_type) {
    file_type <- match.arg(
        tolower(file_type),
        c("soft", "soft_full", "annot", "miniml")
    )
    url <- build_geo_ftp_url(id = id, file_type = file_type)
    file_path <- file.path(dest_dir, basename(url))
    download_inform(url, file_path)
}

#' Return a list of file paths for each ids.
#' @noRd
download_geo_suppl_files_or_gse_matrix <- function(id, dest_dir, file_type) {
    file_type <- match.arg(
        tolower(file_type),
        c("suppl", "matrix")
    )
    urls <- list_geo_file_url(id = id, file_type)
    file_paths <- file.path(dest_dir, basename(urls))
    download_inform(urls, file_paths)
}

download_geo_suppl_files <- function(id, dest_dir) {
    download_geo_suppl_files_or_gse_matrix(id, dest_dir, file_type = "suppl")
}

download_geo_gse_matrix <- function(id, dest_dir) {
    download_geo_suppl_files_or_gse_matrix(id, dest_dir, file_type = "matrix")
}

#' Download utils function with good message.
#' @importFrom curl curl_download
#' @noRd
download_inform <- function(urls, file_paths) {
    .mapply(
        function(url, file_path) {
            if (!file.exists(file_path)) {
                rlang::inform(paste0("Downloading ", basename(url), ":"))
                curl::curl_download(
                    url, file_path,
                    mode = "wb", quiet = FALSE
                )
                # if (res) {
                #     if (file.exists(file_path)) {
                #         file.remove(file_path)
                #     }
                #     rlang::abort(c(
                #         paste0("Download failed for file ", basename(url), "."),
                #         paste0("Check URL(", url, ") manually if in doubt")
                #     ))
                # }
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
        }, list(urls, file_paths), NULL
    )
    invisible(file_paths)
}
