# RStudio 剪贴板路径插件（`rstudio.clipboard.path`）

**语言：中文** · **English:** [README.md](README.md) · **源码仓库：** [github.com/anthonyhtang/RStudio-set-path](https://github.com/anthonyhtang/RStudio-set-path)

本仓库提供一个 **RStudio 插件**（安装后的 R 包名为 **`rstudio.clipboard.path`**）。它会读取**系统剪贴板**里的**目录或文件路径**；若路径存在，则设置 **Working Directory** 与 **Files** 窗格；若判断为常见 **R 相关文件**，还会在编辑器中**打开**该文件（见下文 **行为说明**）。

---

## 什么是 RStudio「插件」（Addins）？

很多人**没接触过插件系统**，这里单独说明一下：

- **插件**是 R **包**在安装后向 **RStudio 登记**的一小段可执行功能，**不是**单独的应用商店；装好包、**重启 RStudio** 后，IDE 会自动发现该包声明的插件。
- 本包只登记 **一个** 插件，名称是 **RStudio clipboard path**（见 [`addins.dcf`](rstudio.clipboard.path/inst/rstudio/addins.dcf)）。

**在 RStudio 里可以从哪里用到插件？**

| 入口 | 位置 |
|------|------|
| **浏览全部插件** | 菜单 **Tools → Browse Addins…**，列表可搜索，选中后点 **Run**。 |
| **工具栏** | 主工具栏 **Addins** 下拉（一般在 **Run** 旁边），带搜索框，通常比每次打开 Browse 更快。 |
| **命令面板** | **Tools → Show Command Palette**，用键盘输入几个字母即可筛选（见下文 **推荐用法**）。 |

---

## 不是日常编程用的「库」

不要在日常脚本里 `library()` 本包。只需**安装一次**；之后优先用 **命令面板 + 键盘** 调用，也可用 **Browse Addins**、工具栏 **Addins**，或**自定义快捷键**。

## 环境与依赖

- **RStudio**（依赖 `rstudioapi`）。
- **Windows / macOS / Linux**，剪贴板通过 CRAN 包 **`clipr`**。
- **Linux**：若无法读剪贴板，请安装 **xclip**、**xsel**（X11）或 **wl-clipboard**（Wayland）。

安装本插件时会**自动**安装 **`clipr`**。Addins 列表里若还有 **`clipr`** 自带的其它项（如 “Output to clipboard”），与 **RStudio clipboard path** 无关。

## 安装说明

插件源码在仓库的 **`rstudio.clipboard.path/`** 目录下（与 R 安装后的包名一致）。

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

**重启 RStudio**。

## 日常使用

1. 将**目录或文件**的完整路径复制到剪贴板（多行时只使用与实现一致的首行逻辑）。
2. 运行插件 — **推荐：命令面板 + 键盘**（下一节）；也可用菜单或工具栏。

支持带引号路径与 UTF-8 BOM。

## 推荐用法：命令面板 + 关键字（最快、尽量不用鼠标）

**思路：** 用快捷键打开 **命令面板（Command Palette）** → 输入几个字母筛选 → **Enter** 运行，不必每次去点 **Browse Addins**。

| 系统 | **Show Command Palette** 的默认快捷键 |
|------|----------------------------------------|
| **Windows / Linux** | **Ctrl+Shift+P** |
| **macOS** | **Cmd+Shift+P** |

也可从菜单打开：**Tools → Show Command Palette**。

打开后输入例如 **`clipboard`** 或 **`RStudio clipboard`**（英文），选中 **RStudio clipboard path** 回车即可。

**若你本机快捷键不是 Ctrl+Shift+P**（例如改成了 **Ctrl+Alt+P**）：打开 **Tools → Modify Keyboard Shortcuts**，搜索 **`Show Command Palette`**，以里面**实际显示**的组合键为准 —— 那就是打开同一命令面板的快捷键。

说明文档：[Command Palette（Posit）](https://docs.posit.co/ide/user/ide/guide/ui/command-palette.html)

## 自定义快捷键（可选）

本包**不自带**默认快捷键。若要绑定成一键运行：

1. 菜单 **Tools → Modify Keyboard Shortcuts**
2. 搜索 **`RStudio clipboard path`**（或在 **Addins** 相关区域找到同名项）
3. 点击该行的 **快捷键** 格子，按下**当前未被占用**的组合键（例如 **Ctrl+Alt+Y**）

参考：[Custom shortcuts（Posit）](https://docs.posit.co/ide/user/ide/guide/productivity/custom-shortcuts.html)

## 其它运行方式

| 方式 | 操作 |
|------|------|
| **工具栏 Addins** | 主工具栏 **Addins** → 搜索 **RStudio clipboard path** → 运行。 |
| **Browse Addins** | **Tools → Browse Addins…** → 搜索 **clipboard** → **Run**。 |
| **R 控制台** | `rstudio.clipboard.path::sync_path_from_clipboard()`（与插件等价）。 |

### 按了命令面板快捷键还是找不到插件？

- 安装或更新后**先完全退出并重启一次 RStudio**，插件列表才会刷新。
- 能搜到什么取决于 **RStudio 版本**；可试英文关键词：**`addin`**、**`clipboard`**、**`RStudio clipboard`**。
- 最稳妥：**Tools → Browse Addins…** → 搜索 **clipboard** 或 **RStudio clipboard path** → **Run**。
- 或：**Tools → Modify Keyboard Shortcuts** → 搜索 **RStudio clipboard path** → 绑定快捷键。

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
