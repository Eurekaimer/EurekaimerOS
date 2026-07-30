# System Configuration

[`modules/system/system.nix`](../modules/system/system.nix) is the system-layer entry point.

## Base

+ [`base.nix`](../modules/system/base.nix)
  + Enables flakes, `nix-command`, unfree packages, `nix-ld`, NetworkManager, and systemd-boot.
  + Uses USTC, Tsinghua, and official caches; optimizes the store and removes generations older than seven days weekly.
+ [`users.nix`](../modules/system/users.nix) defines the daily user, shell, administration, and virtualization groups.
+ [`packages.nix`](../modules/system/packages.nix) groups shared CLI, networking, monitoring, archive, and DOS tools. Browsers are user-level packages.

## Locale and fonts

+ [`locale.nix`](../modules/system/locale.nix)
  + Uses `zh_CN.UTF-8`, retains `en_US.UTF-8`, and configures [Fcitx 5](https://fcitx-im.org/wiki/Fcitx_5) with Rime/Mozc and GTK/Qt frontends.
  + Installs LXGW WenKai Screen plus Noto CJK, WenQuanYi, Sarasa, JetBrains Mono Nerd Font, and Noto Color Emoji.
  + Makes LXGW the first sans-serif, serif, Noto Sans, and common Chinese Windows-font replacement for both Chinese and Latin UI text.
  + Kitty uses LXGW WenKai Screen; JetBrains Mono/Sarasa Mono remain available as code and glyph fallbacks.
+ [`desktop.nix`](../modules/system/desktop.nix) explicitly applies LXGW to ReGreet.

## Desktop services and graphics

+ [`desktop.nix`](../modules/system/desktop.nix)
  + Enables Niri, greetd/ReGreet through Labwc, GVfs, UDisks2, printing, PipeWire, Bluetooth, and UPower.
  + Plasma 6 supplies KDE applications and components, while Niri remains the daily session.
+ [`graphics.nix`](../modules/system/graphics.nix) enables the graphics stack and installs VAAPI diagnostics.
+ [`graphics-intel.nix`](../modules/system/graphics-intel.nix) adds Intel media/VAAPI drivers only for this host.

## Power

+ [`power.nix`](../modules/system/power.nix)
  + Uses [TLP](https://linrunner.de/tlp/) as the sole platform-profile owner and force-disables power-profiles-daemon.
  + Battery mode uses powersave, `power` EPP, low-power platform profile, no Turbo/dynamic boost, and a 5%–50% CPU range.
  + Enables PCIe ASPM, runtime PM, Wi-Fi/audio power saving, and USB autosuspend on battery.
  + Leaves Bluetooth available at boot and across AC/battery transitions so desktop controls can toggle it normally.
  + Prefers deep suspend and installs Powertop/s-tui for diagnostics.

A live sample confirmed TLP was active in battery/low-power mode. Active Chrome renderers, Clash Verge, display composition, and the diagnostic workload were the main wakeup sources; additional kernel tuning would not address those application workloads.

## Storage, gaming, and virtualization

+ [`mounts.nix`](../modules/system/mounts.nix) automounts two host-specific NTFS3 data volumes by UUID and unmounts them after five idle minutes. Verify UUIDs and the `force` option before reuse.
+ [`gaming.nix`](../modules/system/gaming.nix) configures [Steam](https://store.steampowered.com/about/), [GameMode](https://github.com/FeralInteractive/gamemode), MangoHud, and Wine, including the Niri/Xwayland Steam CEF workaround.
+ [`virtualisation.nix`](../modules/system/virtualisation.nix) enables Docker/Compose with the host image-pull proxy, plus [libvirt](https://libvirt.org/), [virt-manager](https://virt-manager.org/), QEMU, swtpm, SPICE USB redirection, and Windows virtio drivers; unused `virtchd` is disabled.

## Host-specific files

+ `hardware-configuration.nix`: regenerate on another machine.
+ `host-local.nix`: current-machine values.
+ `proxy-local.nix`: daily network proxy entry.

[中文版](system_zh-CN.md)
