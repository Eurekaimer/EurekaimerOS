{ pkgs, inputs, ... }:

let
  unstable = import inputs.nixpkgs-unstable {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnfree = true;
  };
in
{
  home.packages = [
    unstable.mpv
    pkgs.spotify
    unstable.go-musicfox
    pkgs.netease-cloud-music-gtk
  ];

  xdg.configFile."mpv" = {
    source = ../config/mpv-config;
    recursive = true;
  };
}
