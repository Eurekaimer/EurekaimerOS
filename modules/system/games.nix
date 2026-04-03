{ pkgs, inputs, ... }:

let
  # 在这里引入 unstable 分支，供下面的游戏软件使用
  pkgs-unstable = import inputs.nixpkgs-unstable {
    system = pkgs.system;
    config.allowUnfree = true;
  };
in
{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    extest.enable = true;
  };

  # gamemode
  programs.gamemode.enable = true;

  environment.systemPackages = with pkgs; [
    # WINE for Galgame
    mangohud
    wine
  ] ++ [
    # LUTRIS for Arknights
    pkgs-unstable.lutris
    pkgs-unstable.protonplus
    pkgs-unstable.umu-launcher
  ];
}
