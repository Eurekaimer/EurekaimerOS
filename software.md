# EurekaimerOS 软件清单

> 本清单是仓库中声明的**全部软件、个人模块与服务**（系统级 + 用户级）的唯一完整清单。
> 最后更新：2026-08-24。

## 当前数量：以 Nix 求值为准

软件分类可以开关，因此静态总数很容易失真。运行以下命令可得到当前 `software-selection.nix` 真正产生的系统包、Home Manager 包和合计数量：

```bash
./scripts/software-report.sh
./scripts/software-report.sh --list  # 同时列出求值后的包名
```

这个数量统计显式 package list 中的条目；Niri、PipeWire、Docker 等由 NixOS 选项启用的服务另列在本文末尾，不会伪装成包数量。新增或删除软件时，应同时修改所属模块和本清单。

## 管理方式：`eureka.software` 抽象

所有软件包都通过两个选项统一注册，**增删软件 = 修改对应模块中的一行**：

| 层级 | 选项 | 汇入 | 声明文件 |
|---|---|---|---|
| 系统级 | `eureka.software.system` | `environment.systemPackages` | `modules/system/software.nix` |
| 用户级 | `eureka.software.home` | `home.packages` | `modules/home/software.nix` |

- 系统软件分类模块位于 `modules/system/packages/`（base-cli / network / monitoring / archive / dos），另有 graphics / gaming / power / virtualisation 模块内嵌各自软件。
- 用户软件分类模块位于 `modules/home/`（core / development / applications / desktop 及其子目录）。
- 新增分类 = 新建一个 `.nix` 文件 + 在对应聚合器 `imports` 加一行。
- 是否导入分类由 [`hosts/nixos/software-selection.nix`](hosts/nixos/software-selection.nix) 决定；交互生成见 [`scripts/select-software.sh`](scripts/select-software.sh)。仓库中提交的默认值全部为 `true`，保持原完整配置。

### 选择开关速查

| 范围 | 选择键 | 控制内容 |
|---|---|---|
| 系统包 | `system.packages.*` | baseCli / network / monitoring / archive / dos |
| 电源 | `system.power.*` | TLP / adaptivePolicy / thermal / sleep / diagnostics |
| 系统功能 | `system.mounts` / `system.gaming` | 主机磁盘、游戏环境 |
| 桌面服务 | `system.desktop.*` | printing / bluetooth |
| 虚拟化 | `system.virtualisation.*` | Docker 与完整虚拟机互相独立 |
| Home 核心 | `home.core.*` | shell、Kitty、Fastfetch、UI、Yazi、回收站策略 |
| 应用 | `home.applications.*` | knowledge / documents / media / web / fileManager / transfer / communication |
| 开发 | `home.development.*` | 编辑器、通用 CLI 与每一种语言工具链 |
| 个人模块 | `personal.*` | Lexigraph / Komari Call / campus-login / docker-ass / Hot100 Assistant |

**图例**：来源 系统=环境级 / 用户=用户级；渠道 stable=nixpkgs 25.11 正式包，unstable=nixpkgs-unstable。

## 系统级软件

| 分类 | 包 | 用途 | 渠道 | 建议 |
|---|---|---|---|---|
| 基础 CLI | `git` | 版本控制 | stable | 保留 |
| 基础 CLI | `gh` | GitHub CLI | stable | 保留 |
| 基础 CLI | `python3` | 系统 Python 解释器 | stable | 保留（脚本兜底） |
| 网络 | `wget` / `curl` | HTTP 下载/请求 | stable | 保留 |
| 网络 | `mihomo` | Clash Meta 代理内核 | stable | 保留（GUI 用 clash-verge-rev） |
| 监控 | `ncdu` / `btop` | 磁盘占用 / 资源监控 | stable | 保留 |
| 压缩 | `peazip` | 图形压缩管理器 | stable | 保留 |
| DOS | `dosbox-staging` | DOS 游戏模拟器 | stable | **可删**（小众） |
| 图形 | `libva-utils` | VA-API 硬件解码测试（vainfo） | stable | 保留 |
| 游戏 | `mangohud` | 游戏内性能 HUD | stable | 保留 |
| 游戏 | `wine` | Windows 兼容层 | stable | **可选**（体积大） |
| 游戏 | `lutris` / `protonplus` / `umu-launcher` | 游戏管理/Proton 管理/UMU | unstable | 保留 |
| 电源 | `powertop` | 电源诊断 | stable | 保留 |
| 虚拟化 | `virt-viewer` / `virtio-win` | 虚拟机图形客户端 / Windows 驱动镜像 | stable | 保留 |

