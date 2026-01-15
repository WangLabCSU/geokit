#' Chat with GEO metadata using AI
#'
#' This function enables interactive AI-powered conversation about your GEO
#' metadata. It uses the `ellmer` package to create a chat session with context
#' from your GEO metadata table, allowing you to ask questions, filter data,
#' and explore datasets through natural language.
#'
#' @param data A data.frame containing GEO metadata, typically from
#'   [geo_meta()] or [geo_search()].
#' @param provider A function that creates a chat object, such as
#'   `ellmer::chat_openai`, `ellmer::chat_anthropic`, etc. You can also pass
#'   a pre-configured Chat object directly.
#' @param system_prompt A character string providing additional system prompt
#'   instructions. This will be appended to the default system prompt that
#'   includes the metadata context.
#' @param max_rows Maximum number of rows to include in the context. Large
#'   tables will be summarized. Default is 100.
#' @param include_summary Logical. If `TRUE` (default), includes a statistical
#'   summary of the metadata columns.
#' @param ... Additional arguments passed to the provider function.
#' @return A `Chat` object from the `ellmer` package that can be used for
#'   interactive conversation.
#'
#' @details
#' The function creates a system prompt that includes:
#' \itemize{
#'   \item Column names and types from your metadata table
#'   \item Sample data rows (up to `max_rows`)
#'   \item Optional statistical summary
#' }
#'
#' The AI can help you:
#' \itemize{
#'   \item Filter and query the metadata
#'   \item Understand dataset characteristics
#'   \item Identify relevant studies for your research
#'   \item Generate R code for data manipulation
#' }
#'
#' @section Provider Setup:
#' You need to configure an API key for your chosen provider. For example:
#' \itemize{
#'   \item OpenAI: Set `OPENAI_API_KEY` environment variable
#'   \item Anthropic: Set `ANTHROPIC_API_KEY` environment variable
#'   \item See `ellmer` package documentation for other providers
#' }
#'
#' @examples
#' \dontrun{
#' # First, get some GEO metadata
#' gse_records <- geo_search("diabetes[ALL] AND Homo sapiens[ORGN] AND GSE[ETYP]")
#' meta <- geo_meta(gse_records$Accession[1:5], odir = tempdir())
#'
#' # Start an AI chat session with OpenAI
#' chat <- geo_chat(meta, provider = ellmer::chat_openai)
#' chat$chat("What types of studies are in this dataset?")
#' chat$chat("Which studies have the most samples?")
#'
#' # Use Anthropic's Claude instead
#' chat <- geo_chat(meta, provider = ellmer::chat_anthropic)
#'
#' # Interactive console mode
#' ellmer::live_console(chat)
#' }
#'
#' @seealso [geo_meta()], [geo_search()], [ellmer::chat_openai()]
#' @export
geo_chat <- function(data,
                     provider = NULL,
                     system_prompt = NULL,
                     max_rows = 100L,
                     include_summary = TRUE,
                     ...) {
  check_installed_ellmer()

  if (!is.data.frame(data)) {
    cli::cli_abort("{.arg data} must be a data.frame, not {.obj_type_friendly {data}}.")
  }

  if (nrow(data) == 0L) {
    cli::cli_abort("{.arg data} must have at least one row.")
  }

  # Build the context from metadata
  context <- build_geo_context(data, max_rows = max_rows, include_summary = include_summary)

  # Construct the full system prompt
  full_prompt <- paste0(
    "You are a helpful bioinformatics assistant specializing in GEO ",
    "(Gene Expression Omnibus) data analysis. You have access to the ",
    "following GEO metadata table that the user wants to explore.\n\n",
    context,
    if (!is.null(system_prompt)) paste0("\n\nAdditional instructions:\n", system_prompt) else ""
  )

  # Create the chat object
  if (inherits(provider, "Chat")) {
    # User passed a pre-configured Chat object
    chat <- provider$clone()
    cli::cli_warn(
      c("Using a pre-configured Chat object.",
        "i" = "The existing conversation history will be preserved.",
        "i" = "Consider creating a fresh chat for a new analysis session.")
    )
    chat
  } else if (is.function(provider)) {
    # User passed a provider function like chat_openai
    provider(system_prompt = full_prompt, ...)
  } else if (is.null(provider)) {
    # Try to use a default provider
    provider <- get_default_provider()
    if (is.null(provider)) {
      cli::cli_abort(c(
        "No provider specified and no default provider available.",
        "i" = "Install and configure a provider, then pass it as {.arg provider}.",
        "i" = "Example: {.code geo_chat(data, provider = ellmer::chat_openai)}"
      ))
    }
    provider(system_prompt = full_prompt, ...)
  } else {
    cli::cli_abort(
      "{.arg provider} must be a function (e.g., {.code ellmer::chat_openai}) or a Chat object."
    )
  }
}

