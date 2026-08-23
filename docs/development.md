# Development Environment

[`modules/home/development.nix`](../modules/home/development.nix) combines Neovim and language-specific toolchains. Development packages stay in the user environment instead of the global system path.

`softwareSelection.home.development` independently selects Neovim, the editor group, common CLI, and each language module. Selection happens only at the `development.nix` and `toolchain.nix` aggregators; language modules retain their complete package ownership.

## Editors and common CLI tools

+ [`development/neovim.nix`](../modules/home/development/neovim.nix) manages Neovim and its repository-owned configuration.
+ [`toolchain/editors.nix`](../modules/home/development/toolchain/editors.nix) installs VSCode and [GitHub Desktop](https://desktop.github.com/).
  + UI and SSH extensions follow the editor; Python/Jupyter, Java, C/C++, LaTeX, and container extensions follow their language or Docker selections. Hot100 Assistant has its own personal switch.
  + Each extension gets an independent first-enable seed marker. Enabling a language later adds its extensions, while a user-uninstalled seeded extension stays removed.
  + `settings.json` is seeded once and remains writable. The UI zoom is `1.5`, with editor, terminal, and debug-console font sizes of 18, 17, and 16.
  + Settings Sync is disabled at launch, so cloud extensions and settings cannot overwrite the local profile. `argv.json` contains only supported runtime arguments.
+ [`toolchain/cli.nix`](../modules/home/development/toolchain/cli.nix) provides tools such as `fd` and `ripgrep`.
+ [`toolchain/nix.nix`](../modules/home/development/toolchain/nix.nix) provides the [nil](https://github.com/oxalica/nil) language server and `nixfmt-rfc-style`.

## Language toolchains

+ Python
  + [`python.nix`](../modules/home/development/toolchain/python.nix) installs [uv](https://docs.astral.sh/uv/) and Pyright; notebooks use project-local uv environments and the initially seeded VSCode Jupyter extensions.
  + `UV_PYTHON` is not pinned globally; projects select versions through `.python-version`, and uv may download missing interpreters.
+ JavaScript
  + The optional general toolchain provides Node.js 22 and [pnpm](https://pnpm.io/); mandatory Bun/Oh My Pi ownership is described below.
+ Java
  + Maven, Gradle, JDT Language Server, and IntelliJ IDEA OSS.
+ Go
  + Go, gopls, and Delve.
+ Rust
  + cargo, clippy, rust-analyzer, rustc, and rustfmt; `RUST_SRC_PATH` points at the pinned rustlib sources.
+ C/C++
  + Bear, Clang tools, CMake, and compiler/debugger tooling.
+ LaTeX
  + TexLab and a writing-focused TeX Live environment.
+ Lua, Markdown, and shell
  + lua-language-server, Stylua, Marksman, and bash-language-server.

[`development/toolchain.nix`](../modules/home/development/toolchain.nix) is the single import list. Add each new language as a separate module rather than growing one undifferentiated package list.

`editors.nix` keeps the extension mapping in one reviewable place but derives every language group from the same `softwareSelection`; no second language-selection database is introduced. LaTeX-only default settings are also conditional.

## Oh My Pi

[`toolchain/oh-my-pi.nix`](../modules/home/development/toolchain/oh-my-pi.nix) is imported unconditionally and jointly bootstraps Bun 1.3.14 plus `@oh-my-pi/pi-coding-agent` 17.3.4 in `~/.bun`. Disabling the general JavaScript toolchain does not remove it. Existing API profiles and credentials under `~/.omp` are preserved.

To reinstall or update the mutable package manually:

```bash
bun add -g @oh-my-pi/pi-coding-agent@17.3.4
omp --version
```

The activation accesses the Bun/npm network and mutates `~/.bun`; this is an explicit mandatory owner requirement and the selection wizard does not disable it.
