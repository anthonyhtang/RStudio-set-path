# RStudio 剪贴板路径插件（`rstudio.clipboard.path`）

本仓库提供 **RStudio 插件**：在 **Addins** 菜单里选择（或设快捷键），会**读取系统剪贴板里的路径**；若该路径在磁盘上存在，则更新 **Working Directory** 与 **Files** 窗格；若像是常见 **R 相关文件**，则在编辑器中**打开**（详见 [README.md](README.md) 中的扩展名列表）。

**英文主文档：** [README.md](README.md)

## 不是给脚本里 `library()` 用的库

日常写代码**不需要**、也不应该把它当成普通 R 包来 `library()`。RStudio 插件通过**一次性安装**一个小包交付（RStudio 靠这样才能加载插件）；之后只要在菜单或快捷键里**点插件**即可。

## 环境与平台

- **RStudio**（`rstudioapi`）。
- **Windows / macOS / Linux**，剪贴板依赖 **`clipr`**。
- **Linux**：若读不到剪贴板，请安装 **xclip**、**xsel** 或 **wl-clipboard**。

**为什么装了 `clipr`？** 本插件用 **`clipr`** 跨平台读剪贴板，安装本包时会**自动**装上，一般不必单独再装。Addins 列表里若还看到 `clipr` 自带的其它项（如 “Output to clipboard”），与本插件无关，可忽略。

## 一次性安装

本地克隆后：

```r
install.packages("你的路径/RStudio-set-path/tcwd", repos = NULL, type = "source")
```

推到 GitHub 之后可用（把 `OWNER/REPO` 换成你的仓库）：

```r
remotes::install_github("OWNER/REPO", subdir = "tcwd")
```

安装后的 R 包名为 **`rstudio.clipboard.path`**。若曾装过旧名 **`clippath`**，执行一次 `remove.packages("clippath")`。安装后**重启 RStudio**。

公开仓库步骤与其它发布渠道（CRAN、R-universe、社区等）见 [README.md](README.md) 末尾 **Publishing the project**；概要：**GitHub** 托管源码 → 他人用 `remotes::install_github(..., subdir = "tcwd")`；若要 `install.packages()` 全网友好安装，可再考虑 **CRAN** 或 **R-universe**。

## 日常使用

1. 复制**目录或文件**的完整路径到剪贴板。
2. 用下面任一方式运行插件。

支持带引号路径与 UTF-8 BOM。详细行为表见 [README.md](README.md)。

### 更快唤起（没法挂到「文件」顶层菜单）

RStudio **不允许** R 插件出现在 **File / Edit** 那一层系统菜单里，这是 IDE 的限制。本包**不提供预设快捷键**，需要的话请在 RStudio 里自己绑定。

| 方式 | 操作 |
|------|------|
| **工具栏 Addins** | 主工具栏 **Addins** 下拉（运行按钮附近）带**搜索框**，不必每次 **Browse Addins**。 |
| **快捷键** | **Tools → Modify Keyboard Shortcuts** → 搜索 **RStudio clipboard path** → 在快捷键栏里按下**任意**未占用的组合键。 |
