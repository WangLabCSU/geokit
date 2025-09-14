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
    # GEO use "text" to refer to "soft" format
    # GEO use "xml" to refer to "miniml" format
    sprintf(
        "https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=%s&targ=%s&view=%s&form=%s",
        tolower(ids), scope, amount, format
    )
}

#' Construct a FTP URL to retrieve data from GEO FTP Site
#'
#' @param formats A character string in one of "soft", "soft_full", "annot",
#' "miniml" or "suppl".
#' @noRd
build_geo_ftp_url <- function(ids, formats = "soft", ftp_over_https = TRUE) {
    geo_types <- substr(ids, 1L, 3L)
    call <- rlang::current_call()
    fnames <- .mapply(function(format, geo_type) {
        file_suffix <- parse_file_suffix(format, geo_types)
        if (is.null(file_suffix)) {
            cli::cli_abort(
                "{.field {geo_type}} never own {.val {format}} file.",
                call = call
            )
        }
        if (nzchar(file_suffix)) {
            paste0(ids, file_suffix)
        } else {
            file_suffix
        }
    }, list(format = formats, geo_type = geo_types), NULL)
    super_ids <- str_replace(ids, "\\d{1,3}$", "nnn")

    # Use https to connect GEO FTP site
    # When connecting GEO FTP site directly, it often failed to derive data.
    if (isTRUE(ftp_over_https)) {
        main_site <- "https://ftp.ncbi.nlm.nih.gov/geo"
    } else {
        main_site <- "ftp://ftp.ncbi.nlm.nih.gov/geo"
    }

    # file.path will omit the ending "/" in windows, so we just use paste
    subdir <- .subset(
        c(
            GSE = "series",
            GPL = "platforms",
            GSM = "samples",
            GDS = "datasets"
        ),
        geo_types
    )
    paste(main_site, subdir, super_ids, ids, formats, fnames, sep = "/")
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
parse_file_suffix <- function(format, geo_type) {
    # file.path will add / for "" in the end
    switch(geo_type,
        GDS = switch(format,
            soft = ".soft.gz",
            soft_full = "_full.soft.gz",
            NULL
        ),
        GSE = switch(format,
            soft = "_family.soft.gz",
            miniml = "_family.xml.tgz",
            matrix = "",
            suppl = "",
            NULL
        ),
        GPL = switch(format,
            annot = ".annot.gz",
            miniml = "_family.xml.tgz",
            soft = "_family.soft.gz",
            suppl = "",
            NULL
        ),
        GSM = if (format == "suppl") "" else NULL
    )
}
