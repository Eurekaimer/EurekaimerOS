# EurekaimerOS

Language: English | [中文说明 (README_zh-CN.md)](README_zh-CN.md)

A personal NixOS setup centered on **Niri + Noctalia**.

![](https://cdn.jsdelivr.net/gh/Eurekaimer/MyIMGs@main/img/20260417160052566.png)

This repository is my daily-driver configuration:

- **Niri** handles the window-management workflow.
- **Noctalia** provides shell UX pieces (bar/control-center style experience).
- **Home Manager + Flakes** keep everything declarative and reproducible.

If you are looking for a minimal but practical Niri/Noctalia-oriented NixOS layout, this repo is meant to be easy to read and easy to fork.

## Reinstall First: Prefer GUI Installer + Mirrors

If you are reinstalling and your proxy software is not ready yet, I recommend a simpler path: use mirrors in the live ISO, install a basic system with the GUI installer, restore your proxy inside the installed system, and only then clone/apply the full configuration.

Current mirror setup:

- Nix binary cache mirror: `https://mirrors.ustc.edu.cn/nix-channels/store`
- Nix official fallback: `https://cache.nixos.org/`
- Flathub mirror: `https://mirror.sjtu.edu.cn/flathub/flathub.flatpakrepo`

For first install or restore, prefer:

```bash
sudo nixos-install --flake .#nixos \
  --option substituters "https://mirrors.ustc.edu.cn/nix-channels/store https://cache.nixos.org/" \
  --option download-attempts 10 \
  --option connect-timeout 30
```

If you are restoring on an already installed system, use:

```bash
sudo nixos-rebuild switch --flake . \
  --option substituters "https://mirrors.ustc.edu.cn/nix-channels/store https://cache.nixos.org/" \
  --option download-attempts 10 \
  --option connect-timeout 30
```

One subtle point: this repository does include a default local proxy module, but that does not affect the freshly installed base system until you actually run `nixos-rebuild switch --flake .`. So if your workflow is “restore proxy first, then clone/apply config”, there is no need for a separate no-proxy variant of the repo.

## What This Repo Prioritizes

- Clear layering instead of one huge config file.
- Separation between **portable modules** and **host-specific settings**.
- Fast onboarding for new machines.

---

## Entry Points

- System entry: `hosts/nixos/configuration.nix`
- Home entry: `home/eurekaimer/home.nix`

`home.nix` imports exactly four top-level modules:

1. `modules/home/desktop.nix`
2. `modules/home/core.nix`
3. `modules/home/development.nix`
4. `modules/home/applications.nix`

`modules/home/applications.nix` also owns desktop file associations through Home Manager `xdg.mimeApps`, so default open behavior stays declarative instead of being scattered across Niri or Noctalia config.

---

## Home Layout (Niri/Noctalia Focus)

```text
modules/home
├── desktop.nix
│   ├── desktop/noctalia.nix
│   ├── desktop/niri.nix
│   ├── desktop/rofi.nix       (optional, disabled by default)
│   └── desktop/waybar.nix     (optional, disabled by default)
├── core.nix
│   ├── core/shell.nix
│   ├── core/kitty.nix
│   ├── core/fastfetch.nix
│   ├── core/ui.nix
│   └── core/yazi.nix
├── development.nix
│   ├── development/neovim.nix
│   └── development/toolchain.nix
└── applications.nix
    ├── applications/knowledge.nix
    ├── applications/documents.nix
    ├── applications/media.nix
    ├── applications/web.nix
    ├── applications/transfer.nix
    ├── applications/communication.nix
    └── applications/flathub.nix
```

Current defaults:

- PDF files open with `sioyek`.
- Common image formats open with `imv`.
- These associations are managed in `modules/home/applications.nix` via `xdg.mimeApps`.

---

## System Layout

`configuration.nix` keeps only three imports:

1. `./hardware-configuration.nix`
2. `./host-local.nix`
3. `../../modules/system/system.nix`

```text
modules/system
├── system.nix
├── base.nix
├── users.nix
├── locale.nix
├── desktop.nix
├── graphics.nix
├── gaming.nix
├── packages.nix
└── graphics-intel.nix   (optional, Intel-only tuning)
```

---

## Hardware File Placement (Important)

`hardware-configuration.nix` is machine-bound and should live at:

- `hosts/<hostname>/hardware-configuration.nix`

Example in this repo:

- `hosts/nixos/hardware-configuration.nix`

When migrating to another machine:

1. Generate hardware config on that machine.
2. Put it under `hosts/<new-host>/hardware-configuration.nix`.
3. Add `hosts/<new-host>/configuration.nix` and `hosts/<new-host>/host-local.nix`.
4. Reuse `modules/system/*` and `modules/home/*` as portable layers.

---

## Rebuild

```bash
sudo nixos-rebuild switch --flake .#nixos
```

---
