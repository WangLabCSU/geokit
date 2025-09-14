#' Get Supplemental Files from GEO
#'
#' NCBI GEO allows supplemental files to be attached to GEO Series (GSE), GEO
#' platforms (GPL), and GEO samples (GSM). This function 'knows' how to get
#' these files based on the GEO accession. No parsing of the downloaded files is
#' attempted, since the file format is not generally knowable by the computer.
#'
#' @inheritParams geo
#' @param pattern character string containing a
#' [regular expression][base::regex] to be matched in the supplementary file
#' names.
#' @return A list (or a character atomic verctor if only one `id` is provided)
#' of the full file paths of the resulting downloaded files.
#' @examples
#' geo_suppl("GSM1137", odir = tempdir())
#' @export
geo_suppl <- function(ids, pattern = NULL, ftp_over_https = TRUE,
                      handle_opts = list(), odir = getwd()) {
    ids <- check_ids(ids)
    odir <- dir_create(odir, recursive = TRUE)
    file_paths <- download_suppl_or_gse_matrix_files(
        ids,
        odir = odir, formats = "suppl",
        pattern = pattern,
        ftp_over_https = ftp_over_https,
        handle_opts = handle_opts
    )
    return_object_or_list(file_paths, ids)
}
