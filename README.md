# EurekaimerOS

Language: English | [中文说明](README_zh-CN.md)

A personal NixOS configuration built around **Niri**, **Noctalia**, **Home Manager**, and **flakes**.

![](https://cdn.jsdelivr.net/gh/Eurekaimer/MyIMGs@main/img/20260417160052566.png)

## Highlights

- Niri-based Wayland desktop workflow
- Noctalia shell components
- Declarative system and user environment
- Reusable module layout with host-specific files separated

## Recovery Notes

For reinstalling or recovering this setup, keep the early path simple:

1. In the live ISO, add a Nix binary cache mirror to `/etc/nix/nix.conf`.
2. Install a minimal working system first, using the GUI installer if convenient.
3. After the first boot, add the mirror again in the installed system.
4. Restore network/proxy access and GitHub access. Prefer `throne` or `nekoray` early; use `mihomo` directly if a headless core is enough.
5. Fetch this repository and run the rebuild command.

This avoids making the initial install depend on a proxy GUI, browser login, or a fully working desktop session.

In the live ISO, rebuild `/etc/nix/nix.conf` as a normal file and add mirrors:

```bash
sudo cp -L /etc/nix/nix.conf /etc/nix/nix.conf.bak
sudo rm /etc/nix/nix.conf
sudo tee /etc/nix/nix.conf >/dev/null <<'EOF'
experimental-features = nix-command flakes
substituters = https://mirrors.ustc.edu.cn/nix-channels/store https://cache.nixos.org/
EOF
sudo systemctl restart nix-daemon
```

The configured system currently prefers domestic mirrors in `modules/system/base.nix`. If a mirror is stale or incomplete, switch mirrors temporarily and rebuild again.

## Layout

```text
hosts/nixos/                 host entry and hardware config
home/eurekaimer/home.nix     Home Manager entry
modules/system/              system-level modules
modules/home/                user-level modules
```

Key files:

- `hosts/nixos/configuration.nix`
- `home/eurekaimer/home.nix`
- `modules/home/development/toolchain.nix`

## Rebuild

```bash
sudo nixos-rebuild switch --flake .#nixos
```

## R And Notebook Support

R is provided through Nix wrappers. The development toolchain includes R Markdown, common statistics packages, plotting packages, Jupyter, and a declarative `R (Nix)` kernel.

After rebuilding:

```bash
jupyter kernelspec list
```

The list should include `r-nix`.

## Troubleshooting Notes

- `hardware-configuration.nix` is machine-specific and should be regenerated per host.
- Host-local and proxy settings may need adjustment on a new machine.
- During early recovery, prefer `throne`, `nekoray`, or `mihomo`; `clash-verge-rev` depends on WebView and is better used after the full desktop environment is stable.
- Steam may show a black UI under Niri/Xwayland. `modules/system/gaming.nix` currently works around this with `-cef-disable-gpu-compositing`.
- `httpgd` is not enabled while it is marked broken in the current nixpkgs revision.

## Notes

- For another host, add a separate `hosts/<name>/` entry instead of reusing machine-specific files blindly.
