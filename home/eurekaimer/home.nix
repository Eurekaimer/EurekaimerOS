{ ... }:

{
  imports = [
    ../../modules/home/desktop.nix
    ../../modules/home/core.nix
    ../../modules/home/development.nix
    ../../modules/home/applications.nix
  ];

  home.username = "eurekaimer";
  home.homeDirectory = "/home/eurekaimer";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;
}
