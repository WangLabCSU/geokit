#' Chat with GEO metadata using natural language
#'
#' Create a [`QueryChat`][querychat::QueryChat] object for exploring GEO
#' metadata with an LLM. Use `geo_qc()` to create the chat object, `geo_shiny()`
#' to launch the Shiny app, and `geo_chat()` to start a console chat.
#'
#' @inheritParams querychat::querychat
#' @param data_source A data.frame or a database connection containing GEO
#'   metadata, typically from [geo_meta()] or [geo_search()].
#' @inheritDotParams querychat::querychat -extra_instructions -prompt_template
#' @param instructions Optional single string with additional instructions to
#'   append to the default GEO metadata assistant instructions.
#'
#' @return A [`QueryChat`][querychat::QueryChat] object configured with
#'   `data_source`, an LLM client, and GEO-specific instructions.
#'
#' @details
#' `geo_qc()` intentionally does not serialize all rows or build a large data
#' prompt. Instead, it delegates schema summarization, SQL querying, and
#' dashboard filtering to [`QueryChat`][querychat::QueryChat].
#'
#' The three exported helpers differ only in how far they take the
#' [`QueryChat`][querychat::QueryChat] workflow:
#'
#' * `geo_qc()` creates and returns the `QueryChat` object. Use it when you want
#'   to inspect the generated prompt, customize the object, embed it in another
#'   Shiny app, or launch the app/console later with `qc$app()` or
#'   `qc$console()`.
#' * `geo_shiny()` creates the same `QueryChat` object and immediately launches
#'   its Shiny app. Use it for interactive browser-based filtering and
#'   exploration.
#' * `geo_chat()` creates the same `QueryChat` object and immediately starts
#'   its console chat. Use it for command-line exploration without opening a
#'   Shiny app.
#'
#' The default instructions guide the assistant to query and filter GEO
#' metadata, identify relevant studies, generate reproducible R code when
#' asked, preserve explicit accession IDs, and explain GEO accession types
#' (`GSE`, `GSM`, `GPL`, and `GDS`) when useful.
#'
#' The first argument is the LLM client. Use `client = NULL` or pass `NULL` as
#' the first positional argument to let `querychat` choose a client from its
#' options or environment variables. Additional context such as
#' `data_description`, `greeting`, `tools`, `categorical_threshold`, and
#' `cleanup` can be passed through `...` to [querychat::querychat()].
#' `prompt_template` is intentionally not forwarded because `geo_qc()` supplies
#' GEO-specific instructions through `extra_instructions`.
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
#'     qc <- geo_qc(NULL, records, table_name = "geo_records", cleanup = TRUE)
#'     qc$cleanup()
#' }
#' @seealso [geo_meta()], [geo_search()], [QueryChat][querychat::QueryChat],
#' [ellmer::chat_openai()]
#' @export
geo_qc <- function(client, data_source, table_name = NULL, ...,
                   instructions = NULL) {
    rlang::check_installed("querychat")
    assert_string(instructions, allow_null = TRUE)
    extra_instructions <- geo_qc_instructions(instructions)
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
        extra_instructions = extra_instructions,
        ...,
        prompt_template = NULL
    )
}

#' @export
#' @rdname geo_qc
geo_shiny <- function(...) {
    qc <- geo_qc(...)
    qc$app()
}

#' @export
#' @rdname geo_qc
geo_chat <- function(...) {
    qc <- geo_qc(...)
    qc$console()
}

geo_qc_instructions <- function(instructions = NULL) {
    prompt <- paste(
        "You are a bioinformatics helper for GEO (Gene Expression Omnibus) metadata.",
        "Use the querychat data context and tools to query and filter the metadata.",
        "Help identify relevant studies, samples, platforms, and datasets.",
        "Generate clear R code when the user asks for reproducible filtering or analysis steps.",
        "When generating R code, use backticks around non-syntactic column names such as names containing spaces, punctuation, or slashes.",
        "Explain GEO accession types when useful: GSE for series, GSM for samples, GPL for platforms, and GDS for curated datasets.",
        "When answering from the metadata, prefer explicit accession IDs and avoid guessing beyond the available data.",
        sep = "\n"
    )
    if (is.null(instructions)) {
        return(prompt)
    }
    paste(
        prompt,
        "Additional instructions:", instructions,
        sep = "\n\n"
    )
}
