#' @import xml2
list_file_helper <- function(url, id) {
    xml_doc <- xml2::read_html(url)
    file_name <- str_extract_all(
        xml2::xml_text(xml_doc),
        "G\\S++"
    )
    if (identical(length(file_name), 1L) && !length(file_name)) {
        return(NULL)
    }
    file.path(url, file_name[[1]])
}
list_geo_file_urls <- function(ids, file_type) {
    file_type <- match.arg(file_type, c("matrix", "suppl"))
    urls <- build_geo_ftp_urls(ids, file_type)
    .mapply(function(url, id) {
        list_file_helper(url)
    }, list(urls, ids), NULL)
}

list_geo_suppl_file_urls <- function(ids) {
    list_geo_file_urls(ids, "suppl")
}

list_geo_gse_matrix_urls <- function(ids) {
    list_geo_file_urls(ids, "matrixx")
}
