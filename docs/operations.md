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

All [`scripts/`](../scripts/) tools stage the new files, atomically replace the target, and keep a timestamped backup:

+ `./scripts/deploy-full.sh` — first deployment on a new machine. Regenerates `hardware-configuration.nix` and swaps `host-local.nix`, `proxy-local.nix`, and `hardware-extra.nix` for the portable defaults (`host-generic.nix`, `proxy-disabled.nix`, `hardware-extra-generic.nix`); when an Intel iGPU is detected it restores the Intel graphics module.
+ `./scripts/deploy-preserve-hardware.sh` — redeploys this machine keeping the target's hardware and host files.
+ `./scripts/deploy-desktop.sh` / `deploy-power.sh` / `deploy-software.sh` — push a single area into an existing `/etc/nixos`; replaced items are backed up to a timestamped `.partial-backup-*` directory.
+ `EUREKAIMEROS_TARGET=/path` overrides the deployment target (default `/etc/nixos`).

After any deploy script, activate with `sudo nixos-rebuild switch --flake /etc/nixos#nixos`.

### Fresh-clone checklist

1. Install NixOS and create the user `eurekaimer` — `users.nix` and `home.nix` hard-code this username.
2. Clone the repository and run `./scripts/deploy-full.sh`.
3. Review the machine-specific values by hand: the resume swap UUID in `power.nix`, the NTFS UUIDs in `mounts.nix`, and the USB quirks in `host-local.nix`.
4. The proxy starts disabled (`proxy-disabled.nix`); once a proxy on 127.0.0.1:7897 is available, enable `proxy-local.nix` and the Docker proxy.
5. Switch with `sudo nixos-rebuild switch --flake /etc/nixos#nixos`. Binary caches (USTC, Tsinghua, official) are preconfigured in `base.nix`.

## Where to edit

+ Fonts, locale, and input method: [`modules/system/locale.nix`](../modules/system/locale.nix)
+ Login and system desktop services: [`modules/system/desktop.nix`](../modules/system/desktop.nix)
+ GTK fonts and icons: [`modules/home/core/ui.nix`](../modules/home/core/ui.nix)
+ Niri: [`modules/home/config/niri-config/config.kdl.in`](../modules/home/config/niri-config/config.kdl.in)
+ Noctalia: [`modules/home/config/noctalia-config/settings.json.in`](../modules/home/config/noctalia-config/settings.json.in)
+ Applications: [`modules/home/applications/`](../modules/home/applications/)
+ Power: [`modules/system/power.nix`](../modules/system/power.nix)

## Power diagnostics

+ Inspect the controller: `cat /run/power-policy/status.json`.
+ Inspect TLP: `sudo tlp-stat -s -p -b`.
+ Inspect managed desktop services: `systemctl --user status swayidle noctalia-shell`.
+ Capture a sample: `sudo powertop --time=10 --csv=/tmp/powertop.csv`; check application wakeups, display brightness, proxy clients, and browser tabs before adding kernel tuning.
+ This battery currently holds about 86.5% of design capacity. Scheduling can reduce consumption, but cannot recover that physical loss.

## Recovery and migration

+ In a live ISO or first boot, restore a working binary cache and network before applying the complete flake.
+ On new hardware, regenerate `hardware-configuration.nix` and verify disk UUIDs, the Intel graphics module, proxy settings, and username.
+ Deploy scripts only replace portable files; machine-specific values — the resume swap UUID in `power.nix`, the NTFS UUIDs in `mounts.nix`, the username in `users.nix`/`home.nix` — are never touched and must be reviewed on new hardware.
+ `system.stateVersion` and `home.stateVersion` are compatibility baselines; do not change them merely because nixpkgs was upgraded.
+ If `mem_sleep_default=deep` causes resume failures, remove it from [`power.nix`](../modules/system/power.nix) and rebuild.

## EurekaimerOS synchronization

`/etc/nixos` is the live configuration. `/home/eurekaimer/Documents/GitHub/EurekaimerOS` is the long-lived repository copy. Sync only after successful verification, preserving the target repository's `.git`, LICENSE, and repository-only files; do not use deletion-based mirroring.

Deployment copies from the repository to `/etc/nixos`; synchronization copies back from `/etc/nixos` to the repository. The two directions complement each other.
