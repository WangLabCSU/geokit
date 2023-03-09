#' Get the metadata of multiple GEO identities
#'
#' This is useful to combine with [search_geo()] and filter results since
#' `search_geo()` cannot get all long metadata of GEO identities.
#'
#' @inheritParams get_geo
#' @return A data.frame contains metadata of all ids.
#' @export
get_geo_meta <- function(ids, dest_dir = getwd(), curl_handle = NULL) {
    ids <- toupper(ids)
    check_ids(ids)
    if (!dir.exists(dest_dir)) {
        dir.create(dest_dir, recursive = TRUE)
    }
    res <- lapply(ids, function(id) {
        out <- rlang::try_fetch(
            get_and_parse_soft(
                id = id,
                geo_type = substring(id, 1L, 3L),
                dest_dir = dest_dir,
                curl_handle = curl_handle,
                only_meta = TRUE
            ),
            error = function(err) {
                cli::cat_line()
                cli::cli_abort(
                    "Error when fetching GEO metadata of {.val {id}}",
                    parent = err
                )
            }
        )$meta
        out[lengths(out) != 1L] <- lapply(
            out[lengths(out) != 1L], function(x) {
                paste0(x, collapse = "; ")
            }
        )
        data.table::setDT(out)
    })
    res <- data.table::rbindlist(res, use.names = TRUE, fill = TRUE)
    data.table::setDF(res)
}
