{ pkgs, inputs, ... }:

let
  unstable = import inputs.nixpkgs-unstable {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnfree = true;
  };
in
{
  home.packages = [
    pkgs.motrix
    pkgs.qbittorrent
    unstable.picgo
  ];
}
