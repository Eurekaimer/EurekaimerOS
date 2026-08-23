# Build and Maintenance

## Normal verification

+ Build without switching the running system:

```bash
nix build .#nixosConfigurations.nixos.config.system.build.toplevel --no-link
```

+ Build and activate:

```bash
sudo nixos-rebuild switch --flake .#nixos
```

+ A complete toplevel build and live switch verified the adaptive controller, managed Noctalia/swayidle services, resume swap, and battery-aware sleep configuration.
+ Validate the flake and its source hygiene: `nix flake check`.

## Deployment

### Recommended flow after cloning

```bash
./scripts/generate-hardware.sh  # generate only this machine's hardware module
./scripts/select-software.sh    # bilingual selection and optional rebuild
./scripts/software-report.sh    # evaluate current package counts
```

`generate-hardware.sh` defaults to `hosts/nixos/hardware-configuration.nix`, validates output, and backs up the previous file. `--output PATH` selects another destination, while `--sudo`/`--no-sudo` controls generator privileges. It never guesses or overwrites GPU extras, data disks, resume swap, proxy, or USB quirks.

`select-software.sh` atomically generates `hosts/nixos/software-selection.nix`. See [Software selection](software-selection.md) for arguments and module mappings.

The existing `deploy-*.sh` tools stage files, atomically replace their target, and keep a timestamped backup:

+ `./scripts/deploy-full.sh` — first deployment on a new machine. Regenerates `hardware-configuration.nix` and swaps `host-local.nix`, `proxy-local.nix`, and `hardware-extra.nix` for the portable defaults (`host-generic.nix`, `proxy-disabled.nix`, `hardware-extra-generic.nix`); when an Intel iGPU is detected it restores the Intel graphics module.
+ `./scripts/deploy-preserve-hardware.sh` — redeploys this machine keeping the target's hardware and host files.
+ `./scripts/deploy-desktop.sh` / `deploy-power.sh` / `deploy-software.sh` — push a single area into an existing `/etc/nixos`; replaced items are backed up to a timestamped `.partial-backup-*` directory.
+ `EUREKAIMEROS_TARGET=/path` overrides the deployment target (default `/etc/nixos`).

After any deploy script, activate with `sudo nixos-rebuild switch --flake /etc/nixos#nixos`.

### Fresh-clone checklist

1. Install NixOS and create the user `eurekaimer` — `users.nix` and `home.nix` hard-code this username.
2. Clone the repository, run `./scripts/select-software.sh`, and choose file generation only at the final prompt.
3. Run `./scripts/deploy-full.sh`; it copies the selection into `/etc/nixos` and regenerates hardware in the staged target.
4. Review machine-specific values: resume swap and USB quirks in `host-local.nix`, plus NTFS UUIDs in `mounts.nix`.
5. The proxy starts disabled; after configuring 127.0.0.1:7897, enable `proxy-local.nix` and the Docker proxy.
6. Run `sudo nixos-rebuild switch --flake /etc/nixos#nixos`.

When building directly from the clone instead of deploying to `/etc/nixos`, run `generate-hardware.sh` first, review host values, and then let the selection wizard rebuild the clone.

## Where to edit

+ Fonts, locale, and input method: [`modules/system/locale.nix`](../modules/system/locale.nix)
+ Login and system desktop services: [`modules/system/desktop.nix`](../modules/system/desktop.nix)
+ GTK fonts and icons: [`modules/home/core/ui.nix`](../modules/home/core/ui.nix)
+ Niri: [`modules/home/config/niri-config/config.kdl.in`](../modules/home/config/niri-config/config.kdl.in)
+ Noctalia: [`modules/home/config/noctalia-config/settings.json.in`](../modules/home/config/noctalia-config/settings.json.in)
+ Applications: [`modules/home/applications/`](../modules/home/applications/)
+ Power entry: [`modules/system/power.nix`](../modules/system/power.nix); focused policies: [`modules/system/power/`](../modules/system/power/)

## Power diagnostics

+ Inspect the controller: `cat /run/power-policy/status.json`.
+ Inspect TLP: `sudo tlp-stat -s -p -b`.
+ Inspect managed desktop services: `systemctl --user status swayidle noctalia-shell`.
+ Capture a sample: `sudo powertop --time=10 --csv=/tmp/powertop.csv`; check application wakeups, display brightness, proxy clients, and browser tabs before adding kernel tuning.
+ This battery currently holds about 86.5% of design capacity. Scheduling can reduce consumption, but cannot recover that physical loss.

## Recovery and migration

+ In a live ISO or first boot, restore a working binary cache and network before applying the complete flake.
+ On new hardware, regenerate `hardware-configuration.nix` and verify disk UUIDs, the Intel graphics module, proxy settings, and username.
+ Deploy scripts only replace portable files; machine-specific values — the resume swap UUID in `host-local.nix`, the NTFS UUIDs in `mounts.nix`, and the username in `users.nix`/`home.nix` — are never touched and must be reviewed on new hardware.
+ `system.stateVersion` and `home.stateVersion` are compatibility baselines; do not change them merely because nixpkgs was upgraded.
+ If `mem_sleep_default=deep` causes resume failures, remove it from [`power/sleep.nix`](../modules/system/power/sleep.nix) and rebuild.

## EurekaimerOS synchronization

`/etc/nixos` is the live configuration. `/home/eurekaimer/Documents/GitHub/EurekaimerOS` is the long-lived repository copy. Sync only after successful verification, preserving the target repository's `.git`, LICENSE, and repository-only files; do not use deletion-based mirroring.

Deployment copies from the repository to `/etc/nixos`; synchronization copies back from `/etc/nixos` to the repository. The two directions complement each other.
