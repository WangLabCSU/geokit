# Chat with GEO metadata using natural language

Create a
[`QueryChat`](https://posit-dev.github.io/querychat/reference/QueryChat.html)
object for exploring GEO metadata with an LLM. Use `geo_chat()` to
create the chat object, `geo_shiny()` to launch the Shiny app, and
`geo_console()` to start a console chat.

## Usage

``` r
geo_chat(client, data_source, table_name = NULL, ...)

geo_shiny(...)

geo_console(...)
```

## Arguments

- client:

  Optional chat client. Can be:

  - An [ellmer::Chat](https://ellmer.tidyverse.org/reference/Chat.html)
    object

  - A string to pass to
    [`ellmer::chat()`](https://ellmer.tidyverse.org/reference/chat-any.html)
    (e.g., `"openai/gpt-4o"`)

  - `NULL` (default): Uses the `querychat.client` option, the
    `QUERYCHAT_CLIENT` environment variable, or defaults to
    [`ellmer::chat_openai()`](https://ellmer.tidyverse.org/reference/chat_openai.html)

- data_source:

  A data.frame or a database connection containing GEO metadata,
  typically from
  [`geo_meta()`](https://WangLabCSU.github.io/geokit/reference/geo_meta.md)
  or
  [`geo_search()`](https://WangLabCSU.github.io/geokit/reference/geo_search.md).

- table_name:

  A string specifying the table name to use in SQL queries. If
  `data_source` is a data.frame, this is the name to refer to it by in
  queries (typically the variable name). If not provided, will be
  inferred from the variable name for data.frame inputs. For database
  connections, this parameter is required.

- ...:

  Arguments passed on to
  [`querychat::querychat`](https://posit-dev.github.io/querychat/reference/querychat-convenience.html)

  `id`

  :   Optional module ID for the QueryChat instance. If not provided,
      will be auto-generated from `table_name`. The ID is used to
      namespace the Shiny module.

  `greeting`

  :   Optional initial message to display to users. Can be a character
      string (in Markdown format) or a file path. If not provided, a
      greeting will be generated at the start of each conversation using
      the LLM, which adds latency and cost. Use `$generate_greeting()`
      to create a greeting to save and reuse.

  `tools`

  :   Which querychat tools to include in the chat client, by default.
      `"filter"` includes the tools for filtering and resetting the
      dashboard and `"query"` includes the tool for executing SQL
      queries. Use `tools = "filter"` when you only want the dashboard
      filtering tools, or when you want to disable the querying tool
      entirely to prevent the LLM from seeing any of the data in your
      dataset. The legacy name `"update"` is still accepted as an alias
      for `"filter"`.

  `data_description`

  :   Optional description of the data in plain text or Markdown. Can be
      a string or a file path. This provides context to the LLM about
      what the data represents.

  `categorical_threshold`

  :   For text columns, the maximum number of unique values to consider
      as a categorical variable. Default is 20.

  `extra_instructions`

  :   Optional additional instructions for the chat model in plain text
      or Markdown. Can be a string or a file path.

  `cleanup`

  :   Whether or not to automatically run `$cleanup()` when the Shiny
      session/app stops. By default, cleanup only occurs if `QueryChat`
      is created within a Shiny app. Set to `TRUE` to always clean up,
      or `FALSE` to never clean up automatically.

      In `querychat_app()`, in-memory databases created for data frames
      are always cleaned up.

  `bookmark_store`

  :   The bookmarking storage method. Passed to
      [`shiny::enableBookmarking()`](https://rdrr.io/pkg/shiny/man/enableBookmarking.html).
      If `"url"` or `"server"`, the chat state (including current query)
      will be bookmarked. Default is `"url"`.

## Value

A
[`QueryChat`](https://posit-dev.github.io/querychat/reference/QueryChat.html)
object configured with `data_source`, an LLM client, and GEO-specific
instructions.

## Details

`geo_chat()` intentionally does not serialize all rows or build a large
data prompt. Instead, it delegates schema summarization, SQL querying,
and dashboard filtering to
[`QueryChat`](https://posit-dev.github.io/querychat/reference/QueryChat.html).

The three exported helpers differ only in how far they take the
[`QueryChat`](https://posit-dev.github.io/querychat/reference/QueryChat.html)
workflow:

- `geo_chat()` creates and returns the `QueryChat` object. Use it when
  you want to inspect the generated prompt, customize the object, embed
  it in another Shiny app, or launch the app/console later with
  `qc$app()` or `qc$console()`.

- `geo_shiny()` creates the same `QueryChat` object and immediately
  launches its Shiny app. Use it for interactive browser-based filtering
  and exploration.

- `geo_console()` creates the same `QueryChat` object and immediately
  starts its console chat. Use it for command-line exploration without
  opening a Shiny app.

The default instructions guide the assistant to query, and filter GEO
metadata, identify relevant studies.

## See also

[`geo_meta()`](https://WangLabCSU.github.io/geokit/reference/geo_meta.md),
[`geo_search()`](https://WangLabCSU.github.io/geokit/reference/geo_search.md),
[QueryChat](https://posit-dev.github.io/querychat/reference/QueryChat.html)

## Examples

``` r
if (requireNamespace("querychat", quietly = TRUE) &&
    requireNamespace("duckdb", quietly = TRUE)) {
    records <- data.frame(
        Accession = c("GSE1", "GSE2"),
        Title = c("human diabetes study", "mouse liver study"),
        Type = c("Expression profiling by array", "RNA-seq"),
        Samples = c(12L, 8L)
    )
    chat <- geo_chat(NULL, records, cleanup = TRUE)
    chat$cleanup()
}
```
