# 网络工具（系统级）
{ pkgs, ... }:

{
  eureka.software.system = with pkgs; [
    wget   # HTTP 下载工具
    curl   # HTTP 请求工具（脚本/调试必备）
    mihomo # Clash Meta 内核（代理核心；GUI 见 home 的 clash-verge-rev）
  ];
}
