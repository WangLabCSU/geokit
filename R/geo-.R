#' GEO accession type
#'
#' Determine the type of a GEO accession ID (e.g. DataSet, Series, Sample,
#' Platform). This function inspects the accession prefix and returns its
#' corresponding GEO type, optionally in an abbreviated form.
#'
#' @param accession A character string of GEO accession ID. Examples:
#'   - DataSets (GDS): `"GDS505"`, `"GDS606"`, `"GDS1234"`, `"GDS9999"`, etc.
#'   - Series (GSE): `"GSE2"`, `"GSE22"`, `"GSE100"`, `"GSE2000"`, etc.
#'   - Platforms (GPL): `"GPL96"`, `"GPL570"`, `"GPL10558"`, etc.
#'   - Samples (GSM): `"GSM12345"`, `"GSM67890"`, `"GSM112233"`, etc.
#' @param abbre A logical scalar indicating whether to abbreviate the GEO type
#'   in the return value. If `FALSE` (default), the full type name is returned;
#'   if `TRUE`, a short abbreviation is used.
#' @return A character string of GEO accession type.
#' @export
geo_gtype <- function(accession, abbre = FALSE) {
    assert_string(accession)
    assert_bool(abbre)
    rust_call("geo_gtype", accession, abbre)
}

#' GEO URL resolver
#'
#' Construct and resolve URLs for GEO (Gene Expression Omnibus) resources. This
#' function provides a unified interface for accessing GEO data either via
#' NCBI’s accession-based query system or directly from GEO FTP/HTTPS servers.
#' Depending on the accession type or requested `famount`, it automatically
#' generates the correct URL.
#'
#' @inheritParams geo_gtype
#' @param famount A character string specifying file/amount type requested. GEO
#' data can be accessed through two sites:
#'
#'   - Direct FTP/HTTPS file retrieval from GEO FTP server (file type):
#'
#'      * `"soft"`: SOFT (Simple Omnibus in Text Format) from GEO FTP site. When
#'        `accession` is `DataSets` or `Series`, this is the default.
#'      * `"soft_full"`: full SOFT (Simple Omnibus in Text Format) files from
#'         GEO FTP site by DataSet (GDS) containging additionally contains
#'         up-to-date gene annotation for the DataSet Platform.
#'      * `"minimal"`: MINiML (MIAME Notation in Markup Language, pronounced
#'        minimal) is an XML format that incorporates experimental data and
#'        metadata. MINiML is essentially an XML rendering of SOFT format.
#'      * `"matrix"`: Series matrix file.
#'      * `"annot"`: annotation files for Platforms.
#'      * `"suppl"`: supplementary files.
#'
#'      The following table summarizes the compatibility between GEO accession
#'      types and `famount` options:
#'
#'        |           famount          | GDS | GSE | GPL | GSM |
#'        | :------------------------: | :-: | :-: | :-: | :-: |
#'        |        SOFT (soft)         |  o  |  o  |  o  |  x  |
#'        |    SOFTFULL (soft_full)    |  o  |  x  |  x  |  x  |
#'        |      MINiML (miniml)       |  x  |  o  |  o  |  x  |
#'        |      Matrix (matrix)       |  x  |  o  |  x  |  x  |
#'        |     Annotation (annot)     |  x  |  x  |  o  |  x  |
#'        | Supplementaryfiles (suppl) |  x  |  o  |  o  |  o  |
#'
#'   - Accession-based queries to the NCBI GEO database (amount of data):
#'      * `"none"`: Only for DataSets; this is the sole valid option.
#'      * `"brief"`: accession attributes only.
#'      * `"quick"`: accession attributes + first **20** rows of the data table.
#'      * `"data"`: omits the accession's attributes, showing only links to
#'        other accessions and the full data table.
#'      * `"full"`: accession attributes + complete data table.
#'
#' @param scope A character string specifying which GEO accessions to include
#' (Only applicable to NCBI GEO database access).
#'   - `"none"`: Only for DataSets; this is the sole valid option.
#'   - `"self"`: the queried accession only.
#'   - `"gsm"`, `"gpl"`, `"gse"`: related samples, platforms, or series.
#'   - `"all"`: all accessions related to the query (family view).
#'
#' @param format A character string specifying the output format (Only
#' applicable to NCBI GEO database access):
#'   - `"none"`: Only for DataSets; this is the sole valid option (no
#'     downloadable entry available).
#'   - `"text"`: machine-readable SOFT format (Simple Omnibus Format in Text).
#'   - `"xml"`: XML format.
#'   - `"html"`: human-readable format with hyperlinks (no downloadable entry
#'     available).
#'
#' @param over_https Logical scalar. If `TRUE`, connects to GEO FTP server via
#'   HTTPS (<https://ftp.ncbi.nlm.nih.gov/geo>); otherwise uses plain FTP
#'   (<ftp://ftp.ncbi.nlm.nih.gov/geo>). Only applicable to GEO FTP server
#'   access.
#' @return A character string of GEO URL.
#' @export
geo_url <- function(accession, famount = NULL, scope = NULL, format = NULL,
                    over_https = NULL) {
    assert_string(accession)
    assert_string(famount, allow_null = TRUE)
    assert_string(scope, allow_null = TRUE)
    assert_string(format, allow_null = TRUE)
    assert_bool(over_https)
    rust_call("geo_url", accession, famount, scope, format, over_https)
}

#' Open the GEO landing page in a browser
#'
#' Construct a GEO landing page and open it directly in the system's default web
#' browser (or a user-specified browser).
#'
#' @inheritParams geo_url
#' @inheritParams utils::browseURL
#' @details See [utils::browseURL()]
#' @export
geo_show <- function(accession, famount = NULL, scope = NULL,
                     over_https = NULL, browser = getOption("browser")) {
    utils::browseURL(
        rust_call("geo_landing_url", accession, famount, scope, over_https),
        browser = browser
    )
}
