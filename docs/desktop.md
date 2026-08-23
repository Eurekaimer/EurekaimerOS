# Desktop and User Interface

The user desktop entry point is [`modules/home/desktop.nix`](../modules/home/desktop.nix). Niri and Noctalia are the only shell components; no second launcher or panel is started.

## Niri session

+ [`desktop/niri.nix`](../modules/home/desktop/niri.nix)
  + Installs Xwayland Satellite, audio/brightness tools (pamixer, brightnessctl), a volume mixer (pavucontrol), Hyprlock, an image viewer, and a Polkit authentication agent (polkit-gnome).
  + Installs grim, slurp, wf-recorder, and wl-clipboard, and creates `~/Pictures/Screenshots`.
  + Generates `niri-window-shot`, which obtains a real window ID through Niri IPC and preserves rounded corners, shadows, and transparency.
  + Runs swayidle as a user service: lock after 15 minutes, turn the display off after 20 minutes, then suspend-then-hibernate after 25/40/60/90 idle minutes for the ≤20%, 20%–50%, 50%–90%, and >90% tiers.
  + Maps [`config/niri-config/config.kdl.in`](../modules/home/config/niri-config/config.kdl.in) to `~/.config/niri/config.kdl`.
+ Niri configuration
  + Starts Fcitx 5, the Polkit agent, Xwayland Satellite, and the tray proxy; Noctalia and swayidle are separate user services.
  + Owns input, layout, animation, window-rule, and keybinding behavior.
  + Google Chrome picture-in-picture windows float automatically; the obsolete Firefox rule was removed.
  + Screenshot bindings: `Print` for a monitor, `Alt+Print` for the focused window, `Mod+Alt+Print` to pick a window, and `Shift+Print` for a region.

Upstream: [Niri](https://niri-wm.github.io/niri/) and [Xwayland Satellite](https://github.com/Supreeeme/xwayland-satellite).

## Noctalia

+ [`desktop/noctalia.nix`](../modules/home/desktop/noctalia.nix)
  + Imports the Noctalia Home Manager module, runs it as a user service, and applies the repository battery-estimate patch.
+ [`config/noctalia-config/settings.json.in`](../modules/home/config/noctalia-config/settings.json.in)
  + Controls the panel, notifications, OSD, launcher, and status surfaces.
  + Uses `LXGW WenKai Screen` for normal UI text while fixed-width text keeps the system `monospace` family.
  + Wallpaper rendering in Noctalia is disabled and notification sounds are off; the Niri session sets the wallpaper with swww.

Upstream: [Noctalia Shell](https://docs.noctalia.dev/) and [Quickshell](https://quickshell.org/).

## GTK, icons, and fonts

+ [`core/ui.nix`](../modules/home/core/ui.nix)
  + Sets the GTK 2/3/4 font to LXGW WenKai 11.
  + Uses Papirus Dark icons and the Bibata Modern Ice cursor.
  + Keeps XDG user directories at stable English paths.

Upstream: [GTK](https://www.gtk.org/), [Papirus](https://github.com/PapirusDevelopmentTeam/papirus-icon-theme), and [Bibata Cursor](https://github.com/ful1e5/Bibata_Cursor).

## Core user tools

+ [`modules/home/core.nix`](../modules/home/core.nix)
  + Uses `softwareSelection.home.core` to select the following categories while each category file stays independent.
  + Shell utilities and Zsh support.
  + Kitty configuration; the terminal uses Fantasque Sans Mono Nerd Font (size 18) for code alignment and icon glyphs.
  + Fastfetch presentation settings.
  + Yazi terminal file manager.
  + A declarative user service for trash cleanup.

Upstream: [Kitty](https://sw.kovidgoyal.net/kitty/), [Yazi](https://yazi-rs.github.io/), and [Fastfetch](https://github.com/fastfetch-cli/fastfetch).

Niri and Noctalia define the current EurekaimerOS desktop and are not optional package categories. Their surrounding core tools can be trimmed through the [software-selection wizard](software-selection.md).
