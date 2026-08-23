# Software Selection and Configuration Generation

EurekaimerOS keeps its existing system, desktop, application, and language-module layout. Selection only controls whether an existing aggregator imports a category; it does not duplicate package lists or install packages imperatively with `nix-env`.

## Data flow

[`hosts/nixos/software-selection.nix`](../hosts/nixos/software-selection.nix) is a plain Nix attribute set. [`flake.nix`](../flake.nix) passes the same value to NixOS and Home Manager:

```text
software-selection.nix
├── system       → modules/system aggregators and service switches
├── home         → modules/home core/application/development aggregators
└── personal     → owner-specific projects and commands
```

Package ownership does not move. For example, every Java package remains in `modules/home/development/toolchain/java.nix`; `toolchain.nix` merely decides whether to import that module.

## Interactive selection

Run:

```bash
./scripts/select-software.sh
```

The wizard first asks for Chinese or English, then walks through system services, system packages, Home core, applications, editors and languages, and personal modules. Pressing Enter keeps the current full-configuration default.

Four dependencies are resolved before writing:

- `campus-login` enables the web group because it needs Chrome.
- `docker-ass` enables Docker.
- The adaptive controller enables TLP.
- Hot100 Assistant enables the VSCode editor group.

Oh My Pi and its pinned Bun runtime are mandatory owner requirements rather than optional selections. They remain installed from `toolchain/oh-my-pi.nix` even when the general JavaScript toolchain is disabled.

The selector does not rewrite personal Niri keybindings. If Kitty, Yazi, Obsidian, or VSCode is disabled, `Mod+Return`, `Mod+Y`, `Mod+O`, or `Mod+V` remains bound but cannot launch the missing program. This deliberately keeps package selection separate from desktop-key customization; update `modules/home/config/niri-config/config.kdl.in` when disabling those applications.

The previous file is timestamp-backed up and the replacement is atomic. At the end, choose file generation only, `nixos-rebuild build`, or `nixos-rebuild switch`.

## Non-interactive use

```bash
./scripts/select-software.sh --all --language en --rebuild none
./scripts/select-software.sh --minimal --language en --rebuild build
./scripts/select-software.sh --minimal --output /tmp/software-selection.nix
```

`--minimal` retains the Niri desktop core, a browser, PCManFM, basic CLI/networking, and Nix development tools. It is only a convenient starting point, not a second architecture or an immutable profile.

## Selection boundaries

| Selection group | Aggregator or implementation |
|---|---|
| `system.packages.*` | `modules/system/packages.nix` |
| `system.power.*` | `modules/system/power.nix`, `modules/system/power/` |
| `system.mounts/gaming` | `modules/system/system.nix` |
| `system.virtualisation.*` | `modules/system/virtualisation.nix` |
| `system.desktop.*` | `modules/system/desktop.nix` |
| `home.core.*` | `modules/home/core.nix` |
| `home.applications.*` | `modules/home/applications.nix` |
| `home.development.*` | `modules/home/development.nix`, `development/toolchain.nix` |
| `personal.*` | `modules/system/personal.nix`, `modules/home/personal.nix` |

When adding a category, keep the existing convention: create one focused module, add one selection at its aggregator, add the matching boolean to the selection file and wizard, and update [`software.md`](../software.md).

## Package-count report

```bash
./scripts/software-report.sh
./scripts/software-report.sh --list
```

The report evaluates the selected `environment.systemPackages` and `home.packages`, so counts are not copied into a second hand-maintained database. Service-style features are documented separately in [`software.md`](../software.md).

[中文版](software-selection_zh-CN.md)
