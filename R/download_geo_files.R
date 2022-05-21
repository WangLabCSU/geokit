download_geo_files <- function(ids, dest_dir, file_type) {
    file_type <- match.arg(
        tolower(file_type),
        c("soft", "soft_full", "annot", "miniml")
    )
    urls <- build_geo_ftp_urls(ids = ids, file_type = file_type)
    file_paths <- file.path(dest_dir, basename(urls))
    download_inform(urls, file_paths)
    invisible(file_paths)
}

# Return a list of file paths for each ids.
#' @noMd  
download_geo_suppl_files_or_gse_matrix <- function(ids, dest_dir, file_type) {
    url_list <- list_geo_file_urls(ids = ids, file_type)
    file_path_list <- lapply(url_list, function(urls) {
        file_paths <- file.path(dest_dir, basename(urls))
        download_inform(urls, file_paths)
        file_paths
    })
    invisible(file_path_list)
}

download_geo_suppl_files <- function(ids, dest_dir) {
    download_geo_suppl_files_or_gse_matrix(ids, dest_dir, file_type = "suppl")
}

download_geo_gse_matrix <- function(ids, dest_dir) {
    download_geo_suppl_files_or_gse_matrix(ids, dest_dir, file_type = "matrixx")
}


download_inform <- function(urls, file_paths) {
    .mapply(
        function(url, file_path) {
            if (!file.exists(file_path)) {
                res <- download.file(url, file_path, mode = "wb")
                if (res) {
                    if (file.exists(file_path)) {
                        file.remove(file_path)
                    }
                    rlang::abort(c(
                        paste0("Download failed for file ", basename(url), "."),
                        paste0("Check URL(", url, ") manually if in doubt")
                    ))
                }
            } else {
                rlang::inform(
                    paste0(
                        "Using locally cached version of ", basename(url),
                        " found here: ",
                        file_path
                    )
                )
            }
        },
        list(urls, file_paths), NULL
    )
    invisible(urls)
}
