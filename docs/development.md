# Development Environment

[`modules/home/development.nix`](../modules/home/development.nix) combines AI tools, Neovim, and language-specific toolchains. Development packages stay in the user environment instead of the global system path.

## Editors and common CLI tools

+ [`development/neovim.nix`](../modules/home/development/neovim.nix) manages Neovim and its repository-owned configuration.
+ [`toolchain/editors.nix`](../modules/home/development/toolchain/editors.nix) installs unstable [Zed](https://zed.dev/) and [GitHub Desktop](https://desktop.github.com/).
+ [`toolchain/cli.nix`](../modules/home/development/toolchain/cli.nix) provides tools such as `fd` and `ripgrep`.
+ [`toolchain/nix.nix`](../modules/home/development/toolchain/nix.nix) provides the [nil](https://github.com/oxalica/nil) language server and `nixfmt-rfc-style`.

## Language toolchains

+ Python
  + [`python.nix`](../modules/home/development/toolchain/python.nix) installs [uv](https://docs.astral.sh/uv/), Jupyter, and Pyright.
  + `UV_PYTHON` is not pinned globally; projects select versions through `.python-version`, and uv may download missing interpreters.
+ JavaScript
  + Node.js 22 and [pnpm](https://pnpm.io/).
+ Java
  + Maven, Gradle, JDT Language Server, and IntelliJ IDEA OSS.
+ Go
  + Go, gopls, and Delve.
+ C/C++
  + Bear, Clang tools, CMake, and compiler/debugger tooling.
+ LaTeX
  + TexLab and a writing-focused TeX Live environment.
+ Lua, Markdown, and shell
  + lua-language-server, Stylua, Marksman, and bash-language-server.

[`development/toolchain.nix`](../modules/home/development/toolchain.nix) is the single import list. Add each new language as a separate module rather than growing one undifferentiated package list.

## AI tools

+ [`development/agents.nix`](../modules/home/development/agents.nix)
  + Installs fast-moving tools such as Claude Code and Codex from unstable.
  + Keeping them in Home Manager avoids making personal tooling a system boot dependency.

Upstream: [Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview) and [OpenAI Codex](https://github.com/openai/codex).

## R and notebooks

+ Nix wrappers provide R packages, R Markdown, Jupyter, and a declarative `R (Nix)` kernel.
+ After rebuilding, `jupyter kernelspec list` should include `r-nix`.
