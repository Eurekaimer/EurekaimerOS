# 内核模块
#
# 内核版本策略：
#   - 当前使用 6.12 LTS（长期支持版），兼顾新硬件支持与稳定性；
#   - 想换内核版本时，只改下面这一行，例如：
#       pkgs.linuxPackages_latest   # 最新稳定版（尝鲜，更新频繁）
#       pkgs.linuxPackages_6_6      # 更保守的旧 LTS
#   - 想用第三方内核（zen / xanmod / liquorix 等）：
#       boot.kernelPackages = pkgs.linuxPackages_zen;
#   - 深度定制见官方手册：https://nixos.wiki/wiki/Linux_kernel
#
# 注意：换内核后首次重建会重新编译内核模块（约 10~30 分钟），
# 之后切换回缓存命中的版本则只是下载。
{ pkgs, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages_6_12;
}
