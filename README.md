# RStudio clipboard path (`rstudio.clipboard.path`)

This repo ships an **RStudio add-in**: choose it from the **Addins** menu (or bind a keyboard shortcut). It **reads whatever path is on your system clipboard**; if that path exists on disk, it updates the **working directory** and **Files** pane (and **opens** the file when it looks like a common R-related file—see below).

**Chinese:** [README-zh.md](README-zh.md)

## Not a coding library

You do **not** use this like a normal R package in your scripts—no `library()` in day-to-day work. RStudio add-ins are **installed once** as a small package (that is how RStudio loads them); after that you only trigger the add-in from the menu or shortcut.

## Requirements

- **RStudio** (`rstudioapi`).
- **Windows, macOS, or Linux** — clipboard via [`clipr`](https://CRAN.R-project.org/package=clipr).
- **Linux:** if the clipboard is unavailable, install **xclip** or **xsel** (X11) or **wl-clipboard** (Wayland).

**Why is `clipr` installed?** This add-in depends on the **`clipr`** package to read the clipboard on Windows, macOS, and Linux. You do not install `clipr` separately for normal use—`install.packages()` pulls it in automatically. The **Browse Addins** list may also show other add-ins that ship *inside* `clipr` (“Output to clipboard”, etc.); those are optional and unrelated to running **RStudio clipboard path**.

## One-time install

Point at the package directory inside this repo (folder may still be named `tcwd` on disk). The installed package name is **`rstudio.clipboard.path`** (R does not allow spaces in package names).

From a local clone:

```r
install.packages("/path/to/RStudio-set-path/tcwd", repos = NULL, type = "source")
```

From GitHub (after you publish the repo; replace `OWNER` and `REPO`):

```r
# install.packages("remotes")
remotes::install_github("OWNER/REPO", subdir = "tcwd")
```

Then restart RStudio. If you previously installed the old name `clippath`, run `remove.packages("clippath")` once to avoid two copies.

## Daily use

1. Copy a **folder** or **file** path to the clipboard (only the first line is used if there are several).
2. Run the add-in using any option below.

Quoted paths and a leading UTF-8 BOM are tolerated.

### Faster access (RStudio cannot put add-ins in the File/Edit menu)

Add-ins are **not allowed** to attach to the top menu bar (File, Edit, …). That is an RStudio limitation, not something this package can change. This package **does not ship a default shortcut**; pick your own in RStudio if you want one.

| Method | How |
|--------|-----|
| **Toolbar Addins** | Use the **Addins** control on the **main toolbar** (near Run). It has a **search box**—you do not need **Tools → Browse Addins** every time. |
| **Keyboard shortcut** | **Tools → Modify Keyboard Shortcuts** → search **RStudio clipboard path** → press the shortcut field and type **any** combination that is still free on your system. |

### Behaviour

| Clipboard points to | Working dir + Files pane | Open in editor |
|---------------------|--------------------------|----------------|
| Existing directory  | That directory           | No             |
| File with R-ecosystem extension / `.Rprofile` / `.Renviron` | Parent of file | Yes        |
| Other existing file | Parent of file           | No             |

**Extensions treated as “open in editor”** (case-insensitive):  
`r`, `rmd`, `qmd`, `rnw`, `rhtml`, `rd`, `rproj`, `rpres`, `rhistory`, `c`, `cpp`, `cc`, `cxx`, `h`, `hpp`, `f`, `f90`, plus basenames `.Rprofile` and `.Renviron`.

## Layout

- Add-in code: [`tcwd/R/sync_path_from_clipboard.R`](tcwd/R/sync_path_from_clipboard.R)
- Registration: [`tcwd/inst/rstudio/addins.dcf`](tcwd/inst/rstudio/addins.dcf)

## Licence

See [`tcwd/LICENSE`](tcwd/LICENSE).

## Publishing the project

**GitHub (typical first step)**  
1. Create a new empty repository on GitHub (no README if you already have one locally).  
2. In this folder:

```bash
git init
git add .
git commit -m "Initial commit: rstudio.clipboard.path add-in"
git branch -M main
git remote add origin https://github.com/OWNER/REPO.git
git push -u origin main
```

Replace `OWNER/REPO` with your account and repository name. Then update the `remotes::install_github("OWNER/REPO", subdir = "tcwd")` line above.

**Other outlets (optional)**

| Outlet | What it is |
|--------|------------|
| **[CRAN](https://cran.r-project.org/submit.html)** | Official R archive. Users can `install.packages("rstudio.clipboard.path")`. Requires passing `R CMD check`, policy compliance, and maintainer email on DESCRIPTION (you already have one). |
| **[R-universe](https://r-universe.dev/)** | Build binaries from GitHub; easier than CRAN for many small packages. |
| **Posit / RStudio** | No separate “add-in store”; discovery is usually GitHub, CRAN, blog posts, or [RStudio Community](https://forum.posit.co/). |
| **`devtools` / blog** | Announcing on social media or a short blog post with the `install_github` one-liner is often enough for niche tools. |
