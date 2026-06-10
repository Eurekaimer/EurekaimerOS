{ pkgs, pkgs-unstable, ... }:

{
  home.packages = [
    pkgs-unstable.mpv
    pkgs.ffmpeg
    pkgs.mediainfo
    pkgs.spotify
    pkgs.trash-cli
    pkgs.yt-dlp
    pkgs-unstable.go-musicfox
    pkgs.netease-cloud-music-gtk
  ];

  xdg.configFile."mpv" = {
    source = ../config/mpv-config;
    recursive = true;
  };
}
