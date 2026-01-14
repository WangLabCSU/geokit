#' Virtual class for holding GEO series, samples, platforms, and datasets.
#'
#' `GEOSoft` class, which contains two slots `meta` and `accession`, is the
#' basic class (super class) of `GEOSeries` class and `GEOData` class.
#' `GEOSeries` class contains extra two slots `gsm` and `gpl` special for `GSE`
#' entity soft file and `GEOData` contains extra two slots `columns` and
#' `datatable` special for GEO samples, platforms, and datasets.
#'
#' @param object A [GEOSoft][GEOSoft-class] Class Object.
#' @param value A R object with the same class of corresponding slots.
#' @name GEOSoft-class
#' @docType class
#' @keywords internal
#' @examples
#' gse <- geo_soft("GSE10", odir = tempdir())
#' accession(gse)
#' gpllist <- gpl(gse)
#' metadata(gpllist[[1L]])
#' accession(gpllist[[1L]])
#' columns(gpllist[[1L]])
#' datatable(gpllist[[1L]])
#' @rdname GEOSoft-class
NULL

# Generic GEO classes:
#' @slot metadata: a `list`, containing the header metadata informations.
#' @slot rcd_type A `character` indicating the type of record (e.g., Platform,
#' Sample, Series, Datasets).
#' @slot rcd_name A `character` representing the name associated with the record
#' (e.g., the GEO dataset name). It usually matches the `accession`, but may
#' differ in some cases.
#' @slot accession: a `character` giving the geo accession id of current GEO
#' series, samples, platforms, and datasets.
#' @slot columns: A `data.frame` gives the `datatable` header descriptions. The
#' rownmaes of this `data.frame` should be the same with the column names of
#' slot `datatable`.
#' @slot datatable: A `data.frame` shows the data information.
#' @rdname GEOSoft-class
methods::setClass(
    "GEOSoft",
    slots = list(
        metadata = "list",
        rcd_type = "character",
        rcd_name = "character",
        accession = "character",
        columns = "data.frame",
        datatable = "data.frame"
    ),
    prototype = list(
        metadata = list(),
        rcd_type = NA_character_,
        rcd_name = NA_character_,
        accession = NA_character_,
        columns = data.frame(),
        datatable = data.frame()
    )
)

methods::setValidity("GEOSoft", function(object) {
    if (!all(rownames(object@columns) == colnames(object@datatable))) {
        "the rownames of slot @columns should be the same with the colnames of slot @datatable."
    } else {
        TRUE
    }
})

#' @importFrom methods show
#' @method show GEOSoft
#' @export
#' @rdname GEOSoft-class
methods::setMethod("show", "GEOSoft", function(object) {
    cat("<", methods::is(object)[[1L]], "> ", "\n", sep = "")
    datatable_dim <- dim(object@datatable)
    cat(
        strwrap(paste0("datatable: a ", datatable_dim[[1L]], " * ", datatable_dim[[2L]], " data.frame"), exdent = 2L),
        sep = "\n"
    )
    if (datatable_dim[2L]) {
        wrap_cat("datatable vars", names = names(object@datatable), 2L, 4L)
    }

    columns_dim <- dim(object@columns)
    cat(
        strwrap(paste0("columns: a ", columns_dim[[1L]], " * ", columns_dim[[2L]], " data.frame"), exdent = 2L),
        sep = "\n"
    )
    if (columns_dim[2L]) {
        wrap_cat("columns vars", names = names(object@columns), 2L, 4L)
    }
    wrap_cat("metadata", names = names(object@metadata))
    wrap_cat("accession", names = object@accession)
})

#' @export
#' @rdname GEOSoft-class
methods::setGeneric("metadata", function(object) standardGeneric("metadata"))

#' @export
#' @rdname GEOSoft-class
methods::setGeneric("metadata<-", function(object, value) {
    standardGeneric("metadata<-")
})

#' @method metadata GEOSoft
#' @aliases metadata
#' @export
#' @rdname GEOSoft-class
methods::setMethod("metadata", "GEOSoft", function(object) {
    object@metadata
})

#' @method metadata<- GEOSoft
#' @aliases metadata<-
#' @export
#' @rdname GEOSoft-class
methods::setMethod("metadata<-", "GEOSoft", function(object, value) {
    object@metadata <- value
    object
})

#' @export
#' @rdname GEOSoft-class
methods::setGeneric("accession", function(object) {
    standardGeneric("accession")
})

#' @export
#' @rdname GEOSoft-class
methods::setGeneric("accession<-", function(object, value) {
    standardGeneric("accession<-")
})

#' @method accession GEOSoft
#' @aliases accession
#' @export
#' @rdname GEOSoft-class
methods::setMethod("accession", "GEOSoft", function(object) {
    object@accession
})

#' @method accession<- GEOSoft
#' @aliases accession<-
#' @export
#' @rdname GEOSoft-class
methods::setMethod("accession<-", "GEOSoft", function(object, value) {
    object@accession <- value
    object
})

