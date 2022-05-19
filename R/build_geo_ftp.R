# Programmatic access to GEO-[help](https://ftp.ncbi.nlm.nih.gov/geo/README.txt)
geo_ftp <- "ftp://ftp.ncbi.nlm.nih.gov/geo/"

parse_sub_dir <- function(x) {
    switch(x,
        GSE = "series",
        GPL = "platforms",
        GSM = "samples",
        GDS = "datasets"
    )
}

#' |            type            | GDS | GSE | GPL | GSM |
#' | :------------------------: | :-: | :-: | :-: | :-: |
#' |        SOFT (soft)         |  o  |  o  |  o  |  x  |
#' |    SOFTFULL (soft_full)    |  o  |  x  |  x  |  x  |
#' |      MINiML (miniml)       |  x  |  o  |  o  |  x  |
#' |      Matrix (matrix)       |  x  |  o  |  x  |  x  |
#' |     Annotation (annot)     |  x  |  x  |  o  |  x  |
#' | Supplementaryfiles (suppl) |  x  |  o  |  o  |  o  |

parse_file <- function(id, file_type, geo_type) {
    sub_file <- switch(geo_type,
        GDS = switch(file_type,
            soft = ".soft.gz",
            soft_full = "_full.soft.gz"
        ),
        GSE = switch(file_type,
            soft = "_family.soft.gz",
            miniml = "_family.xml.tgz",
            matrix = "_series_matrx.txt.gz",
            suppl = "_RAW.tar"
        ),
        GPL = switch(file_type,
            annot = ".annot.gz",
            miniml = "_family.xml.tgz",
            soft = "_family.soft.gz",
            suppl = ""
        ),
        GSM = if (identical(file_type, "suppl")) "" else NULL
    )
    if (is.null(sub_file)) rlang::abort("{id} never owns {file_type} file")
    if (nchar(sub_file)) sub_file <- paste0(id, sub_file)
    paste0(file_type, "/", sub_file)
}

build_geo_ftp <- function(id, file_type) {
    id <- toupper(id)
    geo_type <- substr(id, 1, 3)
    file_type <- match.arg(
        tolower(file_type),
        c("soft", "soft_full", "annot", "miniml", "matrix", "suppl")
    )
    super_id <- sub("\\d{1,3}$", "nnn", id, perl = TRUE)
    paste0(
        geo_ftp,
        parse_sub_dir(geo_type), "/",
        super_id, "/", id, "/",
        parse_file(id, file_type, geo_type)
    )
}
