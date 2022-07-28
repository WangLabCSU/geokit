#' @param gpl a character string
#' @return a character for the name of corresponding Bioconductor annotation
#' package or NA if it doesn't exist.
#' @noRd 
gpl2bioc <- function(gpl) {
    if (has_bioc_annotation_pkg(gpl)) {
        bioc_pkg_expr <- gpl2bioc_dt[
            Platform_geo_accession == gpl, bioc_pkg,
            env = list(gpl = I(gpl))
        ]
    } else {
        NA_character_
    }
}

has_bioc_annotation_pkg <- function(gpl) {
    gpl %in% gpl2bioc_dt$Platform_geo_accession
}
