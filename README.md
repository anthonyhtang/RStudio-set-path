# RStudio clipboard path (`rstudio.clipboard.path`)

**Language: English** · **中文说明:** [README-zh.md](README-zh.md) · **Repository:** [github.com/anthonyhtang/RStudio-set-path](https://github.com/anthonyhtang/RStudio-set-path)

This repository contains an **RStudio add-in** (R package name `rstudio.clipboard.path`). It reads a **folder or file path** from the system clipboard; if that path exists, it sets the **working directory** and **Files** pane, and **opens** the file in the editor when it looks like a common R-related file (see **Behaviour** below).

---

## Not a coding library

Do **not** `library()` this in everyday scripts. Install it **once**; after that, run the add-in from the **Addins** menu, the **command palette**, or a shortcut you assign yourself.

## Requirements

- **RStudio** (uses `rstudioapi`).
- **Windows, macOS, or Linux** — clipboard via [`clipr`](https://CRAN.R-project.org/package=clipr).
- **Linux:** if the clipboard is unavailable, install **xclip** or **xsel** (X11) or **wl-clipboard** (Wayland).

Installing this package pulls in **`clipr`** automatically. Other entries you may see under the **clipr** package in the add-in list (e.g. “Output to clipboard”) are unrelated to **RStudio clipboard path**.

## Installation

The R package sources are in the **`rstudio.clipboard.path/`** directory (same name as the **installed** package `rstudio.clipboard.path`, not `tcwd`).

### Option A — From GitHub (no local paths)

```r
install.packages("remotes")  # if you do not have it yet
remotes::install_github("anthonyhtang/RStudio-set-path", subdir = "rstudio.clipboard.path")
```

(Fork? Use `yourname/RStudio-set-path` instead, or install from the default branch of your fork.)

### Option B — From a local clone (relative path)

1. Clone or download this repository.
2. In RStudio, set the working directory to the **repository root** — the folder that **contains** the `rstudio.clipboard.path` directory (e.g. **Session → Set Working Directory → Choose Directory…**).
3. Run **one** of the following (both use the **`rstudio.clipboard.path`** folder relative to your current working directory):

```r
install.packages("rstudio.clipboard.path", repos = NULL, type = "source")
```

```r
install.packages("remotes")
remotes::install_local("rstudio.clipboard.path")
```

Do **not** paste a full `C:\...` or `/home/...` path unless you prefer; keeping the session at the repo root and using `"rstudio.clipboard.path"` is enough.

### After installing

Restart **RStudio**. If you ever installed the old package name **`clippath`**, remove it once: `remove.packages("clippath")`.

## Daily use

1. Copy a **folder** or **file** path to the clipboard (only the first line is used if there are several).
2. Run the add-in using any method in **Quick ways to run the add-in** below.

Quoted paths and a leading UTF-8 BOM are tolerated.

## Quick ways to run the add-in

RStudio does **not** let packages add items to the top **File / Edit** menu. This package ships **no default shortcut**; assign one yourself if you want it.

| Method | How |
|--------|-----|
| **Command palette** | **Windows / Linux:** `Ctrl+Shift+P` · **macOS:** `Cmd+Shift+P`. Or **Tools → Show Command Palette**. Type `RStudio clipboard path` or `clipboard` and choose the add-in. |
| **Toolbar Addins** | Use the **Addins** control on the **main toolbar** (near **Run**). It includes a **search box** so you can avoid **Tools → Browse Addins…** every time. |
| **Custom shortcut** | **Tools → Modify Keyboard Shortcuts** → search **RStudio clipboard path** → click the shortcut cell and press **any** free key combination you like. |

## Behaviour

| Clipboard points to | Working directory + Files pane | Open file in editor |
|---------------------|--------------------------------|----------------------|
| Existing directory | That directory | No |
| File with R-ecosystem extension, or `.Rprofile` / `.Renviron` | Parent of the file | Yes |
| Other existing file | Parent of the file | No |

**Extensions treated as “open in editor”** (case-insensitive):  
`r`, `rmd`, `qmd`, `rnw`, `rhtml`, `rd`, `rproj`, `rpres`, `rhistory`, `c`, `cpp`, `cc`, `cxx`, `h`, `hpp`, `f`, `f90`, plus basenames `.Rprofile` and `.Renviron`.

## Repository layout

| Path | Purpose |
|------|---------|
| [`rstudio.clipboard.path/R/sync_path_from_clipboard.R`](rstudio.clipboard.path/R/sync_path_from_clipboard.R) | Add-in implementation |
| [`rstudio.clipboard.path/inst/rstudio/addins.dcf`](rstudio.clipboard.path/inst/rstudio/addins.dcf) | RStudio registration |

## Licence

See [`rstudio.clipboard.path/LICENSE`](rstudio.clipboard.path/LICENSE).

## Repository & contributing

**Source:** [github.com/anthonyhtang/RStudio-set-path](https://github.com/anthonyhtang/RStudio-set-path)

```bash
git clone https://github.com/anthonyhtang/RStudio-set-path.git
cd RStudio-set-path
# edit, then commit and push (default branch: main)
```

## Other distribution outlets (optional)

| Outlet | What it is |
|--------|------------|
| **[CRAN](https://cran.r-project.org/submit.html)** | Official R archive; users run `install.packages("rstudio.clipboard.path")`. Requires `R CMD check` and policy compliance. |
| **[R-universe](https://r-universe.dev/)** | Builds from GitHub; lighter than CRAN for many small packages. |
| **Posit / RStudio** | No separate add-in store; discovery is usually GitHub, CRAN, blogs, or [Posit Community](https://forum.posit.co/). |
