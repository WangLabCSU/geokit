#' Get the metadata of multiple GEO identities
#'
#' This is useful to combine with [geo_search()] and filter results since
#' `geo_search()` cannot get all long metadata of GEO identities.
#'
#' @inheritParams geo
#' @return A [data.table][data.table::data.table] contains metadata of all ids.
#' @export
geo_meta <- function(ids, amount = NULL, ftp_over_https = TRUE,
                     handle_opts = list(), odir = getwd()) {
    ids <- check_ids(ids)
    odir <- dir_create(odir, recursive = TRUE)
    amount <- check_amount(amount)
    meta_list <- download_and_parse_soft(
        ids = ids,
        geo_type = substr(ids, 1L, 3L)[1L],
        amount = amount,
        handle_opts = handle_opts,
        only_meta = TRUE,
        ftp_over_https = ftp_over_https,
        odir = odir,
        post_process = function(id, meta) {
            collapsed <- lengths(meta) != 1L
            meta[collapsed] <- lapply(meta[collapsed], paste0, collapse = "; ")
            data.table::setDT(meta)
        }
    )
    data.table::rbindlist(meta_list, use.names = TRUE, fill = TRUE)
}
