#' @param gpl a character string
#' @return A character for the name of corresponding Bioconductor annotation
#' package or NA if it doesn't exist.
#' @importFrom data.table %chin%
#' @noRd
gpl2bioc <- function(gpl) {
    mapping <- read_internal("gpl2bioc.rds")
    mapping[gpl, env = list(gpl = I(gpl)), on = "Platform_geo_accession"]
}

gpl2bioc_pkg <- function(gpl) {
    bioc_pkg <- gpl2bioc(gpl)$bioc_pkg
    if (length(bioc_pkg)) {
        cli::cli_alert_success("Found Bioconductor annotation package for {.val {gpl}}")
        bioc_pkg
    } else {
        cli::cli_alert_info("No Bioconductor annotation package available for platform {.val {gpl}}.")
        NA_character_
    }
}
