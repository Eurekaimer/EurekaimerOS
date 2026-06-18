{ pkgs-unstable, ... }:

{
  home.packages = [
    pkgs-unstable.wezterm
  ];

  xdg.configFile."wezterm/wezterm.lua".source = ../config/wezterm-config/wezterm.lua;
}
