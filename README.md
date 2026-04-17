# EurekaimerOS

Language: English | [中文说明 (README_zh-CN.md)](README_zh-CN.md)

A personal NixOS setup centered on **Niri + Noctalia**.

![](https://cdn.jsdelivr.net/gh/Eurekaimer/MyIMGs@main/img/20260417160052566.png)

This repository is my daily-driver configuration:

- **Niri** handles the window-management workflow.
- **Noctalia** provides shell UX pieces (bar/control-center style experience).
- **Home Manager + Flakes** keep everything declarative and reproducible.

If you are looking for a minimal but practical Niri/Noctalia-oriented NixOS layout, this repo is meant to be easy to read and easy to fork.

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
