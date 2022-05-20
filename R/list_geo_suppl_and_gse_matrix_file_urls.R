list_geo_suppl_file_urls <- function(url, id) {
    xml_doc <- xml2::read_html(url)
    suppl_file_name <- str_extract_all(
        xml2::xml_text(xml_doc),
        "G\\S++"
    )
    if (identical(length(suppl_file_name), 1L) && !length(suppl_file_name)) {
        return(NULL)
    }
    file.path(url, suppl_file_name[[1]])
}

list_geo_suppl_file_urls_multi <- function(ids) {
    urls <- build_geo_ftp_urls(ids, "suppl")
    .mapply(function(url, id) {
        list_geo_suppl_file_urls(url)
    }, list(urls, ids), NULL)
}
