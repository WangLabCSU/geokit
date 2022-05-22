#' @import xml2
list_file_helper <- function(url) {
    xml_doc <- xml2::read_html(url)
    file_name <- str_extract_all(
        xml2::xml_text(xml_doc),
        "G\\S++"
    )
    if (identical(length(file_name), 1L) && !length(file_name[[1L]])) {
        return(NULL)
    }
    file.path(url, file_name[[1L]])
}
list_geo_file_url <- function(id, file_type) {
    url <- build_geo_ftp_url(id, file_type)
    res <- list_file_helper(url)
    if (is.null(res)) {
        rlang::inform(
            paste0("No ", file_type, " file found for ", id, ".")
        )
    }
    res
}

list_geo_suppl_file_url <- function(ids) {
    list_geo_file_url(ids, "suppl")
}

list_geo_gse_matrix_url <- function(ids) {
    list_geo_file_url(ids, "matrixx")
}
