# Generic GEO classes:
methods::setClass(
    "GEOData",
    slots = list(
        meta = "list",
        accession = "character"
    ),
    prototype = list(
        meta = list(),
        accession = NA_character_
    )
)

methods::setGeneric("meta", function(object) {
    methods::makeStandardGeneric("meta")
})
methods::setGeneric("meta<-", function(object, value) {
    methods::makeStandardGeneric("meta<-")
})

#' @noRd
methods::setMethod("meta", "GEOData", function(object) {
    object@meta
})

#' @noRd
methods::setMethod("meta<-", "GEOData", function(object, value) {
    object@meta <- value
    methods::validObject(object)
    object
})

methods::setGeneric("accession", function(object) {
    methods::makeStandardGeneric("accession")
})
methods::setGeneric("accession<-", function(object, value) {
    methods::makeStandardGeneric("accession<-")
})

#' @noRd
methods::setMethod("accession", "GEOData", function(object) {
    object@accession
})

#' @noRd
methods::setMethod("accession<-", "GEOData", function(object, value) {
    object@accession <- value
    methods::validObject(object)
    object
})

# Class `GSE` ----
methods::setClass(
    "GSE", 
    slots = list(gsm = "list", gpl = "list"),
    prototype = list(
        gsm = list(), 
        gpl = list()
    ),
    contains = "GEOData"
)

## Validator ----
methods::setValidity("GSE", function(object) {
    if (!all(vapply(object@gsm, function(x) {
        methods::is(x, "GSM")
    }, logical(1L)))) {
        "the element of @gsm list should contain Class `GSM` object."
    } else if (!all(vapply(object@gpl, function(x) {
        methods::is(x, "GPL")
    }, logical(1L)))) {
        "the element of @gpl list should contain Class `GPL` object."
    } else {
        TRUE
    }
})

## Accessors -----
### Accessors `gsm` ---- 
methods::setGeneric("gsm", function(object) {
    methods::makeStandardGeneric("gsm")
})
methods::setGeneric("gsm<-", function(object, value) {
    methods::makeStandardGeneric("gsm<-")
})
#' @noRd
methods::setMethod("gsm", "GSE", function(object) {
    object@gsm
})

#' @noRd
methods::setMethod("gsm<-", "GSE", function(object, value) {
    object@gsm <- value
    methods::validObject(object)
    object
})

### Accessors `gpl` ----
methods::setGeneric("gpl", function(object) {
    methods::makeStandardGeneric("gpl")
})
methods::setGeneric("gpl<-", function(object, value) {
    methods::makeStandardGeneric("gpl<-")
})
methods::setMethod("gpl", "GSE", function(object) {
    object@gpl
})
methods::setMethod("gpl<-", "GSE", function(object, value) {
    object@gpl <- value
    methods::validObject(object)
    object
})

# Class `GEODataTable` ----
methods::setClass(
    "GEODataTable",
    slots = list(
        columns = "data.frame",
        datatable = "data.frame"
    ),
    prototype = list(
        columns = data.frame(),
        datatable = data.frame()
    ),
    contains = "GEOData"
)

## Accessors -----
### Accessors `columns` ----
methods::setGeneric("columns", function(object) {
    methods::makeStandardGeneric("columns")
})
methods::setGeneric("columns<-", function(object, value) {
    methods::makeStandardGeneric("columns<-")
})
#' @noRd
methods::setMethod("columns", "GEODataTable", function(object) {
    object@columns
})

#' @noRd
methods::setMethod("columns<-", "GEODataTable", function(object, value) {
    object@columns <- value
    methods::validObject(object)
    object
})

### Accessors `datatable` ----
methods::setGeneric("datatable", function(object) {
    methods::makeStandardGeneric("datatable")
})
methods::setGeneric("datatable<-", function(object, value) {
    methods::makeStandardGeneric("datatable<-")
})
methods::setMethod("datatable", "GEODataTable", function(object) {
    object@datatable
})
methods::setMethod("datatable<-", "GEODataTable", function(object, value) {
    object@datatable <- value
    methods::validObject(object)
    object
})

methods::setClass(
    "GPL", 
    contains = "GEODataTable"
)
methods::setClass(
    "GSM", 
    contains = "GEODataTable"
)

##' @importClassesFrom Biobase AnnotatedDataFrame
#' @noRd
methods::setClass(
    "AnnotatedDataFrameWithMeta",
    slots = c(
        meta = "list"
    ),
    contains = "AnnotatedDataFrame",
    prototype = list(
        meta = list()
    )
)

#' SubClass of AnnotatedDataFrame wiht extra meta data
#'
#' An AnnotatedDataFrameWithMeta object is a subclass of
#' [AnnotatedDataFrame](Biobase::AnnotatedDataFrame), which extends it by a
#' slots `meta` contaning the metadata from GPL or GSM in GEO database. You can
#' use `meta()` accessor function to get it.
#'
#' @slot data: A data.frame containing samples (rows) and measured variables
#' (columns).
#' @slot dimLabels: A character vector of length 2 that provides labels for the
#' rows and columns in the show method.
#' @slot varMetadata: A data.frame with number of rows equal number of columns
#' in data, and at least one column, named labelDescription, containing a
#' textual description of each variable.
#' @slot meta: a list of meta data.
#' @slot .__classVersion__: A Versions object describing the R and Biobase
#' version numbers used to created the instance. Intended for developer use.
#'
#' @seealso For methods, please see
#' [AnnotatedDataFrame](Biobase::AnnotatedDataFrame)
#' @section Creating Objects:
#' `AnnotatedDataFrameWithMeta(data, varMetadata, dimLabels=c("rowNames",
#' "columnNames"), meta = list())`
#'
#' `AnnotatedDataFrameWithMeta` instances are created using
#' `AnnotatedDataFrameWithMeta()`. The function can take four arguments, data is
#' a data.frame of the samples (rows) and measured variables (columns).
#' varMetadata is a data.frame with the number of rows equal to the number of
#' columns of the data argument. varMetadata describes aspects of each measured
#' variable. dimLabels provides aesthetic control for labeling rows and columns
#' in the show method. meta is a list of meta data, varMetadata, dimLabels and
#' meta can be missing.
#' @name AnnotatedDataFrameWithMeta-Class
#' @rdname AnnotatedDataFrameWithMeta
NULL

#' @noRd
AnnotatedDataFrameWithMeta <- function(data, varMetadata, dimLabels = c("rowNames", "columnNames"), meta = list()) {
    methods::new(
        "AnnotatedDataFrameWithMeta",
        data = data,
        varMetadata = varMetadata,
        dimLabels = dimLabels,
        meta = meta
    )
}

##' @importFrom methods show
#' @noRd
methods::setMethod("show", "AnnotatedDataFrameWithMeta", function(object) {
    methods::callNextMethod()
    wrap_cat("meta", names(meta(object)))
})
