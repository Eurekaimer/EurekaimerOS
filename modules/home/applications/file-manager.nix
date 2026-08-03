# GUI 文件管理器
#
# 选择 PCManFM（GTK3，LXDE 项目）：
#   - 轻量：单一 GTK3 应用，依赖面最小（nautilus 绑 GNOME、nemo 绑 Cinnamon、
#     Dolphin 绑 KDE，本机已移除 KDE/Plasma 全部组件）；
#   - GTK3 原生，本机渲染流畅（此前 Double Commander 为 Qt 重型双栏应用，
#     在 Wayland 下偏卡，已替换；SpaceFM 已从 nixpkgs 移除）；
#   - 开箱即用：标签页、桌面图标、通过 gvfs/udisks2 自动挂载（系统级已启用）。
#
# 终端侧的文件浏览仍由 yazi 承担（见 modules/home/core/yazi.nix）。
{ pkgs, ... }:

{
  eureka.software.home = with pkgs; [
    pcmanfm # 轻量 GTK3 文件管理器
  ];
}
