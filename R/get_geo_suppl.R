#' Get Supplemental Files from GEO
#'
#' NCBI GEO allows supplemental files to be attached to GEO Series (GSE), GEO
#' platforms (GPL), and GEO samples (GSM).  This function 'knows' how to get
#' these files based on the GEO accession.  No parsing of the downloaded files
#' is attempted, since the file format is not generally knowable by the
#' computer.
#'
#' @inheritParams get_geo
#' @param pattern character string containing a [regular
#' expression][base::regex] to be matched in the supplementary file names.
#' @return A list (or a character atomic verctor if only one `id` is provided)
#' of the full file paths of the resulting downloaded files.
#' @keywords IO database
#' @examples
#'
#' a <- get_geo_suppl("GSM1137", tempdir())
#' a
#'
#' @export
get_geo_suppl <- function(ids, dest_dir = getwd(), pattern = NULL, ftp_over_https = TRUE, handle_opts = list(connecttimeout = 60L)) {
    ids <- toupper(ids)
    check_ids(ids)
    if (!dir.exists(dest_dir)) {
        dir.create(dest_dir, recursive = TRUE)
    }
    file_paths <- download_geo_suppl_or_gse_matrix_files(
        ids,
        dest_dir = dest_dir, file_type = "suppl",
        pattern = pattern, 
        ftp_over_https = ftp_over_https,
        handle_opts = handle_opts
    )
    if (length(file_paths) == 1L) {
        file_paths[[1L]]
    } else {
        names(file_paths) <- ids
        file_paths
    }
}
