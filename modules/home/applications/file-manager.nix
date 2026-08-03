# GUI 文件管理器
#
# 选择 Double Commander（纯 Qt 应用）：
#   - 完全不绑定任何桌面生态（KDE/XFCE/GNOME 依赖均为零），开箱即用；
#   - 功能接近 Dolphin：双栏布局、标签页、内置终端、压缩包直接浏览、
#     快捷键（F5 复制 / F6 移动等）、深色主题；
#   - 备选方案：SpaceFM（GTK3 更轻量）或 Thunar（XFCE，会带入生态依赖）。
#
# 终端侧的文件浏览仍由 yazi 承担（见 modules/home/core/yazi.nix）。
{ pkgs, ... }:

{
  eureka.software.home = with pkgs; [
    doublecmd # 双栏 GUI 文件管理器（独立 Qt 应用）
  ];
}
