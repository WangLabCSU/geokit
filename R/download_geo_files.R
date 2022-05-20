download_inform <- function(urls, file_paths) {
    tryCatch(
        download.file(urls, file_paths, mode = "wb"),
        error = rlang::inform(c(
            paste0("Download failed for file ", basename(urls), "."),
            paste0("Check URL(", urls, ") manually if in doubt")
        ))
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
