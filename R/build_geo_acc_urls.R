#' Construct a URL to retrieve data from GEO Accession Display Bar
#'
#' @param id  a valid GEO accession i.e., gplxxx, gsmxxx or gsexxx
#' @param scope A character string in one of "self", "gsm", "gpl", "gse" or
#' "all". allows you to display the GEO accession(s) which you wish to target
#' for display. You may display the GEO accession which is typed into the text
#' box itself ("Self"), or any ("Platform", "Samples", or "Series") or all
#' ("Family") of the accessions related to the accession number typed into the
#' text box.
#' @param amount A character string in one of "brief", "quick", "data" or
#' "full". Allows you to control the amount of data that you will see displayed.
#' "Brief" displays the accession's attributes only. "Quick" displays the
#' accession's attributes and the first twenty rows of its data table. "Full"
#' displays the accessions's attributes and the full data table. "Data" omits
#' the accession's attributes, showing only the links to other accessions as
#' well as the full data table
#' @param format A character string in one of "text", "html" or "xml". Allows
#' you to display the GEO accession in human readable, linked "HTML" form, or in
#' machine readable, "SOFT" form. SOFT stands for "simple omnibus format in
#' text".
#' @references
#' * https://www.ncbi.nlm.nih.gov/geo/info/download.html
#' * https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi
build_geo_acc_url <- function(id, scope = "self", amount = "data", format = "text") {
    sprintf(
        "https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=%s&targ=%s&view=%s&form=%s", 
        tolower(id),
        match.arg(
            tolower(scope),
            c("self", "gsm", "gpl", "gse", "all")
        ),
        match.arg(
            tolower(amount),
            c("brief", "quick", "data", "full.")
        ),
        match.arg(
            tolower(amount),
            c("text", "html", "xml")
        )
    )
}
