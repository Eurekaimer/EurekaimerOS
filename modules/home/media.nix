{ pkgs, inputs, ... }:

let
  unstable = import inputs.nixpkgs-unstable {
    system = pkgs.system;
    config.allowUnfree = true;
  };
in
{
  home.packages = [
    unstable.mpv
    pkgs.spotify
    unstable.go-musicfox
  ];

  xdg.configFile."mpv" = {
    source = ./config/mpv-config;
    recursive = true;
  };
}
