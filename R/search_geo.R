#' Search GEO database
#'
#' This function searchs [GDS](https://www.ncbi.nlm.nih.gov/gds) database,
#' and return a data.frame for all the search results.
#' 
#' The NCBI allows users to access more records (10 per second) if they register
#' for and use an API key. [set_entrez_key][rentrez::set_entrez_key] function
#' allows users to set this key for all calls to rentrez functions during a
#' particular R session. You can also set an environment variable `ENTREZ_KEY`
#' by [Sys.setenv][base::Sys.setenv].  Once this value is set to your key
#' rentrez will use it for all requests to the NCBI. Details see
#' <https://docs.ropensci.org/rentrez/articles/rentrez_tutorial.html#rate-limiting-and-api-keys>
#' 
#' @param query character, the search term. The NCBI uses a search term syntax
#' where search terms can be associated with a specific search field with square
#' brackets. So, for instance "Homo sapiens\[ORGN\]" denotes a search for `Homo
#' sapiens` in the “Organism” field. Details see
#' <https://www.ncbi.nlm.nih.gov/geo/info/qqtutorial.html>. The names and
#' definitions of these fields can be identified using
#' [entrez_db_searchable][rentrez::entrez_db_searchable].
#' @param step the number of records to fetch from the database each time. You
#' may choose a smaller value if failed.
#' @return a data.frame contains the search results
#' @examples
#' rgeo::search_geo("diabetes[ALL] AND Homo sapiens[ORGN] AND GSE[ETYP]")
#' @export 
search_geo <- function(query, step = 500L) {
    records_num <- rentrez::entrez_search(
        "gds", query,
        retmax = 0L
    )$count
    seq_starts <- seq(1L, records_num, step)
    records <- character(length(seq_starts))
    search_res <- rentrez::entrez_search(
        "gds", query,
        use_history = TRUE, retmax = 0L
    )
    for (i in seq_along(seq_starts)) {
        records[[i]] <- rentrez::entrez_fetch(
            db = "gds", web_history = search_res$web_history,
            rettype = "summary", retmode = "text",
            retmax = step, retstart = seq_starts[[i]]
        )
        Sys.sleep(1L)
    }
    records <- strsplit(
        gsub("^\\n|\\n$", "", paste0(records, collapse = "")),
        "\\n\\n"
    )[[1L]]
    name_value_pairs <- parse_name_value_pairs(preprocess_records(records))
    data.table::setDF(name_value_pairs)
    name_value_pairs
}

preprocess_records <- function(x) {
    x <- sub("^\\d+\\.", "Title:", x, perl = TRUE)
    x <- sub(
        "\\n\\(Submitter supplied\\)\\s*",
        "\nSummary: ", x,
        perl = TRUE
    )
    x <- gsub(
        "\\s*\\n?(Platform|Dataset)s?\\s*:\\s*",
        "\n\\1s: ", x,
        perl = TRUE
    )
    x <- sub("\\tID:\\s*", "\nID: ", x, perl = TRUE)
    x <- sub(
        "\\n?\\s*((?:\\s*\\d+(?:\\s*related)?\\s*(?:DataSet|Platforms|Samples|Series))+)([^:])",
        "\nContains: \\1\\2", x,
        perl = TRUE
    )
    x <- gsub(":\\t+", ": ", x, perl = TRUE)
    x <- gsub("\\t\\t+", " ", x, perl = TRUE)
    strsplit(x, "\\n", perl = TRUE)
}