#' @export
#' @rdname GEOSoft-class
methods::setGeneric("rcd_type", function(object) standardGeneric("rcd_type"))

#' @export
#' @rdname GEOSoft-class
methods::setGeneric("rcd_type<-", function(object, value) {
    standardGeneric("rcd_type<-")
})

#' @method rcd_type GEOSoft
#' @aliases rcd_type
#' @export
#' @rdname GEOSoft-class
methods::setMethod("rcd_type", "GEOSoft", function(object) {
    object@rcd_type
})

#' @method rcd_type<- GEOSoft
#' @aliases rcd_type<-
#' @export
#' @rdname GEOSoft-class
methods::setMethod("rcd_type<-", "GEOSoft", function(object, value) {
    object@rcd_type <- value
    object
})

#' @export
#' @rdname GEOSoft-class
methods::setGeneric("rcd_name", function(object) standardGeneric("rcd_name"))

#' @export
#' @rdname GEOSoft-class
methods::setGeneric("rcd_name<-", function(object, value) {
    standardGeneric("rcd_name<-")
})

#' @method rcd_name GEOSoft
#' @aliases rcd_name
#' @export
#' @rdname GEOSoft-class
methods::setMethod("rcd_name", "GEOSoft", function(object) {
    object@rcd_name
})

#' @method rcd_name<- GEOSoft
#' @aliases rcd_name<-
#' @export
#' @rdname GEOSoft-class
methods::setMethod("rcd_name<-", "GEOSoft", function(object, value) {
    object@rcd_name <- value
    object
})

#' @export
#' @rdname GEOSoft-class
methods::setGeneric("columns", function(object) {
    standardGeneric("columns")
})

#' @export
#' @rdname GEOSoft-class
methods::setGeneric("columns<-", function(object, value) {
    standardGeneric("columns<-")
})

#' @method columns GEOSoft
#' @aliases columns
#' @export
#' @rdname GEOSoft-class
methods::setMethod("columns", "GEOSoft", function(object) {
    object@columns
})

#' @method columns<- GEOSoft
#' @aliases columns<-
#' @export
#' @rdname GEOSoft-class
methods::setMethod("columns<-", "GEOSoft", function(object, value) {
    object@columns <- value
    object
})

#' @export
#' @rdname GEOSoft-class
methods::setGeneric("datatable", function(object) {
    standardGeneric("datatable")
})

#' @export
#' @rdname GEOSoft-class
methods::setGeneric("datatable<-", function(object, value) {
    standardGeneric("datatable<-")
})

#' @method datatable GEOSoft
#' @aliases datatable
#' @export
#' @rdname GEOSoft-class
methods::setMethod("datatable", "GEOSoft", function(object) {
    object@datatable
})

#' @method datatable<- GEOSoft
#' @aliases datatable<-
#' @export
#' @rdname GEOSoft-class
methods::setMethod("datatable<-", "GEOSoft", function(object, value) {
    object@datatable <- value
    object
})

# Class `GEOPlatform` --------------------------------------------
#' @slot gsm: a list of `GEOSoft` object containg the samples information
#' of current GEO platform.
#' @slot gse: a list of `GEOSoft` object containg the series information
#' of current GEO platform.
#' @rdname GEOSoft-class
methods::setClass(
    "GEOPlatform",
    slots = list(gsm = "list", gse = "list"),
    prototype = list(
        gsm = list(),
        gse = list()
    ),
    contains = "GEOSoft"
)

## Validator ----
methods::setValidity("GEOPlatform", function(object) {
    if (!all(vapply(object@gsm, function(x) {
        methods::is(x, "GEOSoft")
    }, logical(1L), USE.NAMES = FALSE))) {
        "the element of slot @gsm list should only contain Class `GEOSoft` object."
    } else if (!all(vapply(object@gse, function(x) {
        methods::is(x, "GEOSoft")
    }, logical(1L), USE.NAMES = FALSE))) {
        "the element of slot @gpl list should only contain Class `GEOSoft` object."
    } else {
        TRUE
    }
})

#' @method show GEOPlatform
#' @export
#' @rdname GEOSoft-class
methods::setMethod("show", "GEOPlatform", function(object) {
    cat("<", methods::is(object)[[1L]], "> ", "\n", sep = "")
    wrap_cat("gse", names = vapply(object@gse, rcd_name, character(1L)))
    wrap_cat("gsm", names = vapply(object@gsm, rcd_name, character(1L)))
    datatable_dim <- dim(object@datatable)
    cat(
        strwrap(paste0("datatable: a ", datatable_dim[[1L]], " * ", datatable_dim[[2L]], " data.frame"), exdent = 2L),
        sep = "\n"
    )
    if (datatable_dim[2L]) {
        wrap_cat("datatable vars", names = names(object@datatable), 2L, 4L)
    }

    columns_dim <- dim(object@columns)
    cat(
        strwrap(paste0("columns: a ", columns_dim[[1L]], " * ", columns_dim[[2L]], " data.frame"), exdent = 2L),
        sep = "\n"
    )
    if (columns_dim[2L]) {
        wrap_cat("columns vars", names = names(object@columns), 2L, 4L)
    }
    wrap_cat("columns", names = names(object@columns), 2L, 4L)
    wrap_cat("metadata", names = names(object@metadata))
    wrap_cat("accession", names = object@accession)
})

