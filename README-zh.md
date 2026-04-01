# RStudio quick working directory（`rstudio.quickwd`）

**语言：中文** · **English:** [README.md](README.md) · **源码仓库：** [github.com/anthonyhtang/rstudio-quick-working-directory](https://github.com/anthonyhtang/rstudio-quick-working-directory)

## 概述

`rstudio.quickwd` 向 RStudio 登记一个插件：**RStudio quick working directory**。你在命令面板、Addins 菜单或自定义快捷键里**手动运行**它时，会按当前情况更新 `setwd()` 与 **Files** 窗格，数据来源可以是：

- **剪贴板里的路径**（目录或文件），或  
- **当前在编辑器里打开、且 RStudio 能给出磁盘路径的文件**：用该文件的**实际路径**（须仍在磁盘上存在），把工作目录设为该路径的**所在文件夹**（即父目录）。

若剪贴板首行解析为磁盘上存在的路径，则按该路径处理（是否在编辑器打开文件见下文 **行为说明**）；否则改用**当前活动源标签页**对应的**磁盘路径**的父目录；**Untitled** 等没有磁盘路径的标签页无法走这一条。插件不会在后台自行执行。

在 **R 控制台**可限定只走一种来源：`quick_working_directory("clipboard")` 或 `quick_working_directory("active")`（见下文）。

---

## 在 RStudio 里运行

装好本包后**重启一次 RStudio**。插件登记在 [`addins.dcf`](rstudio.quickwd/inst/rstudio/addins.dcf)：

| 名称（与 RStudio 列表一致） | 作用 |
|----------------------------|------|
| **RStudio quick working directory** | 剪贴板首行为有效路径则用剪贴板；否则用**当前活动标签页**对应**磁盘路径**的父目录。细则见下文。 |

| 入口 | 操作 |
|------|------|
| **Tools → Browse Addins…** | 搜索后点 **Run**。 |
| **工具栏** | **Addins** 下拉（**Run** 附近）。 |
| **命令面板** | **Tools → Show Command Palette**；亦可参见下文 **推荐用法**。 |

---

## 不是日常编程用的「库」

不要在日常脚本里 `library()` 本包。只需**安装一次**；之后用 **命令面板 + 键盘**、**Browse Addins**、工具栏 **Addins** 或**自定义快捷键**调用**同一个**插件。

## 环境与依赖

- **RStudio**（依赖 `rstudioapi`）。
- **Windows / macOS / Linux**，剪贴板通过 CRAN 包 **`clipr`**（每次运行时要判断「剪贴板路径是否有效」会读剪贴板；`quick_working_directory("clipboard")` 也依赖它）。
- **Linux**：若无法读剪贴板，请安装 **xclip**、**xsel**（X11）或 **wl-clipboard**（Wayland）。

安装本包时会**自动**安装 **`clipr`**。Addins 列表里 **`clipr`** 自带的其它项（如 “Output to clipboard”）与本包无关。

## 安装说明

插件源码在仓库的 **`rstudio.quickwd/`** 目录下（与 R 安装后的包名一致）。

### 方式 A — 从 GitHub 安装（无需本地路径）

```r
install.packages("remotes")  # 若尚未安装
remotes::install_github("anthonyhtang/rstudio-quick-working-directory", subdir = "rstudio.quickwd")
```

（若你 fork 了本仓库，把上面的 `anthonyhtang/rstudio-quick-working-directory` 换成 `你的用户名/仓库名`。）

### 方式 B — 从本地克隆安装（使用相对路径）

1. 克隆或下载本仓库到本机任意位置。
2. 在 RStudio 中，把**工作目录**设为**仓库根目录**（即**包含** `rstudio.quickwd` 文件夹的那一层）。可用 **Session → Set Working Directory → Choose Directory…**。
3. 在控制台执行**下面任选其一**（`"rstudio.quickwd"` 相对于**当前工作目录**）：

```r
install.packages("rstudio.quickwd", repos = NULL, type = "source")
```

```r
install.packages("remotes")
remotes::install_local("rstudio.quickwd")
```

### 安装之后

**重启 RStudio**。

### 从旧仓库 / 旧包名迁移

GitHub 仓库：**`anthonyhtang/rstudio-quick-working-directory`**，R 包在其中的 **`rstudio.quickwd/`** 目录。若本地克隆曾指向旧仓库名，请执行 **`git remote set-url origin https://github.com/anthonyhtang/rstudio-quick-working-directory.git`**。若仍装着旧 R 包 **`rstudio.clipboard.path`**，请改装 **`rstudio.quickwd`** 并使用 **`subdir = "rstudio.quickwd"`**。

## 日常使用

1. **想按剪贴板来：** 复制**目录或文件**路径（多行时只使用首行逻辑），运行插件。支持带引号路径与 UTF-8 BOM。
2. **想按当前打开文件来：** 清空剪贴板或确保剪贴板**不是**有效路径，在编辑器里**聚焦**已有**磁盘路径**的标签页（不是 **Untitled**），再运行**同一**插件。

若剪贴板里仍是**旧但有效**的路径，下一次运行会**先按剪贴板**处理。若只想按**当前标签页磁盘路径**的父目录来，可在控制台执行 `rstudio.quickwd::quick_working_directory("active")`，或清空/改掉剪贴板内容。

## 推荐用法：命令面板 + 关键字（最快、尽量不用鼠标）

| 系统 | **Show Command Palette** 的默认快捷键 |
|------|----------------------------------------|
| **Windows / Linux** | **Ctrl+Shift+P** |
| **macOS** | **Cmd+Shift+P** |

也可：**Tools → Show Command Palette**。

在面板里可搜索，例如：**`quick working`**、**`RStudio quick`**、**`working directory`**、**`quick wd`**。

**若本机打开命令面板的不是 Ctrl+Shift+P**（例如 **Ctrl+Alt+P**）：**Tools → Modify Keyboard Shortcuts** → 搜 **`Show Command Palette`**，以其中显示为准。

说明：[Command Palette（Posit）](https://docs.posit.co/ide/user/ide/guide/ui/command-palette.html)

## 自定义快捷键（可选）

本包**不自带**默认快捷键。可为该插件绑定一组未占用组合键：

1. **Tools → Modify Keyboard Shortcuts**
2. 搜索 **`RStudio quick working directory`**
3. 在 **快捷键** 格子里设置

参考：[Custom shortcuts（Posit）](https://docs.posit.co/ide/user/ide/guide/productivity/custom-shortcuts.html)

## 其它运行方式

| 方式 | 操作 |
|------|------|
| **工具栏 Addins** | **Addins** → 搜索 **RStudio quick working directory** → 运行。 |
| **Browse Addins** | **Tools → Browse Addins…** → 搜索 **quick** → **Run**。 |
| **R 控制台** | `rstudio.quickwd::quick_working_directory()` — 与插件相同（`source = "default"`）。可选：`quick_working_directory("clipboard")` 或 `quick_working_directory("active")` 分别只走剪贴板或只走当前文件。 |

### 命令面板里搜不到？

- **重启 RStudio** 后再试。
- 可试 **`addin`**、**`quick`**、**`working`**、**`directory`** 等英文关键词。
- 最稳妥：**Tools → Browse Addins…** 搜索 **RStudio quick working directory** → **Run**。

## 行为说明

### 默认行为（插件与无参 `quick_working_directory()`）

在**每一次**你触发的运行里：

1. 若剪贴板解析出**可用且存在**的路径 → 与下文 **从剪贴板** 相同。
2. 否则 → 与下文 **从当前文件** 相同。

### 从剪贴板（当本次运行剪贴板符合条件时，或 `source = "clipboard"`）

| 剪贴板内容 | Working Directory + Files 窗格 | 是否在编辑器打开文件 |
|------------|--------------------------------|----------------------|
| 已存在的目录 | 该目录 | 否 |
| 带 R 常见扩展名的文件，或 `.Rprofile` / `.Renviron` | 该文件所在目录 | 是 |
| 其它已存在文件 | 该文件所在目录 | 否 |

**会在编辑器中打开的文件扩展名**（不区分大小写）：  
`r`, `rmd`, `qmd`, `rnw`, `rhtml`, `rd`, `rproj`, `rpres`, `rhistory`, `c`, `cpp`, `cc`, `cxx`, `h`, `hpp`, `f`, `f90`，以及文件名为 `.Rprofile`、`.Renviron` 的情况。

### 从当前文件（当本次运行剪贴板不符合条件时，或 `source = "active"`）

依据 `rstudioapi::getActiveDocumentContext()`：使用 RStudio 为**当前聚焦源标签页**返回的**路径字符串**（即该文件在磁盘上的实际路径，须仍存在）。工作目录设为该路径的**父目录**（若该路径本身是目录，则设为该目录）。

| 情况 | 结果 |
|------|------|
| 当前标签有**磁盘路径**且路径仍存在 | `setwd()` + Files → 该路径的**父目录**（路径为目录时则为该目录）。 |
| **Untitled** / 无磁盘路径 | 报错；请先存盘或在剪贴板放入有效路径。 |
| RStudio 给出的路径在磁盘上已不存在 | 报错。 |

不会在编辑器里再次 `navigateToFile()` — 文件本来已打开。

## 仓库结构

| 路径 | 说明 |
|------|------|
| [`rstudio.quickwd/R/quick_wd_addins.R`](rstudio.quickwd/R/quick_wd_addins.R) | 插件实现代码 |
| [`rstudio.quickwd/inst/rstudio/addins.dcf`](rstudio.quickwd/inst/rstudio/addins.dcf) | RStudio 注册信息 |

## 许可证

见 [`rstudio.quickwd/LICENSE`](rstudio.quickwd/LICENSE)。

## 公开与分发（概要）

- **GitHub**：[anthonyhtang/rstudio-quick-working-directory](https://github.com/anthonyhtang/rstudio-quick-working-directory)；安装命令见上文 **方式 A**。克隆：`git clone https://github.com/anthonyhtang/rstudio-quick-working-directory.git`。更多分发渠道见英文 [README.md](README.md) 末尾。
