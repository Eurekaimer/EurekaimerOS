# EurekaimerOS

Language: English | [中文说明 (README_zh-CN.md)](README_zh-CN.md)

A personal NixOS setup centered on **Niri + Noctalia**.

![](https://cdn.jsdelivr.net/gh/Eurekaimer/MyIMGs@main/img/20260417160052566.png)

This repository is my daily-driver configuration:

- **Niri** handles the window-management workflow.
- **Noctalia** provides shell UX pieces (bar/control-center style experience).
- **Home Manager + Flakes** keep everything declarative and reproducible.

If you are looking for a minimal but practical Niri/Noctalia-oriented NixOS layout, this repo is meant to be easy to read and easy to fork.

## Reinstall First: Add Mirrors, Then Install

For a reinstall, keep the early path simple: add Nix mirrors to `/etc/nix/nix.conf` first, then install. This avoids making the installer depend on a proxy client, a browser login, or a full desktop session before the base system exists.

Current mirror setup:

- Nix binary cache mirror: `https://mirrors.ustc.edu.cn/nix-channels/store`
- Nix official fallback: `https://cache.nixos.org/`

In the live ISO, edit `/etc/nix/nix.conf`:

```bash
sudo cp /etc/nix/nix.conf /etc/nix/nix.conf.bak
sudo nano /etc/nix/nix.conf
```

Add or replace the mirror line:

```conf
substituters = https://mirrors.ustc.edu.cn/nix-channels/store https://cache.nixos.org/
```

Then restart the daemon and install with the GUI installer or your normal NixOS install flow:

```bash
sudo systemctl restart nix-daemon
```

After the first boot, repeat the same `/etc/nix/nix.conf` mirror edit in the installed system before pulling this repository or running the final rebuild:

```bash
sudo nixos-rebuild switch --flake .#nixos
```

For the first network recovery step, prefer `Throne` (`pkgs.throne`) or the headless `mihomo` core. They are less likely to fail because of WebView or GPU-rendering issues during the early restore stage. `clash-verge-rev` is still included, but it is better treated as a full desktop proxy UI after WebView rendering is known to work.

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
    ├── applications/web.nix            (browsers, Clash Verge, Throne)
    ├── applications/transfer.nix
    └── applications/communication.nix
```

Current defaults:

- PDF files open with `sioyek`.
- Common image formats open with `imv`.
- `mihomo` is available as a system-level proxy core.
- `Throne` is the preferred early proxy GUI; `clash-verge-rev` remains available for the full desktop session.
- These associations are managed in `modules/home/applications.nix` via `xdg.mimeApps`.

---

## R, R Markdown, and Notebook Workflow

R is provided through wrapped packages in `modules/home/development/toolchain.nix` instead of installing packages manually from inside RStudio.

The current wrapper includes common coursework and plotting packages:

- R Markdown/reporting: `rmarkdown`, `knitr`, `tinytex`
- VSCode/Jupyter support: `IRkernel`, `languageserver`
- Tidyverse/plots: `tidyverse`, `ggplot2`
- Statistics/course packages: `boot`, `bootstrap`, `MASS`, `Matrix`, `survival`, `car`, `lmtest`, `sandwich`, `lme4`
- Map tests: `maps`, `mapdata`

`httpgd` is intentionally not included for now because the current nixpkgs revision marks `r-httpgd` as broken. Inline plots in R notebooks should still work through the R Jupyter kernel.

After rebuilding, register the R kernel once:

```bash
Rscript -e 'IRkernel::installspec(user = TRUE)'
```

For a quick plotting test:

```bash
Rscript /home/eurekaimer/Documents/Rcode/r_plot_test_china_charts.R
```

For notebook-style inline feedback, open this file in VSCode and select the `R` kernel:

```text
/home/eurekaimer/Documents/Rcode/r_china_charts_notebook.ipynb
```

Required VSCode extensions:

- `REditorSupport.r`
- `ms-toolsai.jupyter`

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
├── packages.nix        (common CLI tools, Firefox, mihomo)
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
