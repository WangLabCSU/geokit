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
        "the element of slot @gsm list should only contain Class `GSM` object."
    } else if (!all(vapply(object@gpl, function(x) {
        methods::is(x, "GPL")
    }, logical(1L)))) {
        "the element of slot @gpl list should only contain Class `GPL` object."
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

## Validator ----
methods::setValidity("GEODataTable", function(object) {
    if (!all(rownames(object@columns) == colnames(object@datatable))) {
        "the rownames of slot @columns should be the same with slot @datatable."
    } else {
        TRUE
    }
})

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
methods::setClass(
    "GDS", 
    contains = "GEODataTable"
)
