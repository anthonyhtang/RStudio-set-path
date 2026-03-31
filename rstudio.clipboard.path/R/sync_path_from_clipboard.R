# Extensions for which we open the file in the editor (lowercase, tools::file_ext).
.rstudio_clipboard_open_exts <- c(
  "r", "rmd", "qmd", "rnw", "rhtml", "rd", "rproj", "rpres", "rhistory",
  "c", "cpp", "cc", "cxx", "h", "hpp", "f", "f90"
)

#' Strip a leading UTF-8 BOM if present.
#' @noRd
strip_bom <- function(s) {
  if (startsWith(s, "\ufeff")) {
    sub("^\ufeff", "", s)
  } else {
    s
  }
}

#' Repeatedly remove matching outer single or double quotes.
#' @noRd
strip_outer_quotes <- function(s) {
  s <- trimws(s)
  repeat {
    if (!nzchar(s) || nchar(s) < 2L) {
      break
    }
    first <- substr(s, 1L, 1L)
    last <- substr(s, nchar(s), nchar(s))
    if ((first == "\"" && last == "\"") || (first == "'" && last == "'")) {
      s <- substr(s, 2L, nchar(s) - 1L)
      s <- trimws(s)
    } else {
      break
    }
  }
  s
}

#' Whether this path should be opened in the RStudio source editor.
#' @noRd
is_r_ecosystem_file <- function(path) {
  bn <- basename(path)
  if (tolower(bn) %in% c(".rprofile", ".renviron")) {
    return(TRUE)
  }
  ext <- tolower(tools::file_ext(path))
  ext %in% .rstudio_clipboard_open_exts
}

#' Read clipboard as a character vector of lines (cross-platform via clipr).
#' @noRd
read_clipboard_lines <- function() {
  if (!clipr::clipr_available()) {
    stop(
      "Clipboard is not available. On Linux, install one of: xclip, xsel (X11), ",
      "or wl-clipboard (Wayland). On macOS and Windows, clipr should work in RStudio.",
      call. = FALSE
    )
  }
  raw <- tryCatch(
    clipr::read_clip(allow_non_interactive = TRUE),
    error = function(e) {
      stop("Could not read clipboard: ", conditionMessage(e), call. = FALSE)
    }
  )
  if (is.null(raw) || !length(raw)) {
    return(character())
  }
  trimws(raw)
}

#' Read a file or directory path from the clipboard (first line, trimmed, quotes stripped).
#'
#' @return A cleaned path string (not yet normalized).
#' @noRd
read_path_from_clipboard <- function() {
  raw <- read_clipboard_lines()
  if (!length(raw)) {
    stop("Clipboard is empty.", call. = FALSE)
  }
  path <- paste(raw, collapse = "\n")
  if (!nzchar(path)) {
    stop("Clipboard is empty.", call. = FALSE)
  }
  path <- sub("\n.*", "", path, perl = TRUE)
  path <- strip_bom(path)
  path <- strip_outer_quotes(path)
  path <- trimws(path)
  if (!nzchar(path)) {
    stop("Clipboard had no usable path after cleaning.", call. = FALSE)
  }
  path
}

#' Normalize an existing path for display and APIs (OS-appropriate separators).
#' @noRd
normalize_existing_path <- function(path) {
  if (.Platform$OS.type == "windows") {
    normalizePath(path, winslash = "\\", mustWork = TRUE)
  } else {
    normalizePath(path, mustWork = TRUE)
  }
}

#' @noRd
has_execute_command <- function() {
  isTRUE(hasFun("executeCommand"))
}