## 用户级软件

### 终端与环境（core/）
| 包 | 用途 | 渠道 | 建议 |
|---|---|---|---|
| `eza` / `tree` | ls 替代 / 目录树 | stable | 保留 |
| `papirus-icon-theme` / `font-awesome` / `libnotify` | 图标主题 / 图标字体 / 通知 | stable | 保留 |
| `yazi` | 终端文件管理器 | stable | 保留 |
| `trash-cleanup`（自建脚本） | 定时清理回收站（systemd timer） | — | 保留 |
| `kitty` / `fastfetch`（programs 配置） | 终端 / 系统信息 | stable | 保留 |
| zsh + starship + zoxide（programs 配置） | shell / 提示符 / 目录跳转 | stable | 保留 |

### 编辑器与开发（development/）
| 包 | 用途 | 渠道 | 建议 |
|---|---|---|---|
| `neovim`（+24 插件） | 主力编辑器 | stable | 保留 |
| `vscode`（按选择首次写入扩展） | 编辑器；语言扩展跟随工具链，扩展可自由卸载，关闭云同步 | unstable | 保留 |
| `jetbrains.idea-oss` | Java IDE | unstable | **可选** |
| `github-desktop` | GitHub 图形客户端 | stable | **可删**（与 gh CLI 重叠） |
| `fd` / `ripgrep` / `sqlite` | 搜索/数据库 CLI | stable | 保留 |
| `bash-language-server` | Bash LSP | stable | 保留 |
| `nil` / `nixfmt-rfc-style` | Nix LSP / 格式化 | stable | 保留 |
| `lua-language-server` / `stylua` | Lua LSP / 格式化 | stable | 保留 |
| `marksman` | Markdown LSP | stable | 保留 |
| `uv` / `pyright` | Python 管理 / 类型检查 | stable | 保留；Notebook 使用项目级 uv 环境 |
| `nodejs_22` / `pnpm` | 可选通用 JavaScript 运行时 / 包管理 | stable | 保留 |
| `bun` / `omp`（强制模块） | 固定 Bun 1.3.14 + Oh My Pi 17.3.4 | unstable/npm | 强制保留，不受选择器控制 |
| `maven` / `gradle` / `jdt-language-server` / `jdk21` / `idea-oss` | Java 工具链 | stable/unstable | 保留 |
| `go` / `gopls` / `delve` / `gotools` | Go 工具链 | stable | 保留 |
| `cargo` / `clippy` / `rust-analyzer` / `rustc` / `rustfmt` | Rust 工具链 | stable | 保留 |
| `bear`/`clang-tools`/`cmake`/`cppcheck`/`gcc`/`gdb`/`gnumake`/`lldb`/`meson`/`ninja`/`pkg-config`/`valgrind` | C/C++ 全工具链 | stable | 保留 |
| `texlab` + TeX Live 组合（中英日文/xetex/latexmk） | LaTeX | stable | 保留 |

#### VSCode 扩展清单（最多 28 个）

扩展只在对应开关首次启用时写入；每个扩展有独立种子标记。此表是完整扩展来源清单，实际数量取决于当前选择。

| 依赖开关 | 扩展 |
|---|---|
| `home.development.editors`（基础，7） | Tokyo Night、Indent Rainbow、Material Icon Theme、简体中文语言包、Remote Explorer、Remote SSH、Remote SSH Edit |
| `home.development.python`（8） | Debugpy、Python、Pylance、Jupyter、Jupyter Keymap、Jupyter Renderers、Jupyter Cell Tags、Jupyter Slideshow |
| `home.development.cpp`（3） | Clangd、CMake Tools、CodeLLDB |
| `system.virtualisation.docker`（1） | Dev Containers |
| `home.development.java`（7） | Language Support for Java、Gradle for Java、Debugger for Java、Project Manager for Java、Extension Pack for Java、Test Runner for Java、Maven for Java |
| `home.development.latex`（1） | LaTeX Workshop |
| `personal.hot100Assistant`（1） | Eurekaimer Hot100 Assistant |

