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

#' First line of clipboard as a path, or \code{NA_character_} if unusable (no throw).
#' @noRd
peek_clipboard_path_safe <- function() {
  if (!clipr::clipr_available()) {
    return(NA_character_)
  }
  raw <- tryCatch(
    clipr::read_clip(allow_non_interactive = TRUE),
    error = function(e) NULL
  )
  if (is.null(raw) || !length(raw)) {
    return(NA_character_)
  }
  raw <- trimws(raw)
  if (!length(raw)) {
    return(NA_character_)
  }
  path <- paste(raw, collapse = "\n")
  path <- sub("\n.*", "", path, perl = TRUE)
  path <- strip_bom(path)
  path <- strip_outer_quotes(path)
  path <- trimws(path)
  if (!nzchar(path)) {
    return(NA_character_)
  }
  if (!file.exists(path) && !dir.exists(path)) {
    return(NA_character_)
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

#' Set \code{setwd} + Files pane from an existing file or directory path; may open R files.
#' @noRd
apply_wd_from_existing_path <- function(path_clean) {
  path_abs <- normalize_existing_path(path_clean)
  if (dir.exists(path_abs)) {
    setwd(path_abs)
    filesPaneNavigate(path_abs)
    return(invisible(path_abs))
  }
  dir_abs <- normalize_existing_path(dirname(path_abs))
  setwd(dir_abs)
  filesPaneNavigate(dir_abs)
  if (is_r_ecosystem_file(path_abs)) {
    navigateToFile(path_abs)
  }
  invisible(path_abs)
}

#' @noRd
quick_wd_from_clipboard_only <- function() {
  path_clean <- read_path_from_clipboard()
  if (!file.exists(path_clean) && !dir.exists(path_clean)) {
    stop(
      "Path does not exist (after cleaning):\n", path_clean,
      call. = FALSE
    )
  }
  apply_wd_from_existing_path(path_clean)
}

#' @noRd
quick_wd_from_active_file_only <- function() {
  ctx <- getActiveDocumentContext()
  path_raw <- ctx$path
  if (is.null(path_raw) || !nzchar(path_raw)) {
    stop(
      "The active editor has no file path (e.g. an unsaved Untitled document). ",
      "Save the file or open one from disk, then run this add-in again.",
      call. = FALSE
    )
  }
  if (!file.exists(path_raw) && !dir.exists(path_raw)) {
    stop(
      "Active path does not exist on disk:\n", path_raw,
      call. = FALSE
    )
  }
  path_abs <- normalize_existing_path(path_raw)
  dir_abs <- if (dir.exists(path_abs)) {
    path_abs
  } else {
    normalize_existing_path(dirname(path_abs))
  }
  setwd(dir_abs)
  filesPaneNavigate(dir_abs)
  invisible(path_abs)
}

#' RStudio add-in: quick working directory (clipboard and/or active file).
#'
#' One manually triggered add-in with two capabilities: (1) set wd from a path on
#' the clipboard, (2) set wd from the on-disk path of the file in the active
#' source tab (parent folder; \code{getActiveDocumentContext()$path}). With
#' \code{source = "default"}, each run first checks the clipboard for a valid
#' existing path (first line); if none, it uses the active tab path. \code{"clipboard"}
#' and \code{"active"} force one source only.
#'
#' @param source One of \code{"default"}, \code{"clipboard"}, \code{"active"}.
#'   The add-in binding uses \code{"default"}. From the console, use
#'   \code{quick_working_directory("clipboard")} or \code{...("active")} when you
#'   want a single capability regardless of clipboard contents.
#'
#' @return Normalized absolute path used for \code{setwd} / navigation (invisibly).
#' @export
quick_working_directory <- function(source = c("default", "clipboard", "active")) {
  if (!isAvailable()) {
    stop("This add-in must be run inside RStudio.", call. = FALSE)
  }
  if (!missing(source) && length(source) == 1L && identical(source, "auto")) {
    source <- "default"
  }
  source <- match.arg(source)

  if (source == "clipboard") {
    return(quick_wd_from_clipboard_only())
  }
  if (source == "active") {
    return(quick_wd_from_active_file_only())
  }

  clip_path <- peek_clipboard_path_safe()
  if (!is.na(clip_path)) {
    return(apply_wd_from_existing_path(clip_path))
  }
  quick_wd_from_active_file_only()
}