#' Run RStudio \code{activateFiles} (Show Files) once, then wait.
#' The command is asynchronous; \code{filesPaneNavigate} does not call \code{bringToFront}
#' on the Files view, and \code{setwd()} tends to refresh Environment and leave that tab selected.
#' @param quiet Passed to \code{executeCommand} (\code{FALSE} surfaces missing-command errors in the Console).
#' @noRd
files_pane_activate_once <- function(delay_sec = 0.25, quiet = TRUE) {
  if (!has_execute_command()) {
    return(invisible(FALSE))
  }
  ok <- tryCatch(
    {
      executeCommand("activateFiles", quiet = quiet)
      TRUE
    },
    error = function(e) {
      if (!quiet) {
        warning(
          "rstudio.clipboard.path: activateFiles failed: ",
          conditionMessage(e),
          call. = FALSE
        )
      }
      FALSE
    }
  )
  Sys.sleep(delay_sec)
  invisible(ok)
}

#' Repeat activation so the Files tab actually wins after \code{setwd} / async UI updates.
#' Ends with one \code{quiet = FALSE} attempt so RStudio reports a missing API in the Console.
#' @noRd
files_pane_bring_forward <- function(delay_sec = 0.32, repeats = 3L) {
  repeats <- as.integer(repeats)
  if (!is.finite(repeats) || repeats < 1L) {
    repeats <- 1L
  }
  for (i in seq_len(repeats)) {
    files_pane_activate_once(delay_sec, quiet = TRUE)
  }
  if (has_execute_command()) {
    files_pane_activate_once(0.2, quiet = FALSE)
  }
  if (isTRUE(getOption("rstudio.clipboard.path.zoom_files", FALSE))) {
    tryCatch(
      {
        executeCommand("layoutZoomFiles", quiet = TRUE)
        Sys.sleep(0.2)
      },
      error = function(e) invisible(NULL)
    )
  }
  invisible(NULL)
}

#' If \pkg{later} is installed, schedule extra \code{activateFiles} after the add-in returns
#' (RStudio sometimes switches back to Environment after the RPC completes).
#' @noRd
schedule_deferred_files_focus <- function() {
  if (!requireNamespace("later", quietly = TRUE)) {
    return(invisible(NULL))
  }
  if (!has_execute_command()) {
    return(invisible(NULL))
  }
  bump <- function() {
    tryCatch(
      executeCommand("activateFiles", quiet = TRUE),
      error = function(e) invisible(NULL)
    )
  }
  later::later(bump, delay = 0.22)
  later::later(bump, delay = 0.6)
  invisible(NULL)
}

#' Activate Files briefly, then navigate (\code{filesPaneNavigate} alone can fail if the pane is not active).
#' @noRd
navigate_files_pane <- function(path) {
  if (has_execute_command()) {
    files_pane_activate_once(0.18, quiet = TRUE)
  }
  filesPaneNavigate(path)
}

#' Escape minimal HTML for a \code{<pre>} block.
#' @noRd
html_escape <- function(s) {
  s <- gsub("&", "&amp;", s, fixed = TRUE)
  s <- gsub("<", "&lt;", s, fixed = TRUE)
  s <- gsub(">", "&gt;", s, fixed = TRUE)
  s
}

#' Show sync summary in the Viewer pane (RStudio only; file must live under \code{tempdir()}).
#' @noRd
notify_sync_viewer <- function(text) {
  if (!isTRUE(getOption("rstudio.clipboard.path.notify_viewer", TRUE))) {
    return(invisible(NULL))
  }
  if (!hasFun("viewer")) {
    return(invisible(NULL))
  }
  d <- tempfile("rstudio_clipboard_path_notify_")
  dir.create(d)
  html <- file.path(d, "index.html")
  body <- html_escape(text)
  writeLines(
    c(
      "<!DOCTYPE html><html><head><meta charset=\"utf-8\">",
      "<title>rstudio.clipboard.path</title>",
      "<style>body{font-family:system-ui,Segoe UI,sans-serif;padding:1rem;line-height:1.45;}",
      "pre{white-space:pre-wrap;background:#f6f8fa;padding:0.75rem;border-radius:6px;}</style>",
      "</head><body><h2 style=\"margin-top:0\">rstudio.clipboard.path</h2>",
      "<pre>", body, "</pre>",
      "<p style=\"color:#555;font-size:0.9rem\">You can close this tab. Summary is also sent to the Console.</p>",
      "</body></html>"
    ),
    html
  )
  tryCatch(viewer(html), error = function(e) invisible(NULL))
  invisible(NULL)
}

