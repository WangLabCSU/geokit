#' Virtual class for holding GEO series, samples, platforms, and datasets.
#'
#' `GEOSoft` class, which contains two slots `meta` and `accession`, is the
#' basic class (super class) of `GEOSeries` class and `GEOData` class.
#' `GEOSeries` class contains extra two slots `gsm` and `gpl` special for `GSE`
#' entity soft file and `GEOData` contains extra two slots `columns` and
#' `datatable` special for GEO samples, platforms, and datasets.
#'
#' @param object A [GEO-class] Class Object.
#' @param value A R object with the same class of corresponding slots.
#' @name GEO-class
#' @docType class
#' @keywords classes
#' @examples
#' gse <- geo("GSE10", odir = tempdir(), gse_matrix = FALSE)
#' accession(gse)
#' gpllist <- gpl(gse)
#' metadata(gpllist[[1L]])
#' accession(gpllist[[1L]])
#' columns(gpllist[[1L]])
#' datatable(gpllist[[1L]])
#' @rdname GEO-class
NULL

# Generic GEO classes:
#' @slot meta: a `list`, containing the header metadata informations.
#' @slot accession: a `character` giving the geo accession id of current GEO
#' series, samples, platforms, and datasets.
#' @rdname GEO-class
methods::setClass(
    "GEOSoft",
    slots = list(
        metadata = "list",
        rcd_type = "character",
        rcd_name = "character",
        accession = "character"
    ),
    prototype = list(
        metadata = list(),
        rcd_type = NA_character_,
        rcd_name = NA_character_,
        accession = NA_character_
    )
)

#' @importFrom methods show
#' @method show GEOSoft
#' @export
#' @rdname GEO-class
methods::setMethod("show", "GEOSoft", function(object) {
    cat("<", methods::is(object)[[1L]], "> ", "\n", sep = "")
    wrap_cat("metadata", names = names(object@metadata))
})

#' @export
#' @rdname GEO-class
methods::setGeneric("metadata", function(object) standardGeneric("metadata"))

#' @export
#' @rdname GEO-class
methods::setGeneric("metadata<-", function(object, value) {
    standardGeneric("metadata<-")
})

#' @method metadata GEOSoft
#' @aliases metadata
#' @export
#' @rdname GEO-class
methods::setMethod("metadata", "GEOSoft", function(object) {
    object@metadata
})

#' @method metadata<- GEOSoft
#' @aliases metadata<-
#' @export
#' @rdname GEO-class
methods::setMethod("metadata<-", "GEOSoft", function(object, value) {
    object@metadata <- value
    object
})

#' @export
#' @rdname GEO-class
methods::setGeneric("accession", function(object) {
    standardGeneric("accession")
})

#' @export
#' @rdname GEO-class
methods::setGeneric("accession<-", function(object, value) {
    standardGeneric("accession<-")
})

#' @method accession GEOSoft
#' @aliases accession
#' @export
#' @rdname GEO-class
methods::setMethod("accession", "GEOSoft", function(object) {
    object@accession
})

#' @method accession<- GEOSoft
#' @aliases accession<-
#' @export
#' @rdname GEO-class
methods::setMethod("accession<-", "GEOSoft", function(object, value) {
    object@accession <- value
    object
})

#' @export
#' @rdname GEO-class
methods::setGeneric("rcd_type", function(object) standardGeneric("rcd_type"))

#' @export
#' @rdname GEO-class
methods::setGeneric("rcd_type<-", function(object, value) {
    standardGeneric("rcd_type<-")
})

#' @method rcd_type GEOSoft
#' @aliases rcd_type
#' @export
#' @rdname GEO-class
methods::setMethod("rcd_type", "GEOSoft", function(object) {
    object@rcd_type
})

#' @method rcd_type<- GEOSoft
#' @aliases rcd_type<-
#' @export
#' @rdname GEO-class
methods::setMethod("rcd_type<-", "GEOSoft", function(object, value) {
    object@rcd_type <- value
    object
})

#' @export
#' @rdname GEO-class
methods::setGeneric("rcd_name", function(object) standardGeneric("rcd_name"))

#' @export
#' @rdname GEO-class
methods::setGeneric("rcd_name<-", function(object, value) {
    standardGeneric("rcd_name<-")
})

