#' Retrieve Series Matrix and Create ExpressionSet
#'
#' The function downloads and parses the relevant Series Matrix files,
#' optionally mapping platform IDs to Bioconductor annotation packages.
#'
#' @inheritParams geo_soft
#' @param add_gpl Logical or `NULL`. Whether to include platform information
#'   (the [`featureData`][Biobase::featureData] slot). If `NULL` (default), the
#'   function attempts to map the GPL accession to a Bioconductor annotation
#'   package. If successful, the [`annotation`][Biobase::eSet] slot is updated
#'   and `add_gpl` is set to `FALSE`; otherwise, `add_gpl` is set to `TRUE`.
#' @param pdata_from_soft Logical. Specifies whether to derive `phenoData` from
#'   the GSE series SOFT file. Defaults to `FALSE`, in which case `phenoData` is
#'   parsed directly from the series matrix file. Set to `TRUE` if you encounter
#'   issues parsing `characteristics_ch*` columns correctly, as it will attempt
#'   to retrieve the data from the SOFT file instead.
#' @return An [`ExpressionSet`][Biobase::ExpressionSet] or a list of
#'  `ExpressionSet`s, one per Series Matrix file.
#' @examples
#' \donttest{
#' if (require("Biobase")) {
#'     eset <- geo_matrix("GSE10", odir = tempdir())
#' }
#' }
#' @export
geo_matrix <- function(accession, add_gpl = NULL, pdata_from_soft = FALSE,
                       ftp_over_https = NULL, handle_opts = list(),
                       odir = getwd()) {
    check_bioc_installed("Biobase", "to build ExpressionSet")
    geotypes <- geo_gtype(accession, abbre = TRUE)
    if (geotypes[1L] != "GSE" || !is_all_same(geotypes)) {
        cli::cli_abort("Only Series {.arg accession} can be used")
    }
    assert_bool(pdata_from_soft)
    assert_bool(add_gpl, allow_null = TRUE)
    odir <- dir_create(odir, recursive = TRUE)
    matrix_list <- geo_matrix_impl(
        accession,
        pdata_from_soft = pdata_from_soft,
        add_gpl = add_gpl,
        ftp_over_https = ftp_over_https,
        handle_opts = handle_opts,
        odir = odir
    )
    return_object_or_list(matrix_list, accession)
}

geo_matrix_impl <- function(accession, pdata_from_soft = TRUE,
                            add_gpl = NULL, ftp_over_https = TRUE,
                            handle_opts = list(), odir = getwd()) {
    collected <- list(
        ftp_over_https = ftp_over_https,
        handle_opts = handle_opts,
        odir = odir
    )
    paths_list <- rlang::inject(download_url_directory(
        accession,
        format = "matrix", !!!collected
    ))

    # we handle `pdata_from_soft` here, since a single series soft can be used
    # by multiple series matrix files
    if (pdata_from_soft) {
        gse_soft <- rlang::inject(geo_soft_impl(
            accession,
            famount = "soft", !!!collected
        ))
        cli::cli_alert_success(sprintf(
            "Parsing {.val {%s}} Series {.field soft} %sfile{?s} successfully!",
            length(gse_soft), "{cli::qty(length(gse_soft))}"
        ))
    } else {
        gse_soft <- rep_len(list(NULL), length(paths_list))
    }

    # parsing GSE metrix files --------------------------------------
    collected$add_gpl <- add_gpl
    es_list <- .mapply(function(paths, ...) {
        names(paths) <- basename(paths)
        es_list <- lapply(paths, function(path) parse_gse_matrix(path, ...))
        return_object_or_list(es_list)
    }, list(paths = paths_list, gse_soft = gse_soft), collected)
    cli::cli_alert_success(sprintf(
        "Parsing {.val {%s}} {.field Series} matrix successfully!",
        length(accession)
    ))
    es_list
}