#' Run \code{cat(...)} in the Console via \code{sendToConsole} (\code{focus = FALSE} so the Files tab can stay selected).
#' @noRd
notify_sync_console_injected <- function(text) {
  if (!isTRUE(getOption("rstudio.clipboard.path.notify_console", TRUE))) {
    return(invisible(NULL))
  }
  if (!hasFun("sendToConsole")) {
    return(invisible(NULL))
  }
  buf <- character(0L)
  tc <- textConnection("buf", "w", local = TRUE)
  cat("cat(", file = tc)
  dput(text, tc)
  cat(", fill = TRUE)\n", file = tc)
  close(tc)
  code_str <- paste(buf, collapse = "")
  tryCatch(
    sendToConsole(code_str, execute = TRUE, echo = FALSE, focus = FALSE),
    error = function(e) invisible(NULL)
  )
  invisible(NULL)
}

#' English notice: Viewer pane + injected Console \code{cat} + \code{message} (Addins often hide bare \code{message} output).
#' @noRd
notify_sync <- function(target_dir, opened_file = NULL, file_skipped = FALSE) {
  lines <- c(
    "--- rstudio.clipboard.path ---",
    paste0("Working directory and Files location:\n  ", target_dir)
  )
  if (!is.null(opened_file)) {
    lines <- c(lines, paste0("Opened in editor:\n  ", opened_file))
  } else if (isTRUE(file_skipped)) {
    lines <- c(
      lines,
      "(Clipboard path is a file; not an R-related type — left unopened in editor.)"
    )
  }
  lines <- c(lines, "------------------------------")
  text <- paste(lines, collapse = "\n")
  notify_sync_viewer(text)
  notify_sync_console_injected(text)
  if (getRversion() >= "4.0.0") {
    message(text, domain = NA, immediate. = TRUE)
  } else {
    message(text, domain = NA)
  }
  flush.console()
}

#' RStudio add-in: set working directory and Files pane from the clipboard path.
#'
#' Intended to be run from the RStudio Addins menu (or a shortcut). Reads the
#' first line of the system clipboard. If it is an existing directory, sets the
#' working directory and Files pane. If it is an existing file, sets both to the
#' parent directory and opens the file in the editor when it looks like a common
#' R-related file (see package README).
#'
#' @return Normalized absolute path (invisibly).
#' @export
sync_path_from_clipboard <- function() {
  if (!isAvailable()) {
    stop("This add-in must be run inside RStudio.", call. = FALSE)
  }
  if (!has_execute_command()) {
    warning(
      "rstudio.clipboard.path: executeCommand() is not available in this RStudio build. ",
      "The Files tab cannot be switched from the API; update RStudio (Help -> Check for Updates).",
      call. = FALSE
    )
  }

  path_clean <- read_path_from_clipboard()
  if (!file.exists(path_clean) && !dir.exists(path_clean)) {
    stop(
      "Path does not exist (after cleaning):\n", path_clean,
      call. = FALSE
    )
  }
  path_abs <- normalize_existing_path(path_clean)

  if (dir.exists(path_abs)) {
    setwd(path_abs)
    navigate_files_pane(path_abs)
    notify_sync(path_abs)
    files_pane_bring_forward(0.32, 3L)
    schedule_deferred_files_focus()
    return(invisible(path_abs))
  }

  dir_abs <- normalize_existing_path(dirname(path_abs))
  setwd(dir_abs)
  navigate_files_pane(dir_abs)

  if (is_r_ecosystem_file(path_abs)) {
    files_pane_bring_forward(0.32, 3L)
    navigateToFile(path_abs)
    notify_sync(dir_abs, opened_file = path_abs)
  } else {
    notify_sync(dir_abs, file_skipped = TRUE)
    files_pane_bring_forward(0.32, 3L)
    schedule_deferred_files_focus()
  }
  invisible(path_abs)
}
