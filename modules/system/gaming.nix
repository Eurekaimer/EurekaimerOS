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

  eureka.software.system = with pkgs; [
    mangohud # 游戏内性能监控 HUD（帧率/温度/功耗）
    wine     # Windows 兼容层（运行 Windows 游戏/软件）
  ] ++ [
    pkgs-unstable.lutris        # 游戏管理器（unstable）
    pkgs-unstable.protonplus    # Proton 版本管理
    pkgs-unstable.umu-launcher  # UMU 启动器（运行非 Steam 游戏）
  ];
}
