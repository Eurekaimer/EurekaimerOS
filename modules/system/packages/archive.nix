# 压缩/解压工具（系统级）
{ pkgs, ... }:

{
  eureka.software.system = with pkgs; [
    peazip # 图形化压缩包管理器（多格式）
  ];
}
