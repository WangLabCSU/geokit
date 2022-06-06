#' Virtual class for holding GEO series, samples, platforms, and datasets.
#'
#' `GEOData` class, which contains two slots `meta` and `accession`, is the
#' basic class (super class) of `GSE` class and `GEODataTable` class.
#' `GEOSeries` class contains extra two slots `gsm` and `gpl` special for `GSE`
#' entity soft file and `GEODataTable` contains extra two slots `columns` and
#' `datatable` special for GEO samples, platforms, and datasets.
#' 
#' @param object A [GEO-class] Class Object.
#' @param value A R object with the same class of corresponding slots.
#' @name GEO-class
#' @docType class
#' @keywords classes
#' @examples
#'  gse <- rgeo::get_geo("GSE10", tempdir(), gse_matrix = FALSE)
#'  accession(gse)
#'  gpllist <- gpl(gse)
#'  meta(gpllist[[1]])
#'  accession(gpllist[[1]])
#'  columns(gpllist[[1]])
#'  datatable(gpllist[[1]])
#' @rdname GEO-class
NULL

# Generic GEO classes:
#' @slot meta: a `list`, containing the header metadata informations.
#' @slot accession: a `character` giving the geo accession id of current GEO
#' series, samples, platforms, and datasets.
#' @rdname GEO-class
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

#' @method meta GEOData
#' @aliases meta
#' @export
#' @rdname GEO-class
methods::setMethod("meta", "GEOData", function(object) {
    object@meta
})

#' @method meta<- GEOData
#' @aliases meta<-
#' @export
#' @rdname GEO-class
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

#' @method accession GEOData
#' @aliases accession
#' @export
#' @rdname GEO-class
methods::setMethod("accession", "GEOData", function(object) {
    object@accession
})

#' @method accession<- GEOData
#' @aliases accession<-
#' @export
#' @rdname GEO-class
methods::setMethod("accession<-", "GEOData", function(object, value) {
    object@accession <- value
    methods::validObject(object)
    object
})

# Class `GEODataTable` ----
#' @slot columns: A `data.frame` gives the `datatable` header descriptions. The
#' rownmaes of this `data.frame` should be the same with the column names of
#' slot `datatable`.
#' @slot datatable: A `data.frame` shows the data information.
#' @rdname GEO-class
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
        "the rownames of slot @columns should be the same with the colunames of slot @datatable."
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

#' @method columns GEODataTable
#' @aliases columns
#' @export
#' @rdname GEO-class
methods::setMethod("columns", "GEODataTable", function(object) {
    object@columns
})

#' @method columns<- GEODataTable
#' @aliases columns<-
#' @export
#' @rdname GEO-class
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
#' @method datatable GEODataTable
#' @aliases datatable
#' @export
#' @rdname GEO-class
methods::setMethod("datatable", "GEODataTable", function(object) {
    object@datatable
})
#' @method datatable<- GEODataTable
#' @aliases datatable<-
#' @export
#' @rdname GEO-class
methods::setMethod("datatable<-", "GEODataTable", function(object, value) {
    object@datatable <- value
    methods::validObject(object)
    object
})

# Class `GEOSeries` ----
#' @slot gsm: a list of `GEODataTable` object containg the samples information
#' of current GEO series.
#' @slot gpl: a list of `GEODataTable` object containg the platforms information
#' of current GEO series.
#' @rdname GEO-class
methods::setClass(
    "GEOSeries", 
    slots = list(gsm = "list", gpl = "list"),
    prototype = list(
        gsm = list(), 
        gpl = list()
    ),
    contains = "GEOData"
)

## Validator ----
methods::setValidity("GEOSeries", function(object) {
    if (!all(vapply(object@gsm, function(x) {
        methods::is(x, "GEODataTable")
    }, logical(1L)))) {
        "the element of slot @gsm list should only contain Class `GEODataTable` object."
    } else if (!all(vapply(object@gpl, function(x) {
        methods::is(x, "GEODataTable")
    }, logical(1L)))) {
        "the element of slot @gpl list should only contain Class `GEODataTable` object."
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
#' @method gsm GEOSeries
#' @aliases gsm
#' @export
#' @rdname GEO-class
methods::setMethod("gsm", "GEOSeries", function(object) {
    object@gsm
})

#' @method gsm<- GEOSeries
#' @aliases gsm<-
#' @export
#' @rdname GEO-class
methods::setMethod("gsm<-", "GEOSeries", function(object, value) {
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
#' @method gpl GEOSeries
#' @aliases gpl
#' @export
#' @rdname GEO-class
methods::setMethod("gpl", "GEOSeries", function(object) {
    object@gpl
})
#' @method gpl<- GEOSeries
#' @aliases gpl<-
#' @export
#' @rdname GEO-class
methods::setMethod("gpl<-", "GEOSeries", function(object, value) {
    object@gpl <- value
    methods::validObject(object)
    object
})
