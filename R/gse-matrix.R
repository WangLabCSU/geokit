#' Retrieve Series Matrix and Create ExpressionSet
#'
#' The function downloads and parses the relevant Series Matrix files,
#' optionally mapping platform IDs to Bioconductor annotation packages.
#'
#' @inheritParams geo_soft
#' @param pdata_from_soft Logical, whether to derive `phenoData` from the GSE
#'   series SOFT file when creating an
#'   [`ExpressionSet`][Biobase::ExpressionSet].  Defaults to `TRUE`. If `FALSE`,
#'   `phenoData` is parsed from the series matrix file; note that some
#'   `characteristics_ch*` columns may not parse correctly.
#' @param add_gpl Logical or `NULL`. Whether to include platform information
#'   (the [`featureData`][Biobase::featureData] slot) when handling `GSE`
#'   entities with `gse_matrix = TRUE`. If `NULL` (default), the function
#'   attempts to map the GPL accession to a Bioconductor annotation package. If
#'   successful, the [`annotation`][Biobase::eSet] slot is updated and `add_gpl`
#'   is set to `FALSE`; otherwise, `add_gpl` is set to `TRUE`.
#' @return An [`ExpressionSet`][Biobase::ExpressionSet] or a list of
#'  `ExpressionSet`s, one per Series Matrix file.
#' @examples
#' if (require("Biobase")) {
#'     eset <- geo_matrix("GSE10", odir = tempdir())
#' }
#' @export
geo_matrix <- function(accession, pdata_from_soft = TRUE, add_gpl = NULL,
                       ftp_over_https = NULL, handle_opts = list(),
                       odir = getwd()) {
    check_bioc_installed("Biobase", "to build ExpressionSet")
    if (!all(geo_gtype(accession, abbre = TRUE) == "GSE")) {
        cli::cli_abort("Only Series {.arg accession} can be used")
    }
    odir <- dir_create(odir, recursive = TRUE)
    out_list <- get_gse_matrix(
        accession,
        odir = odir,
        pdata_from_soft = pdata_from_soft,
        add_gpl = add_gpl,
        ftp_over_https = ftp_over_https,
        handle_opts = handle_opts
    )
    return_object_or_list(out_list, accession)
}

get_gse_matrix <- function(ids, odir = getwd(), pdata_from_soft = TRUE,
                           add_gpl = NULL, ftp_over_https = TRUE,
                           handle_opts = list()) {
    file_paths_list <- download_suppl_or_gse_matrix_files(
        ids = ids,
        odir = odir,
        formats = "matrix",
        ftp_over_https = ftp_over_https,
        handle_opts = handle_opts
    )
    arg_list <- list(id = ids, file_paths = file_paths_list)
    if (pdata_from_soft) {
        gse_soft_file_paths <- download_gse_files(
            ids,
            odir = odir,
            ftp_over_https = ftp_over_https,
            handle_opts = handle_opts
        )
        gse_sample_data_list <- lapply(gse_soft_file_paths, function(x) {
            cli::cli_alert(
                "Parsing series {.field soft} file {.file {basename(x)}}"
            )
            gsm(parse_soft_rust(x))
        })
        cli::cli_alert_success(
            "Parsing {.val {length(gse_soft_file_paths)}} series {.field soft} file{?s} successfully!"
        )
        arg_list <- c(arg_list, list(gse_sample_data = gse_sample_data_list))
    }

    # parsing GSE metrix files --------------------------------------
    # pass id in order to update message
    es_elements_list <- .mapply(function(id, file_paths, ...) {
        cli::cli_alert(
            "Parsing {.val {length(file_paths)}} series {.field matrix} file{?s} of {.field {id}}"
        )
        names(file_paths) <- basename(file_paths)
        lapply(file_paths, function(file_path) {
            data <- parse_gse_matrix_rust(file_path)
            data <- .subset2(data, 1L)
        })
    }, arg_list, NULL)
    cli::cli_alert_success("Parsing {.val {length(ids)}} {.strong GSE} series matrix successfully!")

    # adding featureData and contructing ExpressionSet object
    cli::cli_alert("Constructing {.cls ExpressionSet}")
    lapply(es_elements_list, function(es_elements) {
        es_list <- lapply(es_elements, function(es_element) {
            if (is.null(add_gpl) || !add_gpl) {
                bioc_pkg <- gpl2bioc_pkg(es_element$annotation)
                if (!is.na(bioc_pkg)) {
                    es_element$annotation <- bioc_pkg
                } else if (is.null(add_gpl)) {
                    add_gpl <- TRUE
                }
            }
            if (isTRUE(add_gpl)) {
                es_element <- c(
                    es_element, list(
                        featureData = download_and_parse_annotation(
                            annotation = es_element$annotation,
                            assay = es_element$assayData,
                            odir = odir,
                            ftp_over_https = ftp_over_https,
                            handle_opts = handle_opts
                        )
                    )
                )
            }
            rlang::inject(Biobase::ExpressionSet(!!!es_element))
        })
        return_object_or_list(es_list)
    })
}

