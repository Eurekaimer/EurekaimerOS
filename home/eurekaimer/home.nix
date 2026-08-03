{ ... }:

{
  imports = [
    ../../modules/home/desktop.nix
    ../../modules/home/core.nix
    ../../modules/home/development.nix
    ../../modules/home/applications.nix
    ../../modules/home/software.nix
  ];

  home.username = "eurekaimer";
  home.homeDirectory = "/home/eurekaimer";
  home.stateVersion = "25.11";
  home.sessionPath = [ "$HOME/.local/bin" ];

  # Fontconfig is managed at the system level via modules/system/locale.nix.
  # Disabling it here avoids a conflict with the system-level font
  # configuration and keeps the Home Manager fontconfig module from
  # generating overlapping fontconfig XML.
  fonts.fontconfig.enable = false;

  programs.home-manager.enable = true;
}
