# 系统监控工具（系统级）
{ pkgs, ... }:

{
  eureka.software.system = with pkgs; [
    ncdu # 磁盘占用分析（终端 TUI）
    btop # 系统资源监控（CPU/内存/网络/进程）
  ];
}
