# Home 软件聚合层（抽象层）
#
# 职责：
#   1. 声明 `eureka.software.home` 选项 —— 所有用户级软件包都通过
#      modules/home/ 下的各分类模块往这个选项里注册，而不是直接写 home.packages；
#   2. 把注册结果统一汇入 home.packages。
#
# 设计动机与 modules/system/software.nix 相同：
#   - 增删软件只改对应模块的一行；
#   - 新增分类 = 新建模块文件 + 在对应聚合器里加一行 import；
#   - 分类开关集中在 hosts/nixos/software-selection.nix，模块仍只负责
#     自己的软件与配置；
#   - 系统级与用户级软件分层清晰（system → environment.systemPackages，
#     home → home.packages）。
{ lib, config, ... }:

{
  options.eureka.software.home = lib.mkOption {
    type = lib.types.listOf lib.types.package;
    default = [ ];
    description = ''
      用户级软件包清单（最终汇入 home.packages）。
      由 modules/home/ 下的各分类模块通过 `eureka.software.home` 注册软件包。
    '';
  };

  config.home.packages = config.eureka.software.home;
}