#' For all parsers used in `geo.R`, return a list
#' @noRd
parse_gse_matrix <- function(path, gse_soft = NULL, add_gpl = NULL,
                             ftp_over_https = TRUE, handle_opts = list(),
                             odir = getwd()) {
    entity_list <- parse_soft_rust(path, "matrix")
    gse_matrix <- parse_entity_list(.subset2(entity_list, 1L))

    # extract series matrix data
    matrix_data <- datatable(gse_matrix)
    assay <- as.matrix(matrix_data[, -1L, drop = FALSE])
    rownames(assay) <- .subset2(matrix_data, 1L)

    # special concerns for GSE matrix metadata
    meta_groups <- c("Series", "Sample")
    names(meta_groups) <- meta_groups
    metadata <- metadata(gse_matrix)
    metadata <- lapply(meta_groups, function(group) {
        group_meta <- startsWith(names(metadata), paste0(group, "_"))
        group_meta <- .subset(metadata, group_meta)
        rlang::set_names(
            group_meta,
            function(x) sub(paste0("^", group, "_"), "", x)
        )
    })
    metadata$Sample <- quickdf(metadata$Sample)
    for (x in c("sample_id", "pubmed_id", "platform_id")) {
        if (!is.null(metadata$Series[[x]])) {
            metadata$Series[[x]] <- strsplit(metadata$Series[[x]], " ")[[1L]]
        }
    }

    # fetch phenoData -------------------------------------------
    if (is.null(gse_soft)) {
        sample_data <- parse_sample_data(metadata$Sample)
    } else {
        gsm_list <- gsm(gse_soft)
        names(gsm_list) <- vapply(
            gsm_list, rcd_name, character(1L),
            USE.NAMES = FALSE
        )
        sample_data <- parse_sample_data(gsm_list[colnames(assay)])
    }
    pheno_data <- Biobase::AnnotatedDataFrame(
        data = sample_data[colnames(assay), ]
    )

    # fetch experiment data -------------------------------------
    experiment_data <- Biobase::MIAME(
        name = metadata$Series$contact_name %||% "",
        title = metadata$Series$title,
        contact = metadata$Series$contact_email %||% "",
        pubMedIds = metadata$Series$pubmed_id %||% "",
        abstract = metadata$Series$summary %||% "",
        url = if (!is.null(metadata$Series$web_link)) {
            metadata$Series$web_link
        } else if (!is.null(metadata$Series$geo_accession)) {
            sprintf(
                "https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=%s",
                metadata$Series$geo_accession
            )
        } else {
            "https://www.ncbi.nlm.nih.gov/geo/"
        },
        other = metadata$Series
    )

    # fetch feature data ----------------------------------------
    gpl_column <- grep(
        "platform_id", colnames(metadata$Sample),
        ignore.case = TRUE
    )
    annotation <- .subset(.subset2(metadata$Sample, gpl_column[1L]), 1L)

    if (is.null(add_gpl) || !add_gpl) {
        bioc_pkg <- gpl_map(annotation)$bioc_pkg
        if (is.na(bioc_pkg)) {
            cli::cli_alert_info(
                "No Bioconductor annotation package available for platform {.val {annotation}}."
            )
            if (is.null(add_gpl)) add_gpl <- TRUE
        } else {
            cli::cli_alert_success(
                "Found Bioconductor annotation package for {.val {annotation}}"
            )
            annotation <- bioc_pkg
        }
    }
    feature_data <- NULL
    if (isTRUE(add_gpl)) {
        annot_downloaded <- download_annot(
            annotation,
            handle_opts = handle_opts,
            ftp_over_https = ftp_over_https,
            odir = odir
        )
        if (annot_downloaded$success) {
            annot_file <- .subset2(annot_downloaded, "paths")
            entity_list <- parse_soft_rust(annot_file)
            gpl <- parse_entity_list(.subset2(entity_list, 1L))
            if (nrow(feature_data <- datatable(gpl))) {
                feature_data <- set_rownames(feature_data)
                # NCBI GEO uses case-insensitive matching between platform
                # IDs and series ID Refs
                feature_data <- feature_data[
                    match(
                        tolower(rownames(assay)),
                        tolower(rownames(feature_data))
                    ), ,
                    drop = FALSE
                ]
                rownames(feature_data) <- rownames(assay)
                feature_data <- Biobase::AnnotatedDataFrame(
                    feature_data,
                    varMetadata = columns(gpl)
                )
            } else {
                feature_data <- Biobase::AnnotatedDataFrame(
                    data.frame(row.names = rownames(assay)),
                    varMetadata = columns(gpl)
                )
            }
        } else {
            cli::cli_alert_info(paste(
                "Failed to download annotation file for {.val {accession[!downloaded$success]}},",
                "Platform information will not be added."
            ))
        }
    }
    feature_data <- feature_data %||% Biobase::AnnotatedDataFrame(
        data.frame(row.names = rownames(assay))
    )

    # contructing ExpressionSet object
    Biobase::ExpressionSet(
        assayData = assay,
        phenoData = pheno_data,
        featureData = feature_data,
        experimentData = experiment_data,
        annotation = annotation
    )
}

#' For GPL annot data, we firstly try to download `annot` file in FTP site and
#' then download "data" text file if it failed If we need full amount of data,
#' we try to download it in ACC site since file in ACC site is much smaller than
#' in FTP site.Q
#' @noRd
download_annot <- function(accession, ftp_over_https = TRUE,
                           handle_opts = list(), odir = getwd()) {
    url_and_fname <- file_url_and_fname(
        accession, "annot",
        ftp_over_https = ftp_over_https
    )
    downloaded <- download_inform(
        .subset2(url_and_fname, "urls"),
        file.path(odir, .subset2(url_and_fname, "fnames"), fsep = "/"),
        handle_opts = handle_opts,
        error = FALSE
    )
    if (!downloaded$success) {
        cli::cli_alert_info(paste(
            "{.field annot} file for {.val {accession[!downloaded$success]}} is not available on the FTP site. ",
            "Attempting to use the {.field data} amount file from the GEO Accession Site instead."
        ))
        url_and_fname <- file_url_and_fname(
            accession, "data",
            ftp_over_https = ftp_over_https
        )
        downloaded <- download_inform(
            .subset2(url_and_fname, "urls"),
            file.path(odir, .subset2(url_and_fname, "fnames"), fsep = "/"),
            handle_opts = handle_opts,
            error = FALSE
        )
    }
    downloaded
}

#' @param gpl a character string
#' @return A data frame of the mapping Bioconductor annotation package
#' @noRd
gpl_map <- function(gpl) {
    mapping <- read_internal("gpl2bioc.rds")
    mapping[match(gpl, mapping$Platform_geo_accession), , drop = FALSE]
}
