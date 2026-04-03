{ config, pkgs, inputs, ... }:

{
  imports = [
    ../../modules/home/coding.nix
    ../../modules/home/office.nix
    ../../modules/home/noctalia.nix
    ../../modules/home/niri.nix
    ../../modules/home/read.nix
    ../../modules/home/media.nix
    ../../modules/home/internet.nix
    ../../modules/home/social.nix
    ../../modules/home/kitty.nix
    ../../modules/home/fastfetch.nix
    ../../modules/home/shell.nix
    ../../modules/home/ui.nix
    ../../modules/home/waybar.nix
  ];

  home.username = "eurekaimer";
  home.homeDirectory = "/home/eurekaimer";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;
}
