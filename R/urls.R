#' Construct a URL to retrieve data from GEO Accession Display Bar
#'
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
#' @param format A character string in one of "text", "xml" or "html".
#' Allows you to display the GEO accession in human readable, linked "HTML"
#' form, or in machine readable, "text" format, which is the same with "soft"
#' format. SOFT stands for "simple omnibus format in text".
#' @noRd
build_geo_acc_url <- function(ids, scope = "self", amount = "data",
                              format = "text") {
    sprintf(
        "https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=%s&targ=%s&view=%s&form=%s",
        tolower(ids), scope, amount, format
        # match.arg(
        #     tolower(scope),
        #     c("self", "gsm", "gpl", "gse", "all")
        # ),
        # match.arg(
        #     tolower(amount),
        #     c("brief", "quick", "data", "full")
        # ),
        # GEO use "text" to refer to "soft" format
        # GEO use "xml" to refer to "miniml" format
        # match.arg(
        #     tolower(format),
        #     c("text", "html", "xml")
        # )
    )
}

#' Construct a FTP URL to retrieve data from GEO FTP Site
#'
#' @param file_type A character string in one of "soft", "soft_full", "annot",
#' "miniml" or "suppl".
#' @noRd
build_geo_ftp_url <- function(ids, file_type = "soft", ftp_over_https = FALSE) {
    geo_type <- substr(ids, 1L, 3L)[1L]
    # file_type <- match.arg(
    #     tolower(file_type),
    #     c("soft", "soft_full", "annot", "miniml", "suppl", "matrix")
    # )
    super_ids <- str_replace(ids, "\\d{1,3}$", "nnn")
    if (ftp_over_https) {
        geo_ftp_site <- geo_ftp_over_https
    } else {
        geo_ftp_site <- geo_ftp
    }
    # file.path will omit the ending / in windows, so we just use paste
    paste(
        geo_ftp_site,
        parse_geo_type(geo_type),
        super_ids, ids, file_type,
        parse_file_name(ids, file_type, geo_type),
        sep = "/"
    )
}

# Use https to connect GEO FTP site
# When connecting GEO FTP site directly, it often failed to derive data.
geo_ftp <- "ftp://ftp.ncbi.nlm.nih.gov/geo"
geo_ftp_over_https <- "https://ftp.ncbi.nlm.nih.gov/geo"

parse_geo_type <- function(x) {
    switch(x,
        GSE = "series",
        GPL = "platforms",
        GSM = "samples",
        GDS = "datasets"
    )
}

#' @section GEO file type reference table:
#' |            type            | GDS | GSE | GPL | GSM |
#' | :------------------------: | :-: | :-: | :-: | :-: |
#' |        SOFT (soft)         |  o  |  o  |  o  |  x  |
#' |    SOFTFULL (soft_full)    |  o  |  x  |  x  |  x  |
#' |      MINiML (miniml)       |  x  |  o  |  o  |  x  |
#' |      Matrix (matrix)       |  x  |  o  |  x  |  x  |
#' |     Annotation (annot)     |  x  |  x  |  o  |  x  |
#' | Supplementaryfiles (suppl) |  x  |  o  |  o  |  o  |
#' @noRd
parse_file_name <- function(ids, file_type, geo_type) {
    # file.path will add / for "" in the end
    file_suffix <- switch(geo_type,
        GDS = switch(file_type,
            soft = ".soft.gz",
            soft_full = "_full.soft.gz"
        ),
        GSE = switch(file_type,
            soft = "_family.soft.gz",
            miniml = "_family.xml.tgz",
            matrix = "",
            suppl = ""
        ),
        GPL = switch(file_type,
            annot = ".annot.gz",
            miniml = "_family.xml.tgz",
            soft = "_family.soft.gz",
            suppl = ""
        ),
        GSM = if (file_type == "suppl") "" else NULL
    )
    if (is.null(file_suffix)) {
        cli::cli_abort(
            "{.field {parse_geo_type(geo_type)}} never own {.val {file_type}} file."
        )
    }
    if (nzchar(file_suffix)) {
        paste0(ids, file_suffix)
    } else {
        file_suffix
    }
}

# parse_file_switch_helper <- list(
#     GDS = c(soft = ".soft.gz", soft_full = "_full.soft.gz"),
#     GSE = c(
#         soft = "_family.soft.gz", miniml = "_family.xml.tgz",
#         matrix = "_series_matrx.txt.gz", suppl = ""
#     ),
#     GPL = c(
#         annot = ".annot.gz",
#         miniml = "_family.xml.tgz",
#         soft = "_family.soft.gz",
#         suppl = ""
#     ),
#     GSM = c(suppl = "")
# )
# parse_file <- function(ids, file_type, geo_type) {
#     file_suffix <- parse_file_switch_helper[[geo_type]][[file_type]]
#     if (is.na(file_suffix)) {
#         rlang::abort(
#             "{parse_geo_type(geo_type)} never own {file_type} file"
#         )
#     }
#     if (nchar(file_suffix)) {
#         file_ids <- paste0(ids, file_suffix)
#     } else {
#         file_ids <- file_suffix
#     }
#     paste0(file_type, "/", file_ids)
# }
