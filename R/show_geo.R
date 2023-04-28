#' Load GEO Accession site into a HTML Browser
#' 
#' @param id A string representing the GEO entity
#' ('GDS505','GSE2','GSM2','GPL96' eg.).
#' @param browser a non-empty character string giving the name of the program to
#' be used as the HTML browser. It should be in the PATH, or a full path
#' specified. Alternatively, an R function to be called to invoke the
#' browser.
#'
#' Under Windows NULL is also allowed (and is the default), and implies
#' that the file association mechanism will be used.
#' @details See [utils::browseURL()]
#' @export
show_geo <- function(id, browser = getOption("browser")) {
    if (!(length(id) == 1L && is.character(id))) {
        stop("`id` must be a string", call. = FALSE)
    }
    id <- toupper(id)
    check_ids(id)
    utils::browseURL(
        build_geo_acc_url(
            id, scope = "self", amount = "quick", format = "html"
        ),
        browser = browser
    )
}
