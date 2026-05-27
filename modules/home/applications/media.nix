{ pkgs, pkgs-unstable, ... }:

{
  home.packages = [
    pkgs-unstable.mpv
    pkgs.spotify
    pkgs-unstable.go-musicfox
    pkgs.netease-cloud-music-gtk
  ];

  xdg.configFile."mpv" = {
    source = ../config/mpv-config;
    recursive = true;
  };
}
