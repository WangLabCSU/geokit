## code to prepare `gpl2bioc` dataset goes here
if (!dir.exists(odir <- file.path("inst/extdata"))) {
    dir.create(odir, recursive = TRUE)
}

old_gpl2bioc <- readRDS(file.path(odir, "gpl2bioc.rds"))
new_gpl2bioc <- structure("hgu95av2.db", names = c("GPL8300"))
new_gpl2bioc <- new_gpl2bioc[
    setdiff(names(new_gpl2bioc), old_gpl2bioc$Platform_geo_accession)
]
if (length(new_gpl2bioc)) {
    gpl_soft <- geo(names(new_gpl2bioc), odir = tempdir())
    if (is(gpl_soft, "GEOSoft")) gpl_soft <- list(gpl_soft)
    gpl2bioc_list <- lapply(gpl_soft, function(gpl) {
        res <- meta(gpl)[
            intersect(
                c(
                    "Platform_geo_accession", "Platform_title",
                    "Platform_manufacturer", "Platform_description", "Platform_organism",
                    "Platform_data_row_count", "Platform_status",
                    "Platform_submission_date", "Platform_technology",
                    "Platform_web_link"
                ),
                names(meta(gpl))
            )
        ]
        res <- c(res, bioc_pkg = new_gpl2bioc[[res$Platform_geo_accession]])
        res <- lapply(res, function(x) {
            if (is.null(x)) {
                NA_character_
            } else if (length(x) > 1L) {
                x <- x[x != "" & !is.na(x)]
                paste0(x, collapse = "; ")
            } else {
                x
            }
        })
        data.table::setDT(res)
    })

    gpl2bioc_dt <- data.table::rbindlist(
        c(list(old_gpl2bioc), gpl2bioc_list),
        use.names = TRUE, fill = TRUE, idcol = FALSE
    )
    gpl2bioc_dt[
        , Platform_data_row_count := read_text(
            text = Platform_data_row_count, sep = "",
            header = FALSE
        )[[1L]]
    ]
    data.table::setcolorder(
        gpl2bioc_dt, "bioc_pkg",
        after = "Platform_geo_accession"
    )
    gpl2bioc_dt[, Platform_data_row_count]
    saveRDS(gpl2bioc_dt, file.path(odir, "gpl2bioc.rds"))
}

Sys.setenv(
    http_proxy = "127.0.0.1:10809",
    https_proxy = "127.0.0.1:10809"
)
