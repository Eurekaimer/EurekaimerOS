{ pkgs, pkgs-unstable, ... }:

{
  eureka.software.home = [
    pkgs.qbittorrent     # BT 下载客户端（配合 docker-ass 脚本）
    pkgs-unstable.picgo  # 图床工具（unstable）
  ];
}
