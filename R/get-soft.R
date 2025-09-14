get_geo_soft <- function(ids, geo_type, amount, ftp_over_https, handle_opts,
                         odir) {
    download_and_parse_soft(
        ids = ids,
        geo_type = geo_type,
        amount = amount,
        handle_opts = handle_opts,
        only_meta = FALSE,
        ftp_over_https = ftp_over_https,
        odir = odir,
        post_process = function(id, soft_data) {
            # For GPL, GSM, and GDS entity, return a `GEOSoft` object
            # For GSE entity, return a `GEOSeries` object
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
    )
}

download_and_parse_soft <- function(ids, geo_type, amount, handle_opts,
                                    only_meta, ftp_over_https,
                                    post_process = NULL, odir) {
    file_paths <- switch(geo_type,
        GSM = download_gsm_files(
            ids,
            amount = amount,
            handle_opts = handle_opts,
            odir = odir
        ),
        GPL = download_gpl_files(
            ids,
            amount = amount,
            handle_opts = handle_opts,
            ftp_over_https = ftp_over_https,
            odir = odir
        ),
        GSE = download_gse_files(
            ids,
            amount = amount,
            handle_opts = handle_opts,
            ftp_over_https = ftp_over_https,
            odir = odir
        ),
        GDS = download_gds_files(
            ids,
            amount = amount,
            handle_opts = handle_opts,
            ftp_over_https = ftp_over_https,
            odir = odir
        )
    )
    bar <- cli::cli_progress_bar(
        format = "{cli::pb_spin} Parsing {.field {ids[cli::pb_current]}} soft file | {cli::pb_current}/{cli::pb_total}",
        format_done = "Parsing {.val {cli::pb_total}} {.field soft} file{?s} in {cli::pb_elapsed}",
        total = length(ids),
        clear = FALSE
    )
    .mapply(function(id, file_path) {
        cli::cli_progress_update(id = bar)
        file_text <- read_lines(file_path)
        out <- switch(geo_type,
            GSM = ,
            GPL = parse_gpl_or_gsm_soft(file_text, only_meta = only_meta),
            GSE = parse_gse_soft(
                file_text,
                entity_type = "all",
                only_meta = only_meta
            ),
            GDS = parse_gds_soft(file_text, only_meta = only_meta)
        )
        if (is.null(post_process)) out else post_process(id, out)
    }, list(id = ids, file_path = file_paths), NULL)
}
