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
#'   which can be associated with a specific search field with square brackets.
#'   So, for instance "Homo sapiens\[ORGN\]" denotes a search for `Homo sapiens`
#'   in the “Organism” field. Details see
#'   <https://www.ncbi.nlm.nih.gov/geo/info/qqtutorial.html>. The names and
#'   definitions of these fields can be identified using
#'   [entrez_db_searchable][rentrez::entrez_db_searchable].
#' @param step the number of records to fetch from the database each time. You
#' may choose a smaller value if failed.
#' @param interval The time interval (seconds) between each step.
#' @return a data.frame contains the search results
#' @examples
#' rgeo::search_geo("diabetes[ALL] AND Homo sapiens[ORGN] AND GSE[ETYP]")
#' @export
search_geo <- function(query, step = 500L, interval = 1L) {
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
        Sys.sleep(interval)
    }
    records <- stringi::stri_split(
        stringi::stri_replace_all(stringi::stri_c(records, collapse = ""),
            regex = "^\\n|\\n$", replacement = ""
        ),
        regex = "\\n\\n"
    )[[1L]]
    name_value_pairs <- parse_name_value_pairs(preprocess_records(records))
    tail_col <- c(
        intersect(
            c("Contains", "Datasets", "Series", "Platforms"),
            names(name_value_pairs)
        ),
        grep("Accession$", names(name_value_pairs), perl = TRUE, value = TRUE)
    )
    data.table::setDT(name_value_pairs)
    data.table::setcolorder(
        name_value_pairs,
        tail_col,
        after = ncol(name_value_pairs)
    )
    data.table::setDF(name_value_pairs)
    name_value_pairs
}

# this function just processed GEO searched results returned by `entrez_fetch`
# into key-values paris
preprocess_records <- function(x) {
    x <- stringi::stri_replace(x, regex = "^\\d+\\.", replacement = "Title:")
    x <- stringi::stri_replace(
        x,
        regex = "(Title:[^\\n]*\\n)(?:\\(Submitter supplied\\))?\\s*",
        replacement = "$1Summary: "
    )
    x <- stringi::stri_replace_all(
        x,
        regex = "(Platform|Dataset|Serie)s?: *((?:GPL\\d+ *|GDS\\d+ *|GSE\\d+ *)+)",
        replacement = "$1s: $2\n"
    )
    x <- stringi::stri_replace(x, regex = "\\tID:\\s*", replacement = "\nID: ")
    x <- stringi::stri_replace(
        x,
        regex = "\\n((\\d+( Related| related)? (DataSet|Platform|Sample|Serie)s? *)+)\\n",
        replacement = "\nContains: $1\n"
    )
    x <- stringi::stri_replace_all(x, regex = "\\t+", replacement = " ")
    stringi::stri_split(x, regex = "\\n\\n?")
}
