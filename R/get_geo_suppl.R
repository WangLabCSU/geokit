#' Get Supplemental Files from GEO
#'
#' NCBI GEO allows supplemental files to be attached to GEO Series (GSE), GEO
#' platforms (GPL), and GEO samples (GSM).  This function 'knows' how to get
#' these files based on the GEO accession.  No parsing of the downloaded files
#' is attempted, since the file format is not generally knowable by the
#' computer.
#'
#' @note just a note that the files are simply downloaded.
#'
#' @inheritParams get_geo
#' @return A list (or a character atomic verctor if only one `id` is provided)
#' of The full file paths of the resulting downloaded files.
#' @keywords IO database
#' @examples
#'
#' a <- get_geo_suppl("GSM1137", tempdir())
#' a
#'
#' @export
get_geo_suppl <- function(ids, dest_dir = getwd()) {
    ids <- toupper(ids)
    check_ids(ids)
    get_geo_suppl_multi(ids = ids, dest_dir = dest_dir)
}

get_geo_suppl_multi <- function(ids, dest_dir = getwd()) {
    file_paths <- lapply(ids, function(id) {
        rlang::try_fetch(
            download_geo_suppl_or_gse_matrix_files(
                id,
                dest_dir = dest_dir, file_type = "suppl"
            ),
            error = function(err) {
                rlang::abort(
                    paste0(
                        "Error when fetching GEO Supplementary data of ",
                        id, "."
                    ),
                    parent = err
                )
            }
        )
    })
    if (identical(length(file_paths), 1L)) {
        file_paths[[1L]]
    } else {
        names(file_paths) <- ids
        file_paths
    }
}
