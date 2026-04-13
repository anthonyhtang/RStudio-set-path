norm_existing_path <- function(path) {
  if (.Platform$OS.type == "windows") {
    normalizePath(path, winslash = "\\", mustWork = TRUE)
  } else {
    normalizePath(path, mustWork = TRUE)
  }
}

load_addin_env <- function() {
  env <- new.env(parent = baseenv())
  sys.source("rstudio.quickwd/R/quick_wd_addins.R", envir = env)
  env
}

assert_true <- function(condition, message) {
  if (!isTRUE(condition)) {
    stop(message, call. = FALSE)
  }
}

assert_identical <- function(actual, expected, message) {
  if (!identical(actual, expected)) {
    stop(
      paste0(
        message, "\nExpected: ", paste(capture.output(str(expected)), collapse = " "),
        "\nActual: ", paste(capture.output(str(actual)), collapse = " ")
      ),
      call. = FALSE
    )
  }
}

test_active_file_retries_then_sets_wd <- function() {
  env <- load_addin_env()
  file_path <- tempfile(pattern = "quickwd-active-", fileext = ".R")
  writeLines("x <- 1", file_path)

  attempts <- 0L
  nav_paths <- character()
  command_calls <- list()
  console_calls <- list()
  call_order <- character()

  env$getSourceEditorContext <- function() {
    attempts <<- attempts + 1L
    if (attempts == 1L) {
      return(list(path = ""))
    }
    list(path = file_path)
  }
  env$getActiveDocumentContext <- function() list(path = "")
  env$filesPaneNavigate <- function(path) {
    nav_paths <<- c(nav_paths, path)
    call_order <<- c(call_order, "filesPaneNavigate")
  }
  env$executeCommand <- function(commandId, quiet = FALSE) {
    call_order <<- c(call_order, "executeCommand")
    command_calls <<- c(command_calls, list(list(commandId = commandId, quiet = quiet)))
    invisible(NULL)
  }
  env$sendToConsole <- function(command, execute = FALSE) {
    call_order <<- c(call_order, "sendToConsole")
    console_calls <<- c(console_calls, list(list(command = command, execute = execute)))
    invisible(NULL)
  }
  env$isAvailable <- function() TRUE
  env$navigateToFile <- function(path) stop("navigateToFile should not be called in active-file mode.")

  old_wd <- getwd()
  on.exit(setwd(old_wd), add = TRUE)

  result <- env$quick_wd_from_active_file_only()
  file_abs <- norm_existing_path(file_path)
  dir_abs <- norm_existing_path(dirname(file_path))

  assert_identical(result, file_abs, "Active-file mode should return the normalized file path.")
  assert_identical(norm_existing_path(getwd()), dir_abs, "Active-file mode should set the working directory to the file directory.")
  assert_identical(attempts, 2L, "Active-file mode should retry when the first source lookup is empty.")
  assert_identical(nav_paths, dir_abs, "Files pane should navigate to the file directory.")
  assert_true(length(command_calls) == 1L, "Files pane activation should run exactly once.")
  assert_identical(command_calls[[1L]]$commandId, "activateFiles", "Files pane activation should use activateFiles.")
  assert_identical(command_calls[[1L]]$quiet, TRUE, "Files pane activation should be quiet for compatibility.")
  assert_true(length(console_calls) == 1L, "setwd announcement should be sent once.")
  assert_identical(console_calls[[1L]]$execute, TRUE, "setwd announcement should execute in the console.")
  assert_identical(call_order, c("filesPaneNavigate", "sendToConsole", "executeCommand"), "UI sync should finish by activating the Files pane.")
}

test_clipboard_file_path_opens_editor_and_files_pane <- function() {
  env <- load_addin_env()
  file_path <- tempfile(pattern = "quickwd-clipboard-", fileext = ".R")
  writeLines("y <- 2", file_path)

  nav_paths <- character()
  command_calls <- list()
  console_calls <- list()
  opened_files <- character()
  call_order <- character()

  env$filesPaneNavigate <- function(path) {
    nav_paths <<- c(nav_paths, path)
    call_order <<- c(call_order, "filesPaneNavigate")
  }
  env$executeCommand <- function(commandId, quiet = FALSE) {
    call_order <<- c(call_order, "executeCommand")
    command_calls <<- c(command_calls, list(list(commandId = commandId, quiet = quiet)))
    invisible(NULL)
  }
  env$sendToConsole <- function(command, execute = FALSE) {
    call_order <<- c(call_order, "sendToConsole")
    console_calls <<- c(console_calls, list(list(command = command, execute = execute)))
    invisible(NULL)
  }
  env$isAvailable <- function() TRUE
  env$navigateToFile <- function(path) opened_files <<- c(opened_files, path)

  old_wd <- getwd()
  on.exit(setwd(old_wd), add = TRUE)

  result <- env$apply_wd_from_existing_path(file_path)
  file_abs <- norm_existing_path(file_path)
  dir_abs <- norm_existing_path(dirname(file_path))

  assert_identical(result, file_abs, "Clipboard file mode should return the normalized file path.")
  assert_identical(norm_existing_path(getwd()), dir_abs, "Clipboard file mode should set the working directory to the file directory.")
  assert_identical(nav_paths, dir_abs, "Files pane should navigate to the clipboard file directory.")
  assert_true(length(command_calls) == 1L, "Files pane activation should run exactly once for clipboard file paths.")
  assert_identical(command_calls[[1L]]$commandId, "activateFiles", "Clipboard file mode should activate the Files pane.")
  assert_identical(opened_files, file_abs, "R files from the clipboard should open in the source editor.")
  assert_true(length(console_calls) == 1L, "Clipboard file mode should announce setwd once.")
  assert_identical(call_order[1:3], c("filesPaneNavigate", "sendToConsole", "executeCommand"), "Clipboard mode should activate the Files pane after announcing setwd.")
}

test_active_file_retries_then_sets_wd()
test_clipboard_file_path_opens_editor_and_files_pane()

cat("All quickwd regression tests passed.\n")
