#' Get the metadata of multiple GEO identities
#'
#' This is useful to combine with [`geo_search()`] and filter results since
#' `geo_search()` cannot get all long metadata of GEO identities.
#'
#' @inheritParams geo_soft
#' @return A data frame contains metadata of all ids.
#' @export
geo_meta <- function(accession, famount = NULL, scope = NULL,
                     ftp_over_https = NULL,
                     handle_opts = list(), odir = getwd()) {
    odir <- dir_create(odir, recursive = TRUE)
    olist <- geo_soft_impl(
        accession,
        famount = famount, scope = scope,
        ftp_over_https = ftp_over_https,
        handle_opts = handle_opts,
        odir = odir
    )
    olist <- lapply(olist, function(soft) {
        meta <- metadata(soft)
        collapsed <- lengths(meta) != 1L
        meta[collapsed] <- lapply(meta[collapsed], paste0, collapse = "; ")
        data.table::setDT(meta)
    })
    out <- data.table::rbindlist(olist, use.names = TRUE, fill = TRUE)
    data.table::setDF(out)
    out
}
