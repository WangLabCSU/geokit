test_that("geo_chat requires a data.frame", {
  skip_if_not_installed("ellmer")
  
  expect_error(
    geo_chat("not a data.frame"),
    "must be a data.frame"
  )
  
  expect_error(
    geo_chat(list(a = 1, b = 2)),
    "must be a data.frame"
  )
})

test_that("geo_chat requires non-empty data", {
  skip_if_not_installed("ellmer")
  
  empty_df <- data.frame()
  expect_error(
    geo_chat(empty_df),
    "must have at least one row"
  )
})

test_that("geo_chat requires ellmer package", {
  # Mock ellmer not being available
  local_mocked_bindings(
    check_installed_ellmer = function() {
      cli::cli_abort("The {.pkg ellmer} package is required")
    }
  )
  
  df <- data.frame(id = 1:3, name = c("a", "b", "c"))
  expect_error(geo_chat(df), "ellmer")
})

test_that("geo_chat errors without provider when no API key configured", {
  skip_if_not_installed("ellmer")
  
  # Temporarily unset API keys
  withr::local_envvar(
    OPENAI_API_KEY = "",
    ANTHROPIC_API_KEY = "",
    GOOGLE_API_KEY = ""
  )
  
  df <- data.frame(
    Series_geo_accession = c("GSE12345", "GSE67890"),
    Series_title = c("Study A", "Study B"),
    Series_summary = c("Summary A", "Summary B")
  )
  
  expect_error(
    geo_chat(df, provider = NULL),
    "No provider specified"
  )
})

test_that("geo_chat requires valid provider", {
  skip_if_not_installed("ellmer")
  
  df <- data.frame(id = 1:3)
  
  expect_error(
    geo_chat(df, provider = "invalid"),
    "must be a function"
  )
})

test_that("build_geo_context creates proper context", {
  df <- data.frame(
    accession = c("GSE1", "GSE2", "GSE3"),
    title = c("Study A", "Study B", "Study C"),
    samples = c(10, 20, 30)
  )
  
  context <- build_geo_context(df, max_rows = 100, include_summary = TRUE)
  
  expect_type(context, "character")
  expect_match(context, "GEO Metadata Overview")
  expect_match(context, "3 rows")
  expect_match(context, "3 columns")
  expect_match(context, "accession")
  expect_match(context, "title")
  expect_match(context, "samples")
})

test_that("build_geo_context truncates large tables", {
  df <- data.frame(
    id = 1:200,
    value = rnorm(200)
  )
  
  context <- build_geo_context(df, max_rows = 50, include_summary = TRUE)
  
  expect_match(context, "Showing first 50 of 200 rows")
})

test_that("build_geo_context includes summary statistics", {
  df <- data.frame(
    num_col = c(1, 2, 3, 4, 5),
    char_col = c("a", "b", "a", "c", "b")
  )
  
  context <- build_geo_context(df, max_rows = 100, include_summary = TRUE)
  
  expect_match(context, "Column Statistics")
  expect_match(context, "min=")
  expect_match(context, "max=")
  expect_match(context, "unique values")
})

test_that("build_geo_context works without summary", {
  df <- data.frame(id = 1:3, name = c("a", "b", "c"))
  
  context <- build_geo_context(df, max_rows = 100, include_summary = FALSE)
  
  expect_false(grepl("Column Statistics", context))
})

test_that("can_use_provider checks environment variables", {
  withr::local_envvar(OPENAI_API_KEY = "test-key")
  expect_true(can_use_provider("chat_openai"))
  
  withr::local_envvar(OPENAI_API_KEY = "")
  expect_false(can_use_provider("chat_openai"))
  
  expect_false(can_use_provider("unknown_provider"))
})

test_that("geo_chat works with function provider", {
  skip_if_not_installed("ellmer")
  skip_if(Sys.getenv("OPENAI_API_KEY") == "", "OPENAI_API_KEY not set")
  
  df <- data.frame(
    Series_geo_accession = "GSE12345",
    Series_title = "Test Study"
  )
  
  chat <- geo_chat(df, provider = ellmer::chat_openai)
  
  expect_s3_class(chat, "Chat")
})
