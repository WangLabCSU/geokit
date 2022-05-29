#' @importClassesFrom Biobase AnnotatedDataFrame
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
#' @section Class-specific slots:
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
#' @name AnnotatedDataFrameWithMeta-Class
#' @rdname AnnotatedDataFrameWithMeta
NULL

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
#' @export 
#' @rdname AnnotatedDataFrameWithMeta
AnnotatedDataFrameWithMeta <- function(data, varMetadata, dimLabels = c("rowNames", "columnNames"), meta = list()) {
    methods::new(
        "AnnotatedDataFrameWithMeta",
        data = data,
        varMetadata = varMetadata,
        dimLabels = dimLabels,
        meta = meta
    )
}

methods::setGeneric("meta", function(object) {
    methods::makeStandardGeneric("meta")
})
methods::setGeneric("meta<-", function(object, value) {
    methods::makeStandardGeneric("meta<-")
})

#' @export
#' @rdname AnnotatedDataFrameWithMeta
methods::setMethod("meta", "AnnotatedDataFrameWithMeta", function(object) {
    object@meta
})

#' @export
#' @rdname AnnotatedDataFrameWithMeta
methods::setMethod("meta<-", "AnnotatedDataFrameWithMeta", function(object, value) {
    object@meta <- value
    methods::validObject(object)
    object
})

#' @export
#' @rdname AnnotatedDataFrameWithMeta
methods::setMethod("show", "AnnotatedDataFrameWithMeta", function(object) {
    methods::callNextMethod()
    wrap_cat("meta", names(meta(object)))
})
