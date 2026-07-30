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

+ The complete NixOS toplevel was built after the font, browser, and power changes. The result contains no Firefox desktop file, and its generated TLP configuration contains the 5%–50% battery CPU range and battery-mode Bluetooth disable rule.

## Where to edit

+ Fonts, locale, and input method: [`modules/system/locale.nix`](../modules/system/locale.nix)
+ Login and system desktop services: [`modules/system/desktop.nix`](../modules/system/desktop.nix)
+ GTK fonts and icons: [`modules/home/core/ui.nix`](../modules/home/core/ui.nix)
+ Niri: [`modules/home/config/niri-config/config.kdl`](../modules/home/config/niri-config/config.kdl)
+ Noctalia: [`modules/home/config/noctalia-config/settings.json`](../modules/home/config/noctalia-config/settings.json)
+ Applications: [`modules/home/applications/`](../modules/home/applications/)
+ Power: [`modules/system/power.nix`](../modules/system/power.nix)

## Power diagnostics

+ Inspect TLP: `sudo tlp-stat -s -p -b`.
+ Capture a sample: `sudo powertop --time=10 --csv=/tmp/powertop.csv`.
+ Inspect application wakeups, display brightness, proxy clients, and browser tabs before adding aggressive kernel parameters.
+ This machine reports full-charge capacity at about 85% of design capacity. Scheduling changes cannot recover that physical capacity loss.

## Recovery and migration

+ In a live ISO or first boot, restore a working binary cache and network before applying the complete flake.
+ On new hardware, regenerate `hardware-configuration.nix` and verify disk UUIDs, the Intel graphics module, proxy settings, and username.
+ `system.stateVersion` and `home.stateVersion` are compatibility baselines; do not change them merely because nixpkgs was upgraded.
+ If `mem_sleep_default=deep` causes resume failures, remove it from [`power.nix`](../modules/system/power.nix) and rebuild.

## EurekaimerOS synchronization

`/etc/nixos` is the live configuration. `/home/eurekaimer/Documents/GitHub/EurekaimerOS` is the long-lived repository. Sync only after successful verification, preserving the target repository's `.git`, LICENSE, and repository-only files; do not use deletion-based mirroring.
