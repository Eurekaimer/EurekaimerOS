{ pkgs, ... }:

{
  home.packages = with pkgs; [
    xwayland-satellite
    pamixer
    brightnessctl
    grim
    slurp
    wl-clipboard
    hyprlock
    imv
    pavucontrol
    kdePackages.polkit-kde-agent-1
  ];

  services.swayosd.enable = false;
  xdg.configFile."niri/config.kdl".source = ../config/niri-config/config.kdl;
}
