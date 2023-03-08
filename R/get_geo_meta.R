#' Get the metadata of multiple GEO identities
#'
#' This is useful to combine with [search_geo()] and filter results since
#' `search_geo()` cannot get all long metadata of GEO identities.
#'
#' @inheritParams get_geo
#' @return A data.frame contains metadata of all ids.
#' @export 
get_geo_meta <- function(ids, dest_dir = getwd(), curl_handle = NULL) {
    res <- lapply(ids, function(id) {
        out <- rlang::try_fetch(
            get_and_parse_soft(
                id = id, 
                geo_type = substr(id, 1L, 3L),
                dest_dir = dest_dir, 
                curl_handle = curl_handle,
                only_meta = TRUE
            ),
            error = function(err) {
                rlang::abort(
                    paste0("Error when fetching GEO metadata of ", id, "."),
                    parent = err
                )
            }
        )
        out <- lapply(out$meta, function(x) {
            if (length(x) == 1L) x else paste0(x, collapse = "; ")
        })
        data.table::setDT(out)
    })
    res <- data.table::rbindlist(res, use.names = TRUE, fill = TRUE)
    data.table::setDF(res)
}
