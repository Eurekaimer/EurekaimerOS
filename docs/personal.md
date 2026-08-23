# Personal Modules

Personal modules contain projects, campus behavior, and directory conventions specific to the repository owner. They remain inside the existing `modules/system` and `modules/home` classifications, but no longer leak into generic application and shell modules.

## System entry point

[`modules/system/personal.nix`](../modules/system/personal.nix) conditionally imports the Lexigraph and Komari Call NixOS modules from the pinned flake inputs.

Inside Komari Call, `/login`, `/login deepseek`, and `/login opencode-go` validate and store credentials in the system keyring. Select and inspect the OpenCode Go subscription with:

```bash
komari-call config --provider opencode-go --model deepseek-v4-flash
komari-call models --provider opencode-go
```

Lexigraph behavior stays owned by its external flake module; this repository only chooses whether to connect it.

## Home Manager entry point

[`modules/home/personal.nix`](../modules/home/personal.nix) aggregates:

- [`personal/campus-login.nix`](../modules/home/personal/campus-login.nix): opens the Nankai authentication page without proxies and with an isolated Chrome profile. It requires the web application group.
- [`personal/docker-ass.nix`](../modules/home/personal/docker-ass.nix): controls the owner's ANI-RSS/qBittorrent Compose project. `DOCKER_ASS_PROJECT_DIRECTORY` overrides its historical default path. It requires Docker.
- `personal.hot100Assistant`: selects the owner's Hot100 Assistant extension inside `development/toolchain/editors.nix` and requires the VSCode editor group.

The wizard resolves these dependencies, while Home Manager assertions protect manually edited selections. Oh My Pi is mandatory rather than a personal switch and stays coupled to its pinned Bun runtime in `development/toolchain/oh-my-pi.nix`. New owner-specific commands should stay under `modules/home/personal/`; campus URLs and private directory conventions should not return to generic `applications`, `core`, or `development` modules.

[中文版](personal_zh-CN.md)