#' For all parsers used in `geo.R`, return a list
#' @noRd
parse_gse_matrix_rust <- function(path, gse_sample_data = NULL,
                                  reuse_buffer = TRUE) {
    list <- parse_soft_rust(path, reuse_buffer)

    # extract series matrix data
    matrix_data <- read_data_table(file_text)
    matrix_data <- as.matrix(matrix_data, names(matrix_data)[[1L]])

    # special concerns for GSE matrix metadata
    meta_groups <- c("Series", "Sample")
    names(meta_groups) <- meta_groups
    metadata <- list@metadata
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

    # fetch phenoData
    if (is.null(gse_sample_data)) {
        gse_sample_data <- metadata$Sample
        parse_gse_matrix_sample_characteristics(gse_sample_data)
    } else {
        gse_sample_data <- parse_gse_soft_sample_characteristics(
            gse_sample_data[colnames(matrix_data)]
        )
    }
    gse_sample_data <- gse_sample_data[
        colnames(matrix_data),
        on = "geo_accession"
    ]
    set_rownames(gse_sample_data, "geo_accession")
    pheno_data <- Biobase::AnnotatedDataFrame(data = gse_sample_data)

    # fetch experiment data
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
    # fetch GPL accession
    gpl_id <- metadata$Sample[[grep(
        "platform_id", colnames(metadata$Sample),
        ignore.case = TRUE
    )]][[1L]]

    list(
        assayData = matrix_data,
        phenoData = pheno_data,
        experimentData = experiment_data,
        annotation = gpl_id
    )
}

download_and_parse_annotation <- function(annotation, assay, odir,
                                          ftp_over_https, handle_opts) {
    gpl_file_path <- download_gpl_annot(
        annotation,
        handle_opts = handle_opts,
        ftp_over_https = ftp_over_https,
        odir = odir
    )
    gpl_data <- parse_gpl_or_gsm_soft(read_lines(gpl_file_path))
    if (nrow(gpl_data$data_table)) {
        feature_data <- set_rownames(gpl_data$data_table)
        # NCBI GEO uses case-insensitive matching between platform
        # IDs and series ID Refs
        feature_data <- feature_data[
            data.table::chmatch(
                tolower(rownames(assay)),
                tolower(rownames(feature_data))
            ), ,
            drop = FALSE
        ]
        rownames(feature_data) <- rownames(assay)
        Biobase::AnnotatedDataFrame(feature_data,
            varMetadata = column_to_rownames(gpl_data$columns)
        )
    } else {
        Biobase::AnnotatedDataFrame(
            data.frame(row.names = rownames(assay)),
            varMetadata = column_to_rownames(gpl_data$columns)
        )
    }
}

#' For GPL annot data, we firstly try to download `annot` file in FTP site and
#' then download "data" text file if it failed If we need full amount of data,
#' we try to download it in ACC site since file in ACC site is much smaller than
#' in FTP site.
#' @noRd
download_gpl_annot <- function(ids, handle_opts = list(), ftp_over_https = TRUE,
                               odir = getwd()) {
    download_status <- download_with_ftp(
        ids = ids, odir = odir,
        formats = "annot",
        handle_opts = handle_opts,
        ftp_over_https = ftp_over_https,
        fail = FALSE,
        file_label = "{.strong GPL} {.field annot}"
    )
    out <- download_status$destfiles
    if (any(!download_status$is_success)) {
        cli::cli_alert_info(paste(
            "{.field annot} file in FTP site for",
            "{.val {ids[!download_status$is_success]}} is not available, so",
            "will use {.field data} amount file from GEO Accession Site instead"
        ))
        out[!download_status$is_success] <- download_with_acc(
            ids = ids[!download_status$is_success], odir = odir,
            scope = "self", amount = "data", format = "text",
            handle_opts = handle_opts,
            file_label = "{.strong GPL} {.field data} amount"
        )
    }
    out
}