#' @method rcd_name GEOSoft
#' @aliases rcd_name
#' @export
#' @rdname GEO-class
methods::setMethod("rcd_name", "GEOSoft", function(object) {
    object@rcd_name
})

#' @method rcd_name<- GEOSoft
#' @aliases rcd_name<-
#' @export
#' @rdname GEO-class
methods::setMethod("rcd_name<-", "GEOSoft", function(object, value) {
    object@rcd_name <- value
    object
})

# Class `GEODatatable` ----
#' @slot columns: A `data.frame` gives the `datatable` header descriptions. The
#' rownmaes of this `data.frame` should be the same with the column names of
#' slot `datatable`.
#' @slot datatable: A `data.frame` shows the data information.
#' @rdname GEO-class
methods::setClass(
    "GEODatatable",
    slots = list(
        datatable = "data.frame",
        columns = "data.frame"
    ),
    prototype = list(
        datatable = data.frame(),
        columns = data.frame(),
        accession = NA_character_
    ),
    contains = "GEOSoft"
)

## Validator ----
methods::setValidity("GEODatatable", function(object) {
    if (!all(rownames(object@columns) == colnames(object@datatable))) {
        "the rownames of slot @columns should be the same with the colnames of slot @datatable."
    } else {
        TRUE
    }
})

#' @method show GEODatatable
#' @export
#' @rdname GEO-class
methods::setMethod("show", "GEODatatable", function(object) {
    cat("<", methods::is(object)[[1L]], "> ", "\n", sep = "")
    datatable_dim <- dim(object@datatable)
    cat(
        strwrap(paste0("datatable: a ", datatable_dim[[1L]], " * ", datatable_dim[[2L]], " data.frame"), exdent = 2L),
        sep = "\n"
    )
    columns_dim <- dim(object@columns)
    cat(
        strwrap(paste0("columns: a ", columns_dim[[1L]], " * ", columns_dim[[2L]], " data.frame"), exdent = 2L),
        sep = "\n"
    )
    wrap_cat("columnsData", names = names(object@columns), 2L, 4L)
    wrap_cat("metadata", names = names(object@metadata))
    wrap_cat("accession", names = object@accession)
})

## Accessors -----
### Accessors `columns` ----
#' @export
#' @rdname GEO-class
methods::setGeneric("columns", function(object) {
    standardGeneric("columns")
})

#' @export
#' @rdname GEO-class
methods::setGeneric("columns<-", function(object, value) {
    standardGeneric("columns<-")
})

#' @method columns GEODatatable
#' @aliases columns
#' @export
#' @rdname GEO-class
methods::setMethod("columns", "GEODatatable", function(object) {
    object@columns
})

#' @method columns<- GEODatatable
#' @aliases columns<-
#' @export
#' @rdname GEO-class
methods::setMethod("columns<-", "GEODatatable", function(object, value) {
    object@columns <- value
    object
})

### Accessors `datatable` ----
#' @export
#' @rdname GEO-class
methods::setGeneric("datatable", function(object) {
    standardGeneric("datatable")
})

#' @export
#' @rdname GEO-class
methods::setGeneric("datatable<-", function(object, value) {
    standardGeneric("datatable<-")
})

#' @method datatable GEODatatable
#' @aliases datatable
#' @export
#' @rdname GEO-class
methods::setMethod("datatable", "GEODatatable", function(object) {
    object@datatable
})

#' @method datatable<- GEODatatable
#' @aliases datatable<-
#' @export
#' @rdname GEO-class
methods::setMethod("datatable<-", "GEODatatable", function(object, value) {
    object@datatable <- value
    object
})

# Class `GEOPlatform` --------------------------------------------
#' @slot gsm: a list of `GEODatatable` object containg the samples information
#' of current GEO platform.
#' @slot gse: a list of `GEODatatable` object containg the series information
#' of current GEO platform.
#' @rdname GEO-class
methods::setClass(
    "GEOPlatform",
    slots = list(gsm = "list", gse = "list"),
    prototype = list(
        gsm = list(),
        gse = list()
    ),
    contains = "GEODatatable"
)

