#' Return a character vector, the length of it is the same with `ids`.
#' @noRd
download_geo_file <- function(id, dest_dir, method, file_type, scope, amount, format) {
    url <- switch(match.arg(tolower(method), "ftp", "acc"),
        ftp = build_geo_ftp_url(id = id, file_type = file_type),
        acc = build_geo_acc_url(
            id = id, scope = scope, amount = amount, format = format
        )
    )
    file_path <- file.path(dest_dir, basename(url))
    download_inform(url, file_path, method = method)
}

#' Return a list of file paths for each ids.
#' @noRd
download_geo_suppl_files_or_gse_matrix <- function(id, dest_dir, file_type) {
    urls <- list_geo_file_url(id = id, file_type)
    file_paths <- file.path(dest_dir, basename(urls))
    download_inform(urls, file_paths, method = "ftp")
}

download_geo_suppl_files <- function(id, dest_dir) {
    download_geo_suppl_files_or_gse_matrix(id, dest_dir, file_type = "suppl")
}

download_geo_gse_matrix <- function(id, dest_dir) {
    download_geo_suppl_files_or_gse_matrix(id, dest_dir, file_type = "matrix")
}

#' Download utils function with good message.
#' @importFrom curl curl_download new_handle handle_setopt
#' @noRd
download_inform <- function(urls, file_paths, method = "ftp") {
    .mapply(
        function(url, file_path) {
            if (!file.exists(file_path)) {
                if (!dir.exists(dirname(file_path))) {
                    dir.create(dirname(file_path), recursive = TRUE)
                }
                rlang::inform(paste0("Downloading ", basename(url), ":"))
                h <- curl::new_handle()
                if (identical(method, "ftp")) {
                    curl::handle_setopt(
                        h, buffersize = 33554432,
                        upload_buffersize = 33554432
                    )
                }
                curl::curl_download(
                    url, file_path,
                    mode = "wb", quiet = FALSE,
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
        }, list(urls, file_paths), NULL
    )
    invisible(file_paths)
}
