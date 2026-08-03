{ pkgs, ... }:

{
  eureka.software.home = with pkgs; [
    yazi # 终端文件管理器（图片预览依赖 imv，见 desktop/niri.nix）
  ];
}
