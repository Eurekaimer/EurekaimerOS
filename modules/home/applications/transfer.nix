{ pkgs, pkgs-unstable, ... }:

{
  eureka.software.home = [
    pkgs.motrix          # 多协议下载器（HTTP/BT/磁力）
    pkgs.qbittorrent     # BT 下载客户端（配合 docker-ass 脚本）
    pkgs-unstable.picgo  # 图床工具（unstable）
  ];
}
