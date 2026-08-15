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
+ `system.stateVersion` and `home.stateVersion` are compatibility baselines; do not change them merely because nixpkgs was upgraded.
+ If `mem_sleep_default=deep` causes resume failures, remove it from [`power.nix`](../modules/system/power.nix) and rebuild.

## EurekaimerOS synchronization

`/etc/nixos` is the live configuration. `/home/eurekaimer/Documents/GitHub/EurekaimerOS` is the long-lived repository, hosted at <https://github.com/Eurekaimer/EurekaimerOS>. Sync only after successful verification, preserving the target repository's `.git`, LICENSE, and repository-only files; do not use deletion-based mirroring.
