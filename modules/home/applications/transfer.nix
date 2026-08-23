{ pkgs, pkgs-unstable, ... }:

{
  eureka.software.home = [
    pkgs.qbittorrent     # BT 下载客户端
    pkgs-unstable.picgo  # 图床工具（unstable）
  ];
}