### 应用（applications/）
| 包 | 用途 | 渠道 | 建议 |
|---|---|---|---|
| `obsidian` / `zotero` | 知识库 / 文献管理 | stable | **zotero 可选** |
| `pdfarranger` | PDF 合并拆分 | stable | 保留 |
| `foliate` / `readest` / `sioyek` | 电子书×2 + 论文 PDF | stable | **三选一/二**（sioyek 为默认 PDF） |
| OBS Studio（wrapOBS + 3 插件） | 录屏推流 | unstable | 保留 |
| `mpv` / `ffmpeg` / `mediainfo` | 播放/转码/信息 | stable/unstable | 保留 |
| `trash-cli` / `yt-dlp` | 回收站 CLI / 视频下载 | stable | **trash-cli 可选**（与 trash-cleanup 脚本并存） |
| `google-chrome` / `throne` | 浏览器 | stable | 保留 |
| `clash-verge-rev` | Clash 图形客户端 | stable | 保留 |
| `qbittorrent` | BT 下载客户端 | stable | 保留 |
| `picgo` | 图床 | unstable | 保留 |
| `feishu` / `qq` / `wechat`（FHS 封装）/ `zoom-us` | 通讯 | unstable/stable | 保留 |
| `pcmanfm` | GUI 文件管理器（轻量 GTK3，依赖面最小；曾试 Double Commander/Qt 偏卡） | stable | 保留 |

### 个人专用模块（personal/）

这些功能不属于通用 shell、应用或开发环境；关闭后不会再接入对应模块。

| 选择键 | 软件/命令 | 实现位置 | 依赖与用途 |
|---|---|---|---|
| `personal.lexigraph` | Lexigraph | `modules/system/personal.nix` + flake input | 个人背单词项目 |
| `personal.komariCall` | Komari Call | `modules/system/personal.nix` + flake input | 个人终端聊天项目 |
| `personal.campusLogin` | `campus-login` | `modules/home/personal/campus-login.nix` | 南开校园认证；依赖 web 分类 |
| `personal.dockerAss` | `docker-ass` | `modules/home/personal/docker-ass.nix` | ANI-RSS/qBittorrent Compose；依赖 Docker，路径可由环境变量覆盖 |
| `personal.hot100Assistant` | Hot100 Assistant | `modules/home/development/toolchain/editors.nix` | 个人 VSCode 扩展；依赖 editors |

### 桌面（desktop/）
| 包 | 用途 | 渠道 | 建议 |
|---|---|---|---|
| `xwayland-satellite` / `xembed-sni-proxy` / `pamixer` / `brightnessctl` / `hyprlock` / `imv` / `pavucontrol` / `swayidle` | 会话工具/托盘代理/锁屏/图片查看/音量/空闲挂起 | stable | 保留 |
| `polkit-auth-agent`（基于 polkit-gnome 的封装） | 系统授权弹窗 | stable | 保留 |
| `grim` / `slurp` / `wf-recorder` / `wl-clipboard` | 截图/录屏/剪贴板 | stable | 保留 |
| `niri-window-shot`（自建脚本） | 窗口截图 | — | 保留 |
| `noctalia-shell`（programs 配置） | 桌面 shell（栏/启动器/控制中心） | unstable | 保留 |

## 系统服务（配置启用，非软件包）

`niri`（Wayland 合成器）、`regreet`+`greetd`+`labwc`（登录）、`fcitx5`（输入法，含 rime/mozc/中文扩展）、`pipewire`（音频）、`networkmanager`（网络）、`nix-ld`、`systemd-boot`（引导）、`swww`（壁纸）、UPower、GVfs、UDisks2、`home-manager`、`zsh`、polkit（系统授权）、`swayidle`（空闲锁屏与分级挂起，用户服务）。

以下服务受选择控制：TLP、自适应功耗控制器、thermald、睡眠策略与 powertop 分别由 `system.power.*` 控制；另有 `docker`、`libvirtd`+`qemu`（virtualMachines）、`steam`+`gamemode`（gaming）、CUPS（printing）和蓝牙（bluetooth）。


## 相关文件速查

| 目标 | 文件 |
|---|---|
| 换内核版本 | `modules/system/kernel.nix`（当前 6.12 LTS，改一行） |
| 系统软件增删 | `modules/system/packages/*.nix` |
| 用户软件增删 | `modules/home/**/*.nix` |
| 图片（重命名规范：kebab-case 小写） | `img/`（login-wallpaper / wallpaper-* / logo-bingo / system-showcase） |
