{ pkgs, ... }:

{
  home.packages = with pkgs; [
    rofi
  ];

  xdg.configFile."rofi".source = ../config/rofi-config;
}
