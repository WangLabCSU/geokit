get_geo_soft <- function(ids, geo_type, odir, ftp_over_https, handle_opts) {
    soft_data_list <- download_and_parse_soft(
        ids = ids, geo_type = geo_type,
        odir = odir,
        ftp_over_https = ftp_over_https,
        handle_opts = handle_opts,
        only_meta = FALSE
    )
    .mapply(
        new_geo_obj,
        list(id = ids, soft_data = soft_data_list),
        list(geo_type = geo_type)
    )
}

# For GPL, GSM, and GDS entity, return a `GEOSoft` object
# For GSE entity, return a `GEOSeries` object
new_geo_obj <- function(id, geo_type, soft_data) {
    switch(geo_type,
        GSM = ,
        GPL = ,
        GDS = methods::new(
            "GEOSoft",
            meta = soft_data$meta,
            columns = column_to_rownames(soft_data$columns),
            datatable = set_rownames(soft_data$data_table),
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

download_and_parse_soft <- function(ids, geo_type, odir, handle_opts, only_meta, ftp_over_https) {
    file_paths <- switch(geo_type,
        GSM = download_gsm_files(ids,
            odir = odir,
            handle_opts = handle_opts
        ),
        GPL = download_gpl_files(
            ids,
            odir = odir, amount = "full",
            handle_opts = handle_opts,
            ftp_over_https = ftp_over_https
        ),
        GSE = download_gse_soft_files(ids,
            odir = odir,
            handle_opts = handle_opts,
            ftp_over_https = ftp_over_https
        ),
        GDS = download_gds_files(ids,
            odir = odir,
            handle_opts = handle_opts,
            ftp_over_https = ftp_over_https
        )
    )
    bar_id <- cli::cli_progress_bar(
        format = "{cli::pb_spin} Parsing {.field {ids[cli::pb_current]}} soft file | {cli::pb_current}/{cli::pb_total}",
        format_done = "Parsing {.val {cli::pb_total}} {.field soft} file{?s} in {cli::pb_elapsed}",
        total = length(ids),
        clear = FALSE
    )
    .mapply(function(id, file_path) {
        cli::cli_progress_update(id = bar_id)
        file_text <- read_lines(file_path)
        switch(geo_type,
            GSM = ,
            GPL = parse_gpl_or_gsm_soft(file_text, only_meta = only_meta),
            GSE = parse_gse_soft(file_text,
                entity_type = "all",
                only_meta = only_meta
            ),
            GDS = parse_gds_soft(file_text, only_meta = only_meta)
        )
    }, list(id = ids, file_path = file_paths), NULL)
}
