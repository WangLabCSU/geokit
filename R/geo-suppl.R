#' Get Supplemental Files from GEO
#'
#' NCBI GEO allows supplemental files to be attached to GEO Series (GSE), GEO
#' platforms (GPL), and GEO samples (GSM). This function 'knows' how to get
#' these files based on the GEO accession. No parsing of the downloaded files is
#' attempted, since the file format is not generally knowable.
#'
#' @inheritParams geo_soft
#' @param pattern character string containing a
#' [regular expression][base::regex] to be matched in the supplementary file
#' names.
#' @return A list (or a character atomic verctor if only one `accession` is
#' provided) of the full file paths of the resulting downloaded files.
#' @examples
#' geo_suppl("GSM1137", odir = tempdir())
#' @export
geo_suppl <- function(accession, pattern = NULL, ftp_over_https = TRUE,
                      handle_opts = list(), odir = getwd()) {
    odir <- dir_create(odir, recursive = TRUE)
    file_paths <- download_url_directory(
        accession,
        format = "suppl",
        pattern = pattern,
        ftp_over_https = ftp_over_https,
        handle_opts = handle_opts,
        odir = odir
    )
    return_object_or_list(file_paths, accession)
}
