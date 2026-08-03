# 系统软件聚合层（抽象层）
#
# 职责：
#   1. 声明 `eureka.software.system` 选项 —— 所有系统级软件包都通过
#      各分类模块往这个选项里注册，而不是直接写 environment.systemPackages；
#   2. 把注册结果统一汇入 environment.systemPackages。
#
# 为什么这样设计（简化 + 可扩展）：
#   - 增删软件：只改对应分类模块中的一行，不碰任何聚合逻辑；
#   - 新增分类：新建一个模块文件 + 在 packages.nix 里加一行 import；
#   - 清单可查：所有系统软件集中在 modules/system/packages/ 下，
#     配合 readme/software.md 一览无余；
#   - 聚合逻辑只有一处，避免多个模块各写各的 environment.systemPackages。
{ lib, config, ... }:

{
  options.eureka.software.system = lib.mkOption {
    type = lib.types.listOf lib.types.package;
    default = [ ];
    description = ''
      系统级软件包清单（最终汇入 environment.systemPackages）。
      由 modules/system/packages/ 下的各分类模块通过 `eureka.software.system`
      注册软件包。
    '';
  };
  config.environment.systemPackages = config.eureka.software.system;
}
