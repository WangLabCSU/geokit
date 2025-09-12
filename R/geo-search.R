#' Search GEO database
#'
#' Search the [GDS](https://www.ncbi.nlm.nih.gov/gds) database and return
#' search results as a [data.table][data.table::data.table].
#'
#' The NCBI allows higher request limits (10 per second) when using an API key.
#' You can set this key for the current R session with
#' [rentrez::set_entrez_key()], or permanently by setting the `ENTREZ_KEY`
#' environment variable via [Sys.setenv()][base::Sys.setenv].
#' Once set, `rentrez` will automatically use this key for all NCBI requests.
#' See the [rentrez tutorial](https://docs.ropensci.org/rentrez/articles/rentrez_tutorial.html#rate-limiting-and-api-keys)
#' for details.
#'
#' @param query A character string with the search term. The NCBI uses a
#'   fielded search syntax. For example, `"Homo sapiens[ORGN]"` searches
#'   the "Organism" field for *Homo sapiens*. See the
#'   [GEO query tutorial](https://www.ncbi.nlm.nih.gov/geo/info/qqtutorial.html)
#'   for details. Searchable fields can be listed with
#'   [rentrez::entrez_db_searchable()].
#' @param step Integer. Number of records to fetch per request. Use a smaller
#'   value if requests fail.
#' @param interval Numeric. Time interval (in seconds) between successive
#'   requests. Defaults to `0`. Increase this value if requests fail due to
#'   rate limits.
#' @return A [data.table][data.table::data.table] contains the search results
#' @examples
#' geo_search("diabetes[ALL] AND Homo sapiens[ORGN] AND GSE[ETYP]")
#' @export
geo_search <- function(query, step = 500L, interval = NULL) {
    assert_number_whole(step, min = 1)
    assert_number_decimal(interval, min = 0, allow_null = TRUE)
    interval <- interval %||% 0
    records_num <- rentrez::entrez_search("gds", query, retmax = 0L)$count
    seq_starts <- seq(1L, records_num, step)
    records <- character(length(seq_starts))
    search_res <- rentrez::entrez_search(
        "gds", query,
        use_history = TRUE, retmax = 0L
    )
    bar <- cli::cli_progress_bar(
        name = "NCBI",
        format = "{cli::pb_bar} {cli::pb_current}/{cli::pb_total} [{cli::pb_rate}] | {cli::pb_eta_str}",
        format_done = "Get records from NCBI for {.val {cli::pb_total}} quer{?y/ies} in {cli::pb_elapsed}",
        total = records_num,
        clear = FALSE
    )
    for (i in seq_along(seq_starts)) {
        records[[i]] <- rentrez::entrez_fetch(
            db = "gds", web_history = search_res$web_history,
            rettype = "summary", retmode = "text",
            retmax = step, retstart = seq_starts[[i]]
        )
        if (i == length(seq_starts)) {
            n_records <- records_num - seq_starts[[i]] + 1L
        } else {
            n_records <- seq_starts[[i + 1L]] - seq_starts[[i]]
        }
        cli::cli_progress_update(inc = n_records, id = bar)
        if (interval > 0) Sys.sleep(interval)
    }
    cli::cli_alert("Parsing GEO records")
    records <- str_split(
        str_replace_all(paste0(records, collapse = ""), "^\\n|\\n$", ""),
        "\\n\\n"
    )[[1L]]
    out <- parse_name_value_pairs(preprocess_records(records))
    tail_col <- c(
        intersect(
            c("Contains", "Datasets", "Series", "Platforms"),
            names(out)
        ),
        str_subset(names(out), "Accession$")
    )
    data.table::setDT(out)
    data.table::setcolorder(out, tail_col, after = ncol(out))
    out[]
}

# this function just processed GEO searched results returned by `entrez_fetch`
# into key-values paris
preprocess_records <- function(x) {
    x <- str_replace(x, "^\\d+\\.", "Title:")
    x <- str_replace(
        x, "(Title:[^\\n]*\\n)(?:\\(Submitter supplied\\))?\\s*",
        "\\1Summary: "
    )
    x <- str_replace_all(
        x,
        "(Platform|Dataset|Serie)s?: *((?:GPL\\d+ *|GDS\\d+ *|GSE\\d+ *)+)",
        "\\1s: \\2\n"
    )
    x <- str_replace(x, "\\tID:\\s*", "\nID: ")
    x <- str_replace(
        x,
        "\\n((\\d+( Related| related)? (DataSet|Platform|Sample|Serie)s? *)+)\\n",
        "\nContains: \\1\n"
    )
    x <- str_replace_all(x, "\\t+", " ")
    str_split(x, "\\n\\n?")
}
