{ pkgs, pkgs-unstable, ... }:

let
  wechat = pkgs-unstable.callPackage ./wechat-official.nix { };
in
{
  eureka.software.home = [
    pkgs-unstable.feishu # 飞书（unstable）
    pkgs-unstable.qq     # QQ（unstable）
    wechat               # 微信官方 Linux 客户端（FHS 封装，见 wechat-official.nix）
    pkgs.zoom-us         # Zoom 会议
  ];
}
