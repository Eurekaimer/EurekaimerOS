{ pkgs, ... }:

{
  home.packages = with pkgs; [
    xwayland-satellite
    rofi
    swww
    swaynotificationcenter
    pamixer
    brightnessctl
    libnotify
    grim
    slurp
    wl-clipboard
    hyprlock
    imv
    pavucontrol
  ];

  services.swayosd.enable = true;

  xdg.configFile."niri/config.kdl".source = ./config/niri-config/config.kdl;
}
