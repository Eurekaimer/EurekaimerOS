{ pkgs, pkgs-unstable, ... }:

{
  home.packages = [
    (pkgs-unstable.wrapOBS {
      plugins = with pkgs-unstable.obs-studio-plugins; [
        obs-multi-rtmp
        obs-pipewire-audio-capture
        obs-vaapi
      ];
    })
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
