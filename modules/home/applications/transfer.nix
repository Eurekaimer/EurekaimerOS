{ pkgs, pkgs-unstable, ... }:

{
  home.packages = [
    pkgs.motrix
    pkgs.qbittorrent
    pkgs-unstable.picgo
  ];
}