## Accessors -----
### Accessors `gsm` ----
#' @export
#' @rdname GEOSoft-class
methods::setGeneric("gsm", function(object) {
    standardGeneric("gsm")
})

#' @export
#' @rdname GEOSoft-class
methods::setGeneric("gsm<-", function(object, value) {
    standardGeneric("gsm<-")
})

#' @method gsm GEOPlatform
#' @aliases gsm
#' @export
#' @rdname GEOSoft-class
methods::setMethod("gsm", "GEOPlatform", function(object) {
    object@gsm
})

#' @method gsm<- GEOPlatform
#' @aliases gsm<-
#' @export
#' @rdname GEOSoft-class
methods::setMethod("gsm<-", "GEOPlatform", function(object, value) {
    object@gsm <- value
    object
})

### Accessors `gse` ----
#' @export
#' @rdname GEOSoft-class
methods::setGeneric("gse", function(object) {
    standardGeneric("gse")
})

#' @export
#' @rdname GEOSoft-class
methods::setGeneric("gse<-", function(object, value) {
    standardGeneric("gse<-")
})

#' @method gse GEOPlatform
#' @aliases gse
#' @export
#' @rdname GEOSoft-class
methods::setMethod("gse", "GEOPlatform", function(object) {
    object@gse
})

#' @method gse<- GEOPlatform
#' @aliases gse<-
#' @export
#' @rdname GEOSoft-class
methods::setMethod("gse<-", "GEOPlatform", function(object, value) {
    object@gse <- value
    object
})

# Class `GEOSeries` --------------------------------------------
#' @slot gpl: a list of `GEOSoft` object containg the platforms information
#' of current GEO series.
#' @rdname GEOSoft-class
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
        methods::is(x, "GEOSoft")
    }, logical(1L), USE.NAMES = FALSE))) {
        "the element of slot @gsm list should only contain Class `GEOSoft` object."
    } else if (!all(vapply(object@gpl, function(x) {
        methods::is(x, "GEOSoft")
    }, logical(1L), USE.NAMES = FALSE))) {
        "the element of slot @gpl list should only contain Class `GEOSoft` object."
    } else {
        TRUE
    }
})

#' @method show GEOSeries
#' @export
#' @rdname GEOSoft-class
methods::setMethod("show", "GEOSeries", function(object) {
    cat("<", methods::is(object)[[1L]], "> ", "\n", sep = "")
    wrap_cat("gsm", names = vapply(object@gsm, rcd_name, character(1L)))
    wrap_cat("gpl", names = vapply(object@gpl, rcd_name, character(1L)))
    datatable_dim <- dim(object@datatable)
    cat(
        strwrap(paste0("datatable: a ", datatable_dim[[1L]], " * ", datatable_dim[[2L]], " data.frame"), exdent = 2L),
        sep = "\n"
    )
    if (datatable_dim[2L]) {
        wrap_cat("datatable vars", names = names(object@datatable), 2L, 4L)
    }

    columns_dim <- dim(object@columns)
    cat(
        strwrap(paste0("columns: a ", columns_dim[[1L]], " * ", columns_dim[[2L]], " data.frame"), exdent = 2L),
        sep = "\n"
    )
    if (columns_dim[2L]) {
        wrap_cat("columns vars", names = names(object@columns), 2L, 4L)
    }
    wrap_cat("metadata", names = names(object@metadata))
    wrap_cat("accession", names = object@accession)
})

## Accessors -----
### Accessors `gsm` ----
#' @method gsm GEOSeries
#' @aliases gsm
#' @export
#' @rdname GEOSoft-class
methods::setMethod("gsm", "GEOSeries", function(object) {
    object@gsm
})

#' @method gsm<- GEOSeries
#' @aliases gsm<-
#' @export
#' @rdname GEOSoft-class
methods::setMethod("gsm<-", "GEOSeries", function(object, value) {
    object@gsm <- value
    object
})

### Accessors `gpl` ----
#' @export
#' @rdname GEOSoft-class
methods::setGeneric("gpl", function(object) {
    standardGeneric("gpl")
})

#' @export
#' @rdname GEOSoft-class
methods::setGeneric("gpl<-", function(object, value) {
    standardGeneric("gpl<-")
})

#' @method gpl GEOSeries
#' @aliases gpl
#' @export
#' @rdname GEOSoft-class
methods::setMethod("gpl", "GEOSeries", function(object) {
    object@gpl
})

#' @method gpl<- GEOSeries
#' @aliases gpl<-
#' @export
#' @rdname GEOSoft-class
methods::setMethod("gpl<-", "GEOSeries", function(object, value) {
    object@gpl <- value
    object
})
