# RStudio quick working directory (`rstudio.quickwd`)

**Language: English** · **中文说明:** [README-zh.md](README-zh.md) · **Repository:** [github.com/anthonyhtang/rstudio-quick-working-directory](https://github.com/anthonyhtang/rstudio-quick-working-directory)

## Overview

`rstudio.quickwd` installs one RStudio add-in, **RStudio quick working directory**. When you run it (palette, Addins menu, or a shortcut), it updates `setwd()` and the **Files** pane using either:

- a **path from the clipboard** (folder or file), or  
- the **parent folder** of the file you have open in the editor, using that file’s **actual path on disk** (RStudio’s path for the active tab; it must still exist),

depending on what applies on that run. If the clipboard’s first line is an existing path, that is used (with the file-opening rules described under **Behaviour**). Otherwise the add-in reads the **on-disk path** of the **active source tab** and sets the working directory to that path’s **parent folder** (unsaved **Untitled** documents have no on-disk path). Nothing runs in the background; it only acts when you invoke it.

From the **R console** you can restrict to one source: `quick_working_directory("clipboard")` or `quick_working_directory("active")` (see below).

---

## Running it in RStudio

Install the package, restart RStudio once. The add-in is declared in [`addins.dcf`](rstudio.quickwd/inst/rstudio/addins.dcf):

| Name | Effect |
|------|--------|
| **RStudio quick working directory** | Clipboard path (first line) if valid; else parent folder of the active tab’s on-disk file path. Details below. |

| Where | How |
|--------|-----|
| **Tools → Browse Addins…** | Search the list, **Run**. |
| **Toolbar** | **Addins** dropdown (near **Run**). |
| **Command palette** | **Tools → Show Command Palette** — also under **Fastest way to run the add-in** below. |

---

## Not a coding library

Do **not** `library()` this in everyday scripts. Install it **once**; after that, run the add-in from the **command palette** (recommended), **Browse Addins**, the toolbar **Addins** menu, or a **shortcut** you assign yourself.

## Requirements

- **RStudio** (uses `rstudioapi`).
- **Windows, macOS, or Linux** — clipboard via [`clipr`](https://CRAN.R-project.org/package=clipr) (used when deciding clipboard vs active file on each run, and required for `quick_working_directory("clipboard")`).
- **Linux:** if the clipboard is unavailable, install **xclip** or **xsel** (X11) or **wl-clipboard** (Wayland).

Installing this package pulls in **`clipr`** automatically. Other entries you may see under the **clipr** package in the add-in list (e.g. “Output to clipboard”) are unrelated to this package.

## Installation

The R package sources live in the **`rstudio.quickwd/`** directory (same name as the **installed** package).

### Option A — From GitHub (no local paths)

```r
install.packages("remotes")  # if you do not have it yet
remotes::install_github("anthonyhtang/rstudio-quick-working-directory", subdir = "rstudio.quickwd")
```

(Fork? Use `yourname/rstudio-quick-working-directory` instead, or install from the default branch of your fork.)

### Option B — From a local clone (relative path)

1. Clone or download this repository.
2. In RStudio, set the working directory to the **repository root** — the folder that **contains** the `rstudio.quickwd` directory (e.g. **Session → Set Working Directory → Choose Directory…**).
3. Run **one** of the following (both use the **`rstudio.quickwd`** folder relative to your current working directory):

```r
install.packages("rstudio.quickwd", repos = NULL, type = "source")
```

```r
install.packages("remotes")
remotes::install_local("rstudio.quickwd")
```

Do **not** paste a full `C:\...` or `/home/...` path unless you prefer; keeping the session at the repo root and using `"rstudio.quickwd"` is enough.

### After installing

Restart **RStudio**.

### Renamed from the old package / repo

Canonical GitHub repo: **`anthonyhtang/rstudio-quick-working-directory`**. The R package lives in the **`rstudio.quickwd/`** subdirectory. If you previously used the old repo name locally, run `git remote set-url origin https://github.com/anthonyhtang/rstudio-quick-working-directory.git`. Replace older installs of **`rstudio.clipboard.path`** with **`rstudio.quickwd`** as above.

## Daily use

1. **To prefer the clipboard:** copy a **folder** or **file** path (only the first line is used if there are several), then run the add-in. Quoted paths and a leading UTF-8 BOM are tolerated.
2. **To use the open file instead:** clear the clipboard or ensure it does **not** contain a valid path, focus a source tab whose file **has a path on disk** (not **Untitled**), then run the same add-in.

If the clipboard still holds an **old but valid** path, the next run will follow the clipboard first. To use **only** the active tab’s on-disk path (parent folder), run `rstudio.quickwd::quick_working_directory("active")` in the console, or clear/replace the clipboard text.

## Fastest way to run the add-in (keyboard, no mouse)

**Use the Command Palette:** press the shortcut, type a keyword, press **Enter**.

| OS | Default shortcut for **Show Command Palette** |
|----|-----------------------------------------------|
| **Windows / Linux** | **Ctrl+Shift+P** |
| **macOS** | **Cmd+Shift+P** |

You can also open it from the menu: **Tools → Show Command Palette**.

Then search e.g. **`quick working`**, **`RStudio quick`**, **`working directory`**, **`quick wd`**.

**If your shortcut is different** (for example you remapped it to **Ctrl+Alt+P**): go to **Tools → Modify Keyboard Shortcuts**, search **`Show Command Palette`**, and use whatever key combination RStudio shows there.

Official overview: [Command Palette – RStudio / Posit](https://docs.posit.co/ide/user/ide/guide/ui/command-palette.html).

## Custom shortcut (optional)

This package does **not** ship a default keybinding. To bind your own:

1. **Tools → Modify Keyboard Shortcuts**
2. Search **`RStudio quick working directory`** (or scroll the **Addins** section)
3. Click the **Shortcut** cell and press any **unused** key combination

[Custom shortcuts – RStudio / Posit](https://docs.posit.co/ide/user/ide/guide/productivity/custom-shortcuts.html)

## Other ways to run the add-in

| Method | How |
|--------|-----|
| **Toolbar Addins** | **Addins** on the **main toolbar** (near **Run**) — search box → **RStudio quick working directory**. |
| **Browse Addins** | **Tools → Browse Addins…** → search **quick** → **Run**. |
| **R Console** | `rstudio.quickwd::quick_working_directory()` — same as the add-in (`source = "default"`). Optional: `quick_working_directory("clipboard")` or `quick_working_directory("active")` for clipboard-only or active-file-only. |

### Command palette does not show the add-in?

- **Restart RStudio** once after `install_github` so add-ins are rescanned.
- Try **`addin`**, **`quick`**, **`working`**, **`directory`** (English).
- Reliable path: **Tools → Browse Addins…** → search **RStudio quick working directory** → **Run**.

## Behaviour

### Default (`quick_working_directory()` and the add-in)

On **each** invocation you trigger:

1. If the clipboard yields a **usable path** that **exists** on disk → same rules as **From clipboard** below.
2. Else → same rules as **From active file** below.

### From clipboard (when the clipboard qualifies on that run, or `source = "clipboard"`)

| Clipboard points to | Working directory + Files pane | Open file in editor |
|---------------------|--------------------------------|----------------------|
| Existing directory | That directory | No |
| File with R-ecosystem extension, or `.Rprofile` / `.Renviron` | Parent of the file | Yes |
| Other existing file | Parent of the file | No |

**Extensions treated as “open in editor”** (case-insensitive):  
`r`, `rmd`, `qmd`, `rnw`, `rhtml`, `rd`, `rproj`, `rpres`, `rhistory`, `c`, `cpp`, `cc`, `cxx`, `h`, `hpp`, `f`, `f90`, plus basenames `.Rprofile` and `.Renviron`.

### From active file (when the clipboard does not qualify on that run, or `source = "active"`)

Uses `rstudioapi::getActiveDocumentContext()` — the **path string** RStudio reports for the **focused source tab**. Working directory becomes the **parent** of that path (or the path itself if it is a directory).

| Situation | Result |
|-----------|--------|
| Active tab has an **on-disk path** that still exists | `setwd()` + Files pane → **parent folder** of that path (or the directory if the tab is a folder path). |
| Active tab is **Untitled** / no path on disk | Error: save to a file or put a valid path on the clipboard. |
| Reported path no longer exists on disk | Error. |

Does **not** call `navigateToFile()` here — the document is already open.

## Repository layout

| Path | Purpose |
|------|---------|
| [`rstudio.quickwd/R/quick_wd_addins.R`](rstudio.quickwd/R/quick_wd_addins.R) | Add-in implementation |
| [`rstudio.quickwd/inst/rstudio/addins.dcf`](rstudio.quickwd/inst/rstudio/addins.dcf) | RStudio registration |

## Licence

See [`rstudio.quickwd/LICENSE`](rstudio.quickwd/LICENSE).

## Repository & contributing

**Source:** [github.com/anthonyhtang/rstudio-quick-working-directory](https://github.com/anthonyhtang/rstudio-quick-working-directory)

```bash
git clone https://github.com/anthonyhtang/rstudio-quick-working-directory.git
cd rstudio-quick-working-directory
# edit, then commit and push (default branch: main)
```

## Other distribution outlets (optional)

| Outlet | What it is |
|--------|------------|
| **[CRAN](https://cran.r-project.org/submit.html)** | Official R archive; users run `install.packages("rstudio.quickwd")`. Requires `R CMD check` and policy compliance. |
| **[R-universe](https://r-universe.dev/)** | Builds from GitHub; lighter than CRAN for many small packages. |
| **Posit / RStudio** | No separate add-in store; discovery is usually GitHub, CRAN, blogs, or [Posit Community](https://forum.posit.co/). |
