has_bioc_annotation_pkg <- function(gpl) {
    gpl %in% gpl2bioc_dt$Platform_geo_accession
}

gpl2bioc <- function(gpl) {
    if (has_bioc_annotation_pkg(gpl)) {
        bioc_pkg_expr <- rlang::expr(
            gpl2bioc_dt[
                Platform_geo_accession == !!gpl, bioc_pkg
            ]
        )
        rlang::eval_bare(bioc_pkg_expr)
    } else {
        NA_character_
    }
}
