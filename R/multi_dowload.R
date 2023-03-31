# Copied from https://github.com/jeroen/curl/blob/master/R/multi_download.R
multi_download <- function(urls, destfiles = NULL, progress = interactive(), handle_opts) {
    urls <- enc2utf8(urls)
    dupes <- destfiles[duplicated(destfiles)]
    if (length(dupes) > 0L) {
        cli::cli_abort("Duplicate destfiles: {.path {dupes}}")
    }
    destfiles <- normalizePath(destfiles, mustWork = FALSE)
    out_len <- length(urls)
    handles <- rep_len(list(NULL), out_len)
    writers <- rep_len(list(NULL), out_len)
    errors <- rep_len(NA_character_, out_len)
    success <- rep_len(NA, out_len)
    dlspeed <- rep_len(0, out_len)
    expected <- rep_len(NA, out_len)
    pool <- curl::new_pool()
    total <- 0L
    lapply(seq_along(urls), function(i) {
        dest <- destfiles[i]
        handle <- curl::new_handle(url = urls[i])
        curl::handle_setopt(handle, .list = handle_opts)
        curl::handle_setopt(handle, noprogress = TRUE)
        writer <- curl::file_writer(dest, append = FALSE)
        curl::multi_add(handle, pool = pool, data = function(buf, final) {
            total <<- total + length(buf)
            writer(buf, final)
            if (isTRUE(progress)) {
                if (is.na(expected[i])) {
                    expected[i] <<- curl:::handle_clength(handle)
                }
                dlspeed[i] <<- ifelse(final, 0, curl:::handle_speed(handle)[1])
                print_progress(success, total, sum(dlspeed), sum(expected))
            }
        }, done = function(req) {
            expected[i] <<- curl:::handle_received(handle)
            success[i] <<- TRUE
            dlspeed[i] <<- 0
            if (expected[i] == 0 && !file.exists(dest)) {
                file.create(dest) # create empty file
            }
            mtime <- curl:::handle_mtime(handle)
            if (!is.na(mtime)) {
                Sys.setFileTime(dest, mtime)
            }
        }, fail = function(err) {
            expected[i] <<- curl:::handle_received(handle)
            success[i] <<- FALSE
            errors[i] <<- err
            dlspeed[i] <<- 0
        })
        handles[[i]] <<- handle
        writers[[i]] <<- writer
        if (isTRUE(progress) && (i %% 100 == 0)) {
            print_stream("\rPreparing request %d of %d...", i, length(urls))
        }
    })
    on.exit(lapply(writers, function(writer) {
        # fallback to close writer in case the download got interrupted
        writer(raw(0L), close = TRUE)
    }))
    tryCatch(
        {
            curl::multi_run(timeout = Inf, pool = pool)
            if (isTRUE(progress)) {
                print_progress(
                    success, total, sum(dlspeed),
                    sum(expected), TRUE
                )
            }
        },
        interrupt = function(e) {
            message("download interrupted")
        }
    )
    out <- lapply(handles, curl::handle_data)
    results <- data.frame(
        success = success,
        status_code = sapply(out, function(x) {
            x$status_code
        }),
        url = sapply(out, function(x) {
            x$url
        }),
        destfile = destfiles,
        error = errors,
        type = sapply(out, function(x) {
            x$type
        }),
        modified = structure(sapply(out, function(x) {
            x$modified
        }), class = c("POSIXct", "POSIXt")),
        time = sapply(out, function(x) {
            unname(x$times["total"])
        }),
        stringsAsFactors = FALSE
    )
    results$headers <- lapply(out, function(x) {
        curl::parse_headers(x$headers)
    })
    results
}

# Print at most 10x per second in interactive, and once per sec in batch/CI
print_progress <- local({
    last <- 0
    function(sucvec, total, speed, expected, finalize = FALSE) {
        if (interactive()) {
            throttle <- 0.1
        } else {
            throttle <- 5
        }
        now <- unclass(Sys.time())
        if (isTRUE(finalize) || now - last > throttle) {
            last <<- now
            done <- sum(!is.na(sucvec))
            pending <- sum(is.na(sucvec))
            pctstr <- if (!identical(expected, 0.0)) {
                sprintf("(%s%%)", ifelse(is.na(expected), "??", as.character(round(100 * total / expected))))
            } else {
                ""
            }
            speedstr <- if (!finalize) {
                sprintf(" (%s/s)", curl:::format_size(speed))
            } else {
                ""
            }
            downloaded <- curl:::format_size(total)
            print_stream(
                "\rDownload status: %d done; %d in progress%s. Total size: %s %s...",
                done, pending, speedstr, downloaded, pctstr
            )
        }
        if (finalize) {
            cat(" done!             \n", file = stderr())
            flush(stderr())
        }
    }
})

print_stream <- function(...) {
    cat(sprintf(...), file = stderr())
}
