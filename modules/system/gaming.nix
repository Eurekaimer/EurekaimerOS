{ pkgs, pkgs-unstable, ... }:

{
  hardware.graphics = {
    enable32Bit = true;
  };

  programs.steam = {
    enable = true;
    package = pkgs.steam.override {
      # Work around black Steam UI on niri/xwayland-satellite while keeping
      # webhelper GPU acceleration enabled.
      extraArgs = "-cef-disable-gpu-compositing";
    };
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    extest.enable = true;
  };

  programs.gamemode.enable = true;

  environment.systemPackages = with pkgs; [
    mangohud
    wine
  ] ++ [
    pkgs-unstable.lutris
    pkgs-unstable.protonplus
    pkgs-unstable.umu-launcher
  ];
}
