# 图形栈基础（系统级）
{ pkgs, ... }:

{
  hardware.graphics.enable = true;

  eureka.software.system = with pkgs; [
    libva-utils # VA-API 硬件解码测试工具（vainfo）
  ];
}
