# 开发环境

入口 [`modules/home/development.nix`](../modules/home/development.nix) 组合 Neovim 和按语言拆分的工具链。开发工具属于用户环境，不进入全局系统 path。

`softwareSelection.home.development` 可以分别选择 Neovim、编辑器组、通用 CLI 和每一种语言模块。选择只发生在 `development.nix` 与 `toolchain.nix` 两个聚合器，语言模块本身仍保存完整包清单。

## 编辑器与通用 CLI

+ [`development/neovim.nix`](../modules/home/development/neovim.nix)
  + 管理 Neovim 与仓库内编辑器配置。
+ [`toolchain/editors.nix`](../modules/home/development/toolchain/editors.nix)
  + 安装 VSCode 与 [GitHub Desktop](https://desktop.github.com/)。
  + 外观与 SSH 扩展随编辑器安装；Python/Jupyter、Java、C/C++、LaTeX 和容器扩展分别跟随对应语言或 Docker 开关，Hot100 Assistant 使用独立个人开关。
  + 每个扩展只在首次启用时复制并记录独立种子标记。以后启用新语言可以补齐对应扩展；复制后仍是普通可写文件，用户卸载后不会被 Home Manager 恢复。
  + `settings.json` 只写入一次初始值，之后可直接在 VSCode 中修改。界面缩放为 `1.5`，编辑器、终端和调试控制台字号分别为 18、17、16。
  + 启动时关闭 Settings Sync，云端扩展和设置不会覆盖本地配置；`argv.json` 只保留 VSCode 支持的运行参数。
+ [`toolchain/cli.nix`](../modules/home/development/toolchain/cli.nix)
  + 安装 `fd`、`ripgrep` 等面向代码搜索和自动化的 CLI。
+ [`toolchain/nix.nix`](../modules/home/development/toolchain/nix.nix)
  + [nil](https://github.com/oxalica/nil) 提供 Nix LSP，`nixfmt-rfc-style` 统一格式。

## 语言工具链

+ Python
  + [`python.nix`](../modules/home/development/toolchain/python.nix) 安装 [uv](https://docs.astral.sh/uv/) 和 Pyright；Notebook 使用项目级 uv 环境与首次写入的 VSCode Jupyter 扩展。
  + 不全局固定 `UV_PYTHON`；项目通过 `.python-version` 选择版本，必要时允许 uv 下载解释器。
+ JavaScript
  + 可选通用工具链安装 Node.js 22 与 [pnpm](https://pnpm.io/)；强制保留的 Bun/Oh My Pi 由下方独立模块负责。
+ Java
  + Maven、Gradle、JDT Language Server 和 IntelliJ IDEA OSS。
+ Go
  + Go、gopls 与 Delve。
+ Rust
  + cargo、clippy、rust-analyzer、rustc 和 rustfmt；`RUST_SRC_PATH` 指向固定的 rustlib 源码。
+ C/C++
  + Bear、Clang tools、CMake 及编译调试工具。
+ LaTeX
  + TexLab 和按写作需求裁剪的 TeX Live 环境。
+ Lua、Markdown 与 Shell
  + lua-language-server、Stylua、Marksman 和 bash-language-server。

所有导入点集中在 [`development/toolchain.nix`](../modules/home/development/toolchain.nix)。新增语言时应新建独立文件并在此导入，避免一个巨大软件列表。

VSCode 的扩展映射集中在 `editors.nix`，但依赖读取同一份 `softwareSelection`，不复制第二份语言选择。LaTeX 专属默认设置也只在 LaTeX 开启时写入初始设置。

## Oh My Pi

[`toolchain/oh-my-pi.nix`](../modules/home/development/toolchain/oh-my-pi.nix) 是强制导入模块，在 `~/.bun` 中联合准备 Bun 1.3.14 和 `@oh-my-pi/pi-coding-agent` 17.3.4。即使关闭通用 JavaScript 工具链也不会关闭它。`~/.local/bin/omp` 明确使用用户目录中的固定 Bun，`~/.omp` 中已有的 API profile 和凭据不会被覆盖。

手动重装或更新可执行：

```bash
bun add -g @oh-my-pi/pi-coding-agent@17.3.4
omp --version
```

Oh My Pi 的 activation 会访问 npm/Bun 网络并修改 `~/.bun`；这是仓库所有者明确要求的强制例外，不会被软件选择向导关闭。
