# 开发环境

入口 [`modules/home/development.nix`](../modules/home/development.nix) 组合 Neovim 和按语言拆分的工具链。开发工具属于用户环境，不进入全局系统 path。

## 编辑器与通用 CLI

+ [`development/neovim.nix`](../modules/home/development/neovim.nix)
  + 管理 Neovim 与仓库内编辑器配置。
+ [`toolchain/editors.nix`](../modules/home/development/toolchain/editors.nix)
  + 安装 VSCode 与 [GitHub Desktop](https://desktop.github.com/)。
  + 语言、SSH、容器、Jupyter、LaTeX 和外观扩展只会在首次激活时复制到 `~/.vscode/extensions`。
  + 复制后的扩展是普通可写用户文件；VSCode 可以自由安装、更新、禁用和卸载，Home Manager 后续不会把已卸载扩展恢复回来。
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
  + Node.js 22、[pnpm](https://pnpm.io/) 与 Bun。
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

## Oh My Pi

[`toolchain/javascript.nix`](../modules/home/development/toolchain/javascript.nix) 会在 `~/.bun` 中准备 Bun 1.3.14 和 `@oh-my-pi/pi-coding-agent` 17.3.4。`~/.local/bin/omp` 启动器明确使用用户目录中的 Bun，避免 `PATH` 前面的旧版 Nix Bun。`~/.omp` 中已有的 API profile 和凭据不会被覆盖。

手动重装或更新可执行：

```bash
bun add -g @oh-my-pi/pi-coding-agent@17.3.4
omp --version
```
