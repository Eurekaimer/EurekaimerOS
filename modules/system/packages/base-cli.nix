# 基础命令行工具（系统级）
#
# 说明：所有软件都注册到 eureka.software.system 选项，
# 由 software.nix 统一汇入 environment.systemPackages。
# 增删软件：直接增删下面列表中的行即可。
{ pkgs, ... }:

{
  eureka.software.system = with pkgs; [
    git      # 版本控制，基础必备
    gh       # GitHub 官方 CLI（PR、issue、release 管理）
    python3  # Python 解释器（日常脚本用；Python 开发环境见 toolchain/python.nix 的 uv）
  ];
}
