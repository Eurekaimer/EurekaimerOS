# 开发环境

入口 [`modules/home/development.nix`](../modules/home/development.nix) 组合 AI 工具、Neovim 和按语言拆分的工具链。开发工具属于用户环境，不进入全局系统 path。

## 编辑器与通用 CLI

+ [`development/neovim.nix`](../modules/home/development/neovim.nix)
  + 管理 Neovim 与仓库内编辑器配置。
+ [`toolchain/editors.nix`](../modules/home/development/toolchain/editors.nix)
  + [Zed](https://zed.dev/) 使用 unstable 版本；同时安装 [GitHub Desktop](https://desktop.github.com/)。
+ [`toolchain/cli.nix`](../modules/home/development/toolchain/cli.nix)
  + 安装 `fd`、`ripgrep` 等面向代码搜索和自动化的 CLI。
+ [`toolchain/nix.nix`](../modules/home/development/toolchain/nix.nix)
  + [nil](https://github.com/oxalica/nil) 提供 Nix LSP，`nixfmt-rfc-style` 统一格式。

## 语言工具链

+ Python
  + [`python.nix`](../modules/home/development/toolchain/python.nix) 安装 [uv](https://docs.astral.sh/uv/)、Jupyter 和 Pyright。
  + 不全局固定 `UV_PYTHON`；项目通过 `.python-version` 选择版本，必要时允许 uv 下载解释器。
+ JavaScript
  + Node.js 22 与 [pnpm](https://pnpm.io/)。
+ Java
  + Maven、Gradle、JDT Language Server 和 IntelliJ IDEA OSS。
+ Go
  + Go、gopls 与 Delve。
+ C/C++
  + Bear、Clang tools、CMake 及编译调试工具。
+ LaTeX
  + TexLab 和按写作需求裁剪的 TeX Live 环境。
+ Lua、Markdown 与 Shell
  + lua-language-server、Stylua、Marksman 和 bash-language-server。

所有导入点集中在 [`development/toolchain.nix`](../modules/home/development/toolchain.nix)。新增语言时应新建独立文件并在此导入，避免一个巨大软件列表。

## AI 与代理工具

+ [`development/agents.nix`](../modules/home/development/agents.nix)
  + 从 unstable 安装 Codex 等快速更新工具。
  + 配置放在用户层，避免把个人工具链变成系统启动依赖。

上游：[OpenAI Codex](https://github.com/openai/codex)。

## R 与 Notebook

+ 统计与 Notebook 支持由 Nix wrapper 提供 R 包、R Markdown、Jupyter 和声明式 `R (Nix)` kernel。
+ 重建后使用 `jupyter kernelspec list` 检查 `r-nix` 是否存在。