#' Build context string from GEO metadata
#' @noRd
build_geo_context <- function(data, max_rows = 100L, include_summary = TRUE) {
  n_total <- nrow(data)
  n_cols <- ncol(data)

  # Column information
  col_info <- vapply(data, function(x) {
    paste0(class(x)[1L], " (", sum(!is.na(x)), " non-NA)")
  }, character(1L))

  col_desc <- paste0(
    "  - ", names(data), ": ", col_info,
    collapse = "\n"
  )

  # Truncate data if necessary
  if (n_total > max_rows) {
    data_subset <- data[seq_len(max_rows), , drop = FALSE]
    truncated_msg <- sprintf(
      "\n[Showing first %d of %d rows. Ask if you need information about remaining rows.]",
      max_rows, n_total
    )
  } else {
    data_subset <- data
    truncated_msg <- ""
  }

  # Convert to text representation
  data_text <- utils::capture.output(print(data_subset, max = max_rows * n_cols))
  data_text <- paste(data_text, collapse = "\n")

  # Build summary if requested
  summary_text <- ""
  if (include_summary) {
    summary_lines <- character()

    for (col_name in names(data)) {
      col <- data[[col_name]]
      if (is.numeric(col)) {
        summary_lines <- c(summary_lines, sprintf(
          "  - %s: min=%.2f, max=%.2f, mean=%.2f, NA=%d",
          col_name, min(col, na.rm = TRUE), max(col, na.rm = TRUE),
          mean(col, na.rm = TRUE), sum(is.na(col))
        ))
      } else if (is.character(col) || is.factor(col)) {
        unique_vals <- unique(col[!is.na(col)])
        n_unique <- length(unique_vals)
        if (n_unique <= 5L) {
          summary_lines <- c(summary_lines, sprintf(
            "  - %s: %d unique values (%s)",
            col_name, n_unique, paste(unique_vals, collapse = ", ")
          ))
        } else {
          top_vals <- names(sort(table(col), decreasing = TRUE))[1:3]
          summary_lines <- c(summary_lines, sprintf(
            "  - %s: %d unique values (top 3: %s)",
            col_name, n_unique, paste(top_vals, collapse = ", ")
          ))
        }
      }
    }

    if (length(summary_lines) > 0L) {
      summary_text <- paste0(
        "\n\n## Column Statistics:\n",
        paste(summary_lines, collapse = "\n")
      )
    }
  }

  # Combine everything
  paste0(
    "## GEO Metadata Overview\n",
    sprintf("Total records: %d rows, %d columns\n\n", n_total, n_cols),
    "## Columns:\n", col_desc, "\n\n",
    "## Data:\n```\n", data_text, "\n```",
    truncated_msg,
    summary_text,
    "\n\n---\n",
    "You can help the user by:\n",
    "1. Answering questions about this GEO metadata\n",
    "2. Suggesting R code to filter or analyze the data\n",
    "3. Identifying relevant studies based on user criteria\n",
    "4. Explaining GEO accession types (GSE, GSM, GPL, GDS)\n"
  )
}

#' Try to get a default provider
#' @noRd
get_default_provider <- function() {
  providers <- c("chat_openai", "chat_anthropic", "chat_google_gemini")

  for (provider_name in providers) {
    provider_fn <- tryCatch(
      utils::getFromNamespace(provider_name, "ellmer"),
      error = function(e) NULL
    )
    if (!is.null(provider_fn)) {
      if (can_use_provider(provider_name)) {
        return(provider_fn)
      }
    }
  }
  NULL
}

#' Check if a provider is likely usable
#' @noRd
can_use_provider <- function(provider_name) {
  env_vars <- list(
    chat_openai = "OPENAI_API_KEY",
    chat_anthropic = "ANTHROPIC_API_KEY",
    chat_google_gemini = "GOOGLE_API_KEY"
  )

  env_var <- env_vars[[provider_name]]
  if (is.null(env_var)) return(FALSE)

  nzchar(Sys.getenv(env_var, ""))
}

#' Check if ellmer is installed
#' @noRd
check_installed_ellmer <- function() {
  if (!requireNamespace("ellmer", quietly = TRUE)) {
    cli::cli_abort(c(
      "The {.pkg ellmer} package is required for AI chat functionality.",
      "i" = "Install it with: {.code install.packages('ellmer')}"
    ))
  }
}
