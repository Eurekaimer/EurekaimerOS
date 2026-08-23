{ pkgs, ... }:

{
  eureka.software.home = with pkgs; [
    google-chrome   # Chrome 浏览器（默认）
    clash-verge-rev # Clash 图形客户端（配 mihomo 内核）
    throne          # 浏览器（Throne）
  ];
}
