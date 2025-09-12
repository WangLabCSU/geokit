#' Get the metadata of multiple GEO identities
#'
#' This is useful to combine with [geo_search()] and filter results since
#' `geo_search()` cannot get all long metadata of GEO identities.
#'
#' @inheritParams geo
#' @return A [data.table][data.table] contains metadata of all ids.
#' @export
geo_meta <- function(ids, ftp_over_https = TRUE,
                     handle_opts = list(connecttimeout = 60L),
                     odir = getwd()) {
    ids <- check_ids(ids)
    odir <- dir_create(odir, recursive = TRUE)
    meta_list <- download_and_parse_soft(
        ids = ids,
        geo_type = substr(ids, 1L, 3L)[1L],
        odir = odir,
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
