# For GPL, GSM, and GDS entity, return a `GEOSoft` object
# For GSE entity, return a `GEOSeries` object
get_geo_soft <- function(id, geo_type, dest_dir = getwd(), curl_handle = NULL) {
    file_path <- switch(geo_type,
        GSM = download_gsm_file(id,
            dest_dir = dest_dir,
            curl_handle = curl_handle
        ),
        GPL = download_gpl_file(
            id,
            dest_dir = dest_dir, amount = "full",
            curl_handle = curl_handle
        ),
        GSE = download_gse_soft_file(id,
            dest_dir = dest_dir,
            curl_handle = curl_handle
        ),
        GDS = download_gds_file(id,
            dest_dir = dest_dir,
            curl_handle = curl_handle
        )
    )
    file_text <- read_lines(file_path)
    soft_data <- switch(geo_type,
        GSM = ,
        GPL = parse_gpl_or_gsm_soft(file_text),
        GSE = parse_gse_soft(file_text, entity_type = "all"),
        GDS = parse_gds_soft(file_text)
    )
    switch(geo_type,
        GSM = ,
        GPL = ,
        GDS = methods::new(
            "GEOSoft",
            meta = soft_data$meta,
            columns = soft_data$columns,
            datatable = soft_data$data_table,
            accession = id
        ),
        GSE = methods::new(
            "GEOSeries",
            meta = soft_data$meta,
            gsm = soft_data$gsm,
            gpl = soft_data$gpl,
            accession = id
        )
    )
}
