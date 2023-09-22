#' Get the metadata of multiple GEO identities
#'
#' This is useful to combine with [search_geo()] and filter results since
#' `search_geo()` cannot get all long metadata of GEO identities.
#'
#' @inheritParams get_geo
#' @return A [data.table][data.table] contains metadata of all ids.
#' @export
get_geo_meta <- function(ids, dest_dir = getwd(), ftp_over_https = TRUE, handle_opts = list(connecttimeout = 60L)) {
    ids <- toupper(ids)
    check_ids(ids)
    if (!dir.exists(dest_dir)) {
        dir.create(dest_dir, recursive = TRUE)
    }
    meta_list <- download_and_parse_soft(
        ids = ids,
        geo_type = substr(ids, 1L, 3L)[1L],
        dest_dir = dest_dir,
        ftp_over_https = ftp_over_https,
        handle_opts = handle_opts,
        only_meta = TRUE
    )
    meta_list <- lapply(meta_list, function(meta) {
        meta[lengths(meta) != 1L] <- lapply(
            meta[lengths(meta) != 1L],
            paste0,
            collapse = "; "
        )
        data.table::setDT(meta)
    })
    data.table::rbindlist(meta_list, use.names = TRUE, fill = TRUE)
}
