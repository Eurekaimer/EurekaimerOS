# EurekaimerOS

[中文说明](README_zh-CN.md)

A personal, host-aware NixOS configuration built around Niri, Noctalia, Home Manager, and flakes. `/etc/nixos` is the live configuration; this repository is its long-lived, frequently synchronized source copy.

![EurekaimerOS system showcase](img/system-showcase.png)

The ReGreet login screen and the Hyprlock lock screen share the same wallpaper and greeting text:

![ReGreet login screen](img/regreet-demo.png)

![Hyprlock lock screen](img/hyprlock-demo.png)

## Choose a topic

+ [Configuration architecture](docs/architecture.md)
  + Flake inputs and package flow
  + Host, system, and Home Manager boundaries
  + Safe extension points
+ [System configuration](docs/system.md)
  + Boot, network, locale, LXGW fonts, graphics, and desktop services
  + TLP power policy, storage, gaming, and virtualization
+ [Desktop and UI](docs/desktop.md)
  + Niri session, screenshots, and window rules
  + Noctalia, GTK, icons, and core user tools
+ [Applications](docs/applications.md)
  + Chrome and Throne as the declared browsers
  + Documents, media, file manager, communication, transfer, and MIME defaults
  + Links crediting each major upstream project
+ [Development environment](docs/development.md)
  + Editors, CLI tools, language toolchains, notebooks, and AI tools
+ [Software selection](docs/software-selection.md)
  + Bilingual CLI wizard, category switches, atomic replacement, and optional rebuild
+ [Personal modules](docs/personal.md)
  + Boundaries for Lexigraph, Komari Call, Nankai authentication, and docker-ass
+ [Build and maintenance](docs/operations.md)
  + Rebuild and verification commands
  + Recovery, migration, power diagnostics, and EurekaimerOS synchronization
+ [Complete documentation index](docs/index.md)
  + English and Chinese navigation for every section

## Software inventory and counts

[`software.md`](software.md) is the single complete inventory of declared packages, services, sources, purposes, and selection switches. Update the owning module and this inventory together whenever software changes.

Generate counts from the evaluated configuration rather than maintaining a second manual total:

```bash
./scripts/software-report.sh          # system, Home Manager, and total counts
./scripts/software-report.sh --list   # also print evaluated package names
```

## Repository map

```text
flake.nix
├── inputs
│   ├── nixpkgs
│   ├── nixpkgs-unstable
│   ├── home-manager
│   ├── noctalia
│   ├── komari-call
│   ├── lexigraph
│   └── hot100-assistant
└── nixosConfigurations.nixos
    ├── hosts/nixos/configuration.nix
    │   ├── hardware-configuration.nix
    │   ├── hardware-extra.nix
    │   ├── host-local.nix
    │   ├── proxy-local.nix
    │   ├── settings.nix
    │   ├── software-selection.nix
    │   ├── modules/system/system.nix
    │   ├── modules/system/personal.nix
    │   └── modules/system/software.nix
    └── home-manager.users.eurekaimer
        └── home/eurekaimer/home.nix
            ├── modules/home/desktop.nix
            ├── modules/home/core.nix
            ├── modules/home/development.nix
            ├── modules/home/applications.nix
            ├── modules/home/personal.nix
            └── modules/home/software.nix

docs/
├── index.md / index_zh-CN.md
└── <topic>.md / <topic>_zh-CN.md

scripts/
├── select-software.sh
├── generate-hardware.sh
├── software-report.sh
├── deploy-full.sh
├── deploy-owner.sh
├── deploy-preserve-hardware.sh
├── deploy-desktop.sh
├── deploy-power.sh
├── deploy-software.sh
└── deploy-common.sh
```

> The repository keeps the owner's real machine settings. `deploy-owner.sh` restores those values exactly. For another machine, `deploy-full.sh` replaces the host and proxy declarations with safe portable defaults and never guesses the GPU driver.

+ [`flake.nix`](flake.nix)
  + Pins stable and unstable package sets and builds `nixosConfigurations.nixos`.
+ [`hosts/nixos/`](hosts/nixos/)
  + Current machine's hardware, local, and proxy entry points.
+ [`modules/system/`](modules/system/)
  + Root-owned NixOS services, hardware, power, fonts, virtualization, and shared packages.
+ [`home/eurekaimer/`](home/eurekaimer/)
  + Home Manager user entry point.
+ [`modules/home/`](modules/home/)
  + Desktop, user configuration, applications, and development tools.
+ [`docs/`](docs/)
  + Bilingual explanations of this repository's own configuration.

## Rebuild

+ To reproduce the repository owner's current machine exactly, deploy the committed hardware, UUIDs, Intel extras, proxy, and preferences as-is:

```bash
./scripts/deploy-owner.sh
```

+ On different hardware, first run the bilingual hardware generator and explicitly choose Generic or Intel (the previous files are backed up):

```bash
./scripts/generate-hardware.sh
```

+ Run the bilingual software-selection wizard when you want a different package set. It atomically replaces the selection file and can optionally run the rebuild:

```bash
./scripts/select-software.sh
```

On another machine, do not choose `rebuild switch` before generating and reviewing its hardware and graphics modules. Oh My Pi and its pinned Bun runtime are mandatory and are never removed by the wizard.

+ Validate without activation:

```bash
nix build .#nixosConfigurations.nixos.config.system.build.toplevel --no-link
```

+ Build and switch the running system:

```bash
sudo nixos-rebuild switch --flake .#nixos
```

+ Deploy a fresh clone on a new machine — regenerates the hardware configuration and applies portable host/proxy defaults (proxy stays disabled until one is configured):

```bash
./scripts/deploy-full.sh
```

+ Redeploy an already-installed target while keeping that target's existing hardware and host files:

```bash
./scripts/deploy-preserve-hardware.sh
```

+ Push only one area into an existing `/etc/nixos`:

```bash
./scripts/deploy-desktop.sh   # or deploy-power.sh / deploy-software.sh
```

After a deploy script, switch with `sudo nixos-rebuild switch --flake /etc/nixos#nixos`.

## Current decisions

+ UI text prefers LXGW WenKai; the greeter, lock screen, and shell use LXGW WenKai Screen; the terminal uses Fantasque Sans Mono Nerd Font with LXGW WenKai Mono fallback.
+ Google Chrome and Throne are the browsers; Firefox and its outdated desktop rule were removed.
+ TLP owns power profiles. A small controller samples the battery every minute and adjusts the 90%/50%/20% tiers, aiming for six hours at the current full-charge capacity; idle sessions use suspend-then-hibernate.
+ Stable packages by default. Only fast-moving applications draw from the single `pkgs-unstable` instance in `flake.nix`.
+ Docker is enabled with Compose support and pulls images through the local proxy.
+ Disk UUIDs, proxy settings, and hardware configuration are machine-specific — review them before using this setup on another host.
