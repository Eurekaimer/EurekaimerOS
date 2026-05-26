# EurekaimerOS

Language: English | [中文说明](README_zh-CN.md)

A personal NixOS configuration built around **Niri**, **Noctalia**, **Home Manager**, and **flakes**.

![](https://cdn.jsdelivr.net/gh/Eurekaimer/MyIMGs@main/img/20260417160052566.png)

## Highlights

- Niri-based Wayland desktop workflow
- Noctalia shell components
- Declarative system and user environment
- Reusable module layout with host-specific files separated

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

## Notes

- `hardware-configuration.nix` is machine-specific and should be regenerated per host.
- Host-local and proxy settings may need adjustment on a new machine.
- `httpgd` is not enabled while it is marked broken in the current nixpkgs revision.
