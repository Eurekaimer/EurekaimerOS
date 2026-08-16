# System Configuration

[`modules/system/system.nix`](../modules/system/system.nix) is the system-layer entry point.

## Base

+ [`base.nix`](../modules/system/base.nix)
  + Enables flakes, `nix-command`, unfree packages, `nix-ld`, NetworkManager, and systemd-boot; sets `time.timeZone` to `Asia/Shanghai` and keeps `system.stateVersion` at NixOS 25.11.
  + Uses USTC, Tsinghua, and official caches; optimizes the store and prunes profile generations on every rebuild — once the count reaches 10 the oldest are deleted and the store is GC'd immediately (no weekly timer).
+ [`users.nix`](../modules/system/users.nix) defines the daily user, shell, administration, and virtualization groups.
+ [`packages.nix`](../modules/system/packages.nix) groups shared CLI, networking, monitoring, archive, and DOS tools. Browsers are user-level packages.
+ [`kernel.nix`](../modules/system/kernel.nix) pins Linux 6.12 LTS; changing the kernel is a one-line edit in that file.

## Locale and fonts

+ [`locale.nix`](../modules/system/locale.nix)
  + Uses `zh_CN.UTF-8`, retains `en_US.UTF-8`, and configures [Fcitx 5](https://fcitx-im.org/wiki/Fcitx_5) with Rime/Mozc and GTK/Qt frontends.
  + Installs LXGW WenKai (regular, Screen, and Mono families), Noto CJK, WenQuanYi, Sarasa, Fantasque Sans Mono Nerd Font, and Noto Color Emoji.
  + LXGW WenKai is the first sans-serif and serif; the Noto Sans and common Chinese Windows-font aliases (SimSun, Microsoft YaHei, DengXian, SimHei, KaiTi, FangSong, …) prefer LXGW WenKai Screen.
  + The monospace order is Fantasque Sans Mono Nerd Font, LXGW WenKai Mono, then Noto Sans Mono CJK SC; Kitty uses Fantasque Sans Mono Nerd Font.
+ [`desktop.nix`](../modules/system/desktop.nix) explicitly applies LXGW to ReGreet.

## Desktop services

+ [`desktop.nix`](../modules/system/desktop.nix)
  + Enables Niri, greetd/ReGreet through Labwc, GVfs, UDisks2, printing, PipeWire, Bluetooth, and UPower.
  + No KDE/Plasma components are installed; Niri is the only desktop session.
  + PipeWire serves ALSA, 32-bit ALSA, and PulseAudio clients.
  + UDisks NTFS defaults never force-mount dirty volumes; fix them with Windows `chkdsk` first.

## Graphics

+ [`graphics.nix`](../modules/system/graphics.nix) enables the graphics stack and installs VAAPI diagnostics.
+ [`hardware-extra.nix`](../hosts/nixos/hardware-extra.nix) hooks host GPU extras; `deploy-full.sh` swaps it per detected vendor on new machines (generic default, Intel when an Intel iGPU is detected).
+ [`graphics-intel.nix`](../modules/system/graphics-intel.nix) adds Intel media/VAAPI drivers only for this host.

## Power

+ [`power.nix`](../modules/system/power.nix)
  + Uses [TLP](https://linrunner.de/tlp/) as the sole platform-profile owner and force-disables power-profiles-daemon.
  + Derives a six-hour power budget from current full-charge energy, smooths one-minute power samples with a 30%/70% EWMA, and adjusts the Intel HWP ceiling with multiplicative feedback.
  + Uses four capacity tiers: above 90% (`30%–75%`, `balance_power` EPP), 50%–90% (`20%–60%`), 20%–50% (`15%–45%`), and at or below 20% (`10%–30%`). The lower tiers use `power` EPP.
  + Every battery tier uses the `powersave` governor, low-power platform profile, and disabled Turbo/dynamic boost.
  + Enables PCIe ASPM, runtime PM (incl. AHCI), Wi-Fi/audio power saving, and USB autosuspend on battery; thermald runs alongside TLP.
  + Leaves Bluetooth available at boot and across AC/battery transitions so desktop controls can toggle it normally.
  + Noctalia applies the same smoothed, conservative `energy / max(measured rate, target rate)` estimate, so displayed time never exceeds the proportional six-hour target.
  + Uses deep suspend, a declared resume swap partition, and systemd's battery-aware suspend-then-hibernate. Lid close uses it on battery and plain suspend on AC.
  + The resume swap device (`boot.resumeDevice`, `swapDevices`) is machine-specific — review it before deploying on new hardware.

Live status is published at `/run/power-policy/status.json`. Heavy browser or proxy-renderer workloads can keep the measured estimate below the target even at a tier's CPU floor; the controller does not hide that load or claim battery wear can be recovered in software.

## Storage

+ [`mounts.nix`](../modules/system/mounts.nix) automounts two host-specific NTFS3 data volumes (`/mnt/Rina` and `/mnt/Eureka`) by UUID and unmounts them after five idle minutes. Verify UUIDs and the `force` option before reuse.

## Gaming and virtualization

+ [`gaming.nix`](../modules/system/gaming.nix) configures [Steam](https://store.steampowered.com/about/), [GameMode](https://github.com/FeralInteractive/gamemode), MangoHud, and Wine, including the Niri/Xwayland Steam CEF workaround.
+ [`virtualisation.nix`](../modules/system/virtualisation.nix) enables Docker/Compose with the host image-pull proxy, plus [libvirt](https://libvirt.org/), [virt-manager](https://virt-manager.org/), QEMU, swtpm, SPICE USB redirection, and Windows virtio drivers; unused `virtchd` is disabled.

## Host-specific files

+ `hardware-configuration.nix`: regenerate on another machine.
+ `host-local.nix`: current-machine values.
+ `proxy-local.nix`: daily network proxy entry.

[中文版](system_zh-CN.md)
