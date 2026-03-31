# RStudio 剪贴板路径插件（`rstudio.clipboard.path`）

**语言：中文** · **English:** [README.md](README.md) · **源码仓库：** [github.com/anthonyhtang/RStudio-set-path](https://github.com/anthonyhtang/RStudio-set-path)

本仓库提供一个 **RStudio 插件**（安装后的 R 包名为 **`rstudio.clipboard.path`**）。它会读取**系统剪贴板**里的**目录或文件路径**；若路径存在，则设置 **Working Directory** 与 **Files** 窗格；若判断为常见 **R 相关文件**，还会在编辑器中**打开**该文件（见下文 **行为说明**）。

---

## 不是日常编程用的「库」

不要在日常脚本里 `library()` 本包。只需**安装一次**，之后通过 **Addins**、**命令面板** 或**自己绑定的快捷键**运行插件即可。

## 环境与依赖

- **RStudio**（依赖 `rstudioapi`）。
- **Windows / macOS / Linux**，剪贴板通过 CRAN 包 **`clipr`**。
- **Linux**：若无法读剪贴板，请安装 **xclip**、**xsel**（X11）或 **wl-clipboard**（Wayland）。

安装本插件时会**自动**安装 **`clipr`**。Addins 列表里若还有 **`clipr`** 自带的其它项（如 “Output to clipboard”），与 **RStudio clipboard path** 无关。

## 安装说明

插件源码在仓库的 **`rstudio.clipboard.path/`** 目录下（与 R 包名一致；**不再使用**误导性的旧文件夹名 `tcwd`）。

### 方式 A — 从 GitHub 安装（无需本地路径）

```r
install.packages("remotes")  # 若尚未安装
remotes::install_github("anthonyhtang/RStudio-set-path", subdir = "rstudio.clipboard.path")
```

（若你 fork 了本仓库，把上面的 `anthonyhtang/RStudio-set-path` 换成 `你的用户名/仓库名`。）

### 方式 B — 从本地克隆安装（使用相对路径）

1. 克隆或下载本仓库到本机任意位置。
2. 在 RStudio 中，把**工作目录**设为**仓库根目录**（即**包含** `rstudio.clipboard.path` 文件夹的那一层）。可用 **Session → Set Working Directory → Choose Directory…**。
3. 在控制台执行**下面任选其一**（`"rstudio.clipboard.path"` 相对于**当前工作目录**，无需写 `C:\...` 等绝对路径）：

```r
install.packages("rstudio.clipboard.path", repos = NULL, type = "source")
```

```r
install.packages("remotes")
remotes::install_local("rstudio.clipboard.path")
```

### 安装之后

**重启 RStudio**。若曾安装过旧包名 **`clippath`**，请执行一次：`remove.packages("clippath")`。

## 日常使用

1. 将**目录或文件**的完整路径复制到剪贴板（多行时只使用与实现一致的首行逻辑）。
2. 用下文 **快速运行插件** 中的任一方式执行。

支持带引号路径与 UTF-8 BOM。

## 快速运行插件

RStudio **不允许**把插件挂到 **File / Edit** 等顶层菜单。本包**不自带默认快捷键**，需要请自行在快捷键设置里绑定。

| 方式 | 操作 |
|------|------|
| **命令面板（推荐快速唤起）** | **Windows / Linux：** `Ctrl+Shift+P` · **macOS：** `Cmd+Shift+P`。或菜单 **Tools → Show Command Palette**。输入 **`RStudio clipboard path`** 或 **`clipboard`**，选中对应插件回车。 |
| **工具栏 Addins** | 主工具栏 **Addins** 下拉（在 **Run** 附近），带**搜索框**，可少用 **Browse Addins**。 |
| **自定义快捷键** | **Tools → Modify Keyboard Shortcuts** → 搜索 **RStudio clipboard path** → 在快捷键栏按下**任意**未占用的组合键。 |

## 行为说明

| 剪贴板内容 | Working Directory + Files 窗格 | 是否在编辑器打开文件 |
|------------|--------------------------------|----------------------|
| 已存在的目录 | 该目录 | 否 |
| 带 R 常见扩展名的文件，或 `.Rprofile` / `.Renviron` | 该文件所在目录 | 是 |
| 其它已存在文件 | 该文件所在目录 | 否 |

**会在编辑器中打开的文件扩展名**（不区分大小写）：  
`r`, `rmd`, `qmd`, `rnw`, `rhtml`, `rd`, `rproj`, `rpres`, `rhistory`, `c`, `cpp`, `cc`, `cxx`, `h`, `hpp`, `f`, `f90`，以及文件名为 `.Rprofile`、`.Renviron` 的情况。

## 仓库结构

| 路径 | 说明 |
|------|------|
| [`rstudio.clipboard.path/R/sync_path_from_clipboard.R`](rstudio.clipboard.path/R/sync_path_from_clipboard.R) | 插件实现代码 |
| [`rstudio.clipboard.path/inst/rstudio/addins.dcf`](rstudio.clipboard.path/inst/rstudio/addins.dcf) | RStudio 注册信息 |

## 许可证

见 [`rstudio.clipboard.path/LICENSE`](rstudio.clipboard.path/LICENSE)。

## 公开与分发（概要）

- **GitHub**：默认仓库 [anthonyhtang/RStudio-set-path](https://github.com/anthonyhtang/RStudio-set-path)；安装命令见上文 **方式 A**。克隆：`git clone https://github.com/anthonyhtang/RStudio-set-path.git`。更多分发渠道见英文 [README.md](README.md) 末尾。
