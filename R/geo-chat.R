#' Chat with GEO metadata using natural language
#'
#' Create a [`QueryChat`][querychat::QueryChat] object for exploring GEO
#' metadata with an LLM. Use `geo_chat()` to create the chat object,
#' `geo_shiny()` to launch the Shiny app, and `geo_console()` to start a console
#' chat.
#'
#' @inheritParams querychat::querychat
#' @param data_source A data.frame or a database connection containing GEO
#'   metadata, typically from [geo_meta()] or [geo_search()].
#' @inheritDotParams querychat::querychat -prompt_template
#'
#' @return A [`QueryChat`][querychat::QueryChat] object configured with
#'   `data_source`, an LLM client, and GEO-specific instructions.
#'
#' @details
#' `geo_chat()` intentionally does not serialize all rows or build a large data
#' prompt. Instead, it delegates schema summarization, SQL querying, and
#' dashboard filtering to [`QueryChat`][querychat::QueryChat].
#'
#' The three exported helpers differ only in how far they take the
#' [`QueryChat`][querychat::QueryChat] workflow:
#'
#' * `geo_chat()` creates and returns the `QueryChat` object. Use it when you
#'   want to inspect the generated prompt, customize the object, embed it in
#'   another Shiny app, or launch the app/console later with `qc$app()` or
#'   `qc$console()`.
#' * `geo_shiny()` creates the same `QueryChat` object and immediately launches
#'   its Shiny app. Use it for interactive browser-based filtering and
#'   exploration.
#' * `geo_console()` creates the same `QueryChat` object and immediately starts
#'   its console chat. Use it for command-line exploration without opening a
#'   Shiny app.
#'
#' The default instructions guide the assistant to query, and filter GEO
#' metadata, identify relevant studies.
#'
#' @examples
#' if (requireNamespace("querychat", quietly = TRUE) &&
#'     requireNamespace("duckdb", quietly = TRUE)) {
#'     records <- data.frame(
#'         Accession = c("GSE1", "GSE2"),
#'         Title = c("human diabetes study", "mouse liver study"),
#'         Type = c("Expression profiling by array", "RNA-seq"),
#'         Samples = c(12L, 8L)
#'     )
#'     chat <- geo_chat(NULL, records, cleanup = TRUE)
#'     chat$cleanup()
#' }
#' @seealso [geo_meta()], [geo_search()], [QueryChat][querychat::QueryChat]
#' @export
geo_chat <- function(client, data_source, table_name = NULL, ...) {
    rlang::check_installed("querychat")
    if (is.null(data_source)) {
        cli::cli_abort("{.arg data_source} must be provided.")
    }
    if (is.null(table_name)) {
        if (is.data.frame(data_source) ||
            inherits(data_source, "tbl_sql")) {
            table_name <- deparse1(substitute(data_source))
        }
    }
    querychat::querychat(
        data_source = data_source,
        table_name = table_name,
        client = client,
        ...,
        prompt_template = pkg_prompt("prompt.md")
    )
}

#' @export
#' @rdname geo_chat
geo_shiny <- function(...) {
    chat <- geo_chat(...)
    if (is.null(chat$greeting)) {
        chat$greeting <- chat$generate_greeting("none")
    }
    chat$app()
}

#' @export
#' @rdname geo_chat
geo_console <- function(...) {
    chat <- geo_chat(...)
    if (is.null(chat$greeting)) {
        chat$greeting <- chat$generate_greeting("none")
    }
    chat$console()
}
