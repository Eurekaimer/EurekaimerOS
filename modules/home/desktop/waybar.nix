{ ... }:

{
  programs.waybar.enable = false;
  xdg.configFile."waybar".source = ../config/waybar-config;
}
