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
                        "File ", basename(url),
                        " is already downloaded at ",
                        file_path
                    )
                )
            }
        },
        list(urls, file_paths), NULL
    )
    invisible(urls)
}

download_geo_files <- function(ids, dest_dir = getwd(), file_type) {
    file_type <- match.arg(
        tolower(file_type),
        c("soft", "soft_full", "annot", "miniml", "matrix")
    )
    urls <- build_geo_ftp_urls(ids = ids, file_type = file_type)
    file_paths <- file.path(dest_dir, basename(urls))
    download_inform(urls, file_paths)
    invisible(file_paths)
}

download_geo_suppl_files <- function(ids, dest_dir = getwd()) {
    urls <- list_geo_suppl_file_urls_multi(ids = ids)
    file_paths <- lapply(urls, function(url) {
        file_path <- file.path(dest_dir, basename(url))
        download_inform(url, file_path)
        file_path
    })
    invisible(file_paths)
}
