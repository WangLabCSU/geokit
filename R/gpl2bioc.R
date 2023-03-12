#' @param gpl a character string
#' @return a character for the name of corresponding Bioconductor annotation
#' package or NA if it doesn't exist.
#' @noRd
gpl2bioc <- function(gpl) {
    if (has_bioc_annotation_pkg(gpl)) {
        cli::cli_alert_success("Found Bioconductor annotation package for {.val {gpl}}")
        gpl2bioc_dt[
            Platform_geo_accession == gpl, bioc_pkg,
            env = list(gpl = I(gpl))
        ]
    } else {
        cli::cli_alert_info(
            "Cannot map {.val {gpl}} to a Bioconductor annotation package"
        )
        NA_character_
    }
}

#' @importFrom data.table %chin%
has_bioc_annotation_pkg <- function(gpl) {
    gpl %chin% gpl2bioc_dt$Platform_geo_accession
}
