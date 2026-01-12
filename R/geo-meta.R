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
    paths <- download_soft(
        accession,
        famount = famount, scope = scope,
        ftp_over_https = ftp_over_https,
        handle_opts = handle_opts,
        odir = odir
    )
    entity_list <- parse_soft_rust(paths, use_lines = "metadata")
    olist <- lapply(entity_list, parse_entity_list)
    olist <- lapply(olist, function(soft) {
        metadata <- metadata(soft)
        # each metadata is a list group by entity
        metadata <- lapply(names(metadata), function(nm) {
            sublist <- .subset2(metadata, nm)
            collapsed <- lengths(sublist) != 1L
            sublist[collapsed] <- lapply(
                sublist[collapsed], paste0,
                collapse = "; "
            )
            # names(sublist) <- paste(nm, names(sublist), sep = "_")
            sublist
        })
        metadata <- unlist(metadata, FALSE)
        data.table::setDT(metadata)
    })
    out <- data.table::rbindlist(olist, use.names = TRUE, fill = TRUE)
    data.table::setDF(out)
    out
}