## Validator ----
methods::setValidity("GEOPlatform", function(object) {
    if (!all(vapply(object@gsm, function(x) {
        methods::is(x, "GEODatatable")
    }, logical(1L), USE.NAMES = FALSE))) {
        "the element of slot @gsm list should only contain Class `GEODatatable` object."
    } else if (!all(vapply(object@gse, function(x) {
        methods::is(x, "GEODatatable")
    }, logical(1L), USE.NAMES = FALSE))) {
        "the element of slot @gpl list should only contain Class `GEODatatable` object."
    } else {
        TRUE
    }
})

#' @method show GEOPlatform
#' @export
#' @rdname GEO-class
methods::setMethod("show", "GEOPlatform", function(object) {
    cat("<", methods::is(object)[[1L]], "> ", "\n", sep = "")
    wrap_cat("gse", names = vapply(object@gse, rcd_name, character(1L)))
    wrap_cat("gsm", names = vapply(object@gsm, rcd_name, character(1L)))
    wrap_cat("metadata", names = names(object@metadata))
    wrap_cat("accession", names = object@accession)
})

## Accessors -----
### Accessors `gsm` ----
#' @export
#' @rdname GEO-class
methods::setGeneric("gsm", function(object) {
    standardGeneric("gsm")
})

#' @export
#' @rdname GEO-class
methods::setGeneric("gsm<-", function(object, value) {
    standardGeneric("gsm<-")
})

#' @method gsm GEOPlatform
#' @aliases gsm
#' @export
#' @rdname GEO-class
methods::setMethod("gsm", "GEOPlatform", function(object) {
    object@gsm
})

#' @method gsm<- GEOPlatform
#' @aliases gsm<-
#' @export
#' @rdname GEO-class
methods::setMethod("gsm<-", "GEOPlatform", function(object, value) {
    object@gsm <- value
    object
})

### Accessors `gse` ----
#' @export
#' @rdname GEO-class
methods::setGeneric("gse", function(object) {
    standardGeneric("gse")
})

#' @export
#' @rdname GEO-class
methods::setGeneric("gse<-", function(object, value) {
    standardGeneric("gse<-")
})

#' @method gse GEOPlatform
#' @aliases gse
#' @export
#' @rdname GEO-class
methods::setMethod("gse", "GEOPlatform", function(object) {
    object@gse
})

#' @method gse<- GEOPlatform
#' @aliases gse<-
#' @export
#' @rdname GEO-class
methods::setMethod("gse<-", "GEOPlatform", function(object, value) {
    object@gse <- value
    object
})

# Class `GEOSeries` --------------------------------------------
#' @slot gsm: a list of `GEODatatable` object containg the samples information
#' of current GEO series.
#' @slot gpl: a list of `GEODatatable` object containg the platforms information
#' of current GEO series.
#' @rdname GEO-class
methods::setClass(
    "GEOSeries",
    slots = list(gsm = "list", gpl = "list"),
    prototype = list(
        gsm = list(),
        gpl = list()
    ),
    contains = "GEOSoft"
)

## Validator ----
methods::setValidity("GEOSeries", function(object) {
    if (!all(vapply(object@gsm, function(x) {
        methods::is(x, "GEODatatable")
    }, logical(1L), USE.NAMES = FALSE))) {
        "the element of slot @gsm list should only contain Class `GEODatatable` object."
    } else if (!all(vapply(object@gpl, function(x) {
        methods::is(x, "GEODatatable")
    }, logical(1L), USE.NAMES = FALSE))) {
        "the element of slot @gpl list should only contain Class `GEODatatable` object."
    } else {
        TRUE
    }
})

#' @method show GEOSeries
#' @export
#' @rdname GEO-class
methods::setMethod("show", "GEOSeries", function(object) {
    cat("<", methods::is(object)[[1L]], "> ", "\n", sep = "")
    wrap_cat("gsm", names = vapply(object@gsm, rcd_name, character(1L)))
    wrap_cat("gpl", names = vapply(object@gpl, rcd_name, character(1L)))
    wrap_cat("metadata", names = names(object@metadata))
    wrap_cat("accession", names = object@accession)
})

## Accessors -----
### Accessors `gsm` ----
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
    object
})

### Accessors `gpl` ----
#' @export
#' @rdname GEO-class
methods::setGeneric("gpl", function(object) {
    standardGeneric("gpl")
})

#' @export
#' @rdname GEO-class
methods::setGeneric("gpl<-", function(object, value) {
    standardGeneric("gpl<-")
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
    object
})
