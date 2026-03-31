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

#' Bring the Files pane to the front (RStudio command \code{activateFiles} = Show Files).
#' @param delay_sec Seconds to wait after the command (it runs asynchronously).
#' @noRd
files_pane_to_front <- function(delay_sec = 0.2) {
  tryCatch(
    executeCommand("activateFiles", quiet = TRUE),
    error = function(e) invisible(NULL)
  )
  Sys.sleep(delay_sec)
}

#' Bring Files pane to front, then set its directory (\code{filesPaneNavigate} alone can fail if the pane is not active).
#' @noRd
navigate_files_pane <- function(path) {
  files_pane_to_front(0.12)
  filesPaneNavigate(path)
}

#' One short English console message (not a dialog): working directory + Files pane path.
#' @noRd
notify_sync <- function(target_dir, opened_file = NULL, file_skipped = FALSE) {
  lines <- c(
    paste0(
      "[rstudio.clipboard.path] Files pane brought forward; working directory and Files location set to:\n  ",
      target_dir
    )
  )
  if (!is.null(opened_file)) {
    lines <- c(lines, paste0("  Opened in editor: ", opened_file))
  } else if (isTRUE(file_skipped)) {
    lines <- c(lines, "  (Clipboard points to a non-R file; left unopened in editor.)")
  }
  message(paste(lines, collapse = "\n"), domain = NA)
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
  # Show Files first so later navigation is reliable if another tab was active.
  files_pane_to_front(0.2)

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
    return(invisible(path_abs))
  }

  dir_abs <- normalize_existing_path(dirname(path_abs))
  setwd(dir_abs)
  navigate_files_pane(dir_abs)

  if (is_r_ecosystem_file(path_abs)) {
    navigateToFile(path_abs)
    notify_sync(dir_abs, opened_file = path_abs)
  } else {
    notify_sync(dir_abs, file_skipped = TRUE)
  }
  invisible(path_abs)
}
