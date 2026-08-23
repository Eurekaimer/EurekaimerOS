# 配置架构

## 配置流向

+ [`flake.nix`](../flake.nix)
  + 固定 `nixpkgs` 25.11、`nixpkgs-unstable`、Home Manager、Noctalia、Komari Call、Lexigraph，以及非 flake 的 Hot100 源码输入。
  + 只在这里导入一次 `nixpkgs-unstable`，生成 `pkgs-unstable`。
  + 将 `pkgs-unstable` 同时通过 `specialArgs` 和 `home-manager.extraSpecialArgs` 传给下层模块。
  + 读取 `hosts/nixos/settings.nix` 与 `software-selection.nix`，将同一份主机参数和软件选择传给 NixOS 与 Home Manager。
  + 导出当前为 `x86_64-linux` 的 `nixosConfigurations.nixos`。
+ [`hosts/nixos/configuration.nix`](../hosts/nixos/configuration.nix)
  + 主机入口，组合硬件（hardware-configuration.nix + hardware-extra.nix）、主机本地参数、代理和通用系统模块。
  + `hardware-configuration.nix`、`host-local.nix`、`proxy-local.nix` 都属于机器或网络相关配置，不应直接复制到另一台机器。
+ [`modules/system/system.nix`](../modules/system/system.nix)
  + 聚合系统级模块：基础设施、用户、区域、桌面、电源、图形、挂载、游戏、虚拟化和系统软件包。
  + 保留职责分类不变，仅在聚合器层根据 `softwareSelection` 跳过未选择模块。
  + `power.nix` 仍是原分类入口，内部再按 TLP、自适应控制、温控、睡眠和诊断拆分到 `modules/system/power/`。
  + 系统模块负责服务、驱动、启动过程、字体缓存和所有用户共享的软件。
+ [`home/eurekaimer/home.nix`](../home/eurekaimer/home.nix)
  + Home Manager 用户入口，固定用户名、主目录和 `home.stateVersion`。
  + 聚合桌面、核心工具、开发环境和日常应用。
  + 另外导入 `modules/home/personal.nix`，个人命令不再混入通用应用和 shell。
  + 关闭 Home Manager 自己的 fontconfig，避免与系统层字体 XML 重复。

```mermaid
flowchart TD
  F[flake 输入 + flake.lock] --> H[hosts/nixos]
  H --> S[modules/system]
  H --> HM[Home Manager modules/home]
  C[software-selection.nix] --> S
  C --> HM
  S --> ES[eureka.software.system]
  HM --> EH[eureka.software.home]
  ES --> SP[environment.systemPackages]
  EH --> HP[home.packages]
```

## 模块边界

+ 系统层 `modules/system/`
  + 需要 root、systemd 系统服务、硬件、内核或全局字体时放在这里。
  + 小型通用命令按用途拆到 `modules/system/packages/`。
+ 用户层 `modules/home/`
  + 用户软件、XDG 配置、桌面快捷键、编辑器和语言工具链放在这里。
  + `config/` 保存由 Home Manager 映射到 `~/.config` 的真实配置目录。
+ 主机层 `hosts/nixos/`
  + `settings.nix` 集中用户、语言、兼容基线和个人模块默认值。
  + `host-local.nix`、`hardware-configuration.nix`、`hardware-extra.nix` 和 `proxy-local.nix` 保存仓库所有者已验证的真实机器/网络信息。
  + `software-selection.nix` 也是主机选择数据；它不包含包实现。

## 通用模块与个人模块

+ `modules/system/personal.nix` 只连接 Lexigraph 与 Komari Call 等个人 flake 模块。
+ `modules/home/personal/` 保存 campus-login、docker-ass 等包含学校 URL 或个人目录约定的命令。
+ 通用 `applications`、`core`、`development` 模块不再了解这些个人工作流。
+ 详细边界见 [个人专用模块](personal_zh-CN.md)。

## 软件包版本约定

+ 默认使用稳定版 `pkgs`。
  + 系统基础和大部分应用跟随 NixOS 25.11，减少整体更新风险。
+ 只对确实需要新版本的软件使用 `pkgs-unstable`。
  + 当前包括 Noctalia、OBS、mpv、部分通信软件和编辑器。
  + 模块只接收 `pkgs-unstable` 参数，禁止再次导入 unstable nixpkgs，避免同一配置出现多套不一致实例。

## 扩展方法

+ 新增主机
  + 新建 `hosts/<name>/`，保留独立硬件配置，并在 `flake.nix` 增加对应 `nixosConfigurations.<name>`。
+ 完整恢复仓库所有者当前机器时使用 `deploy-owner.sh`。其他机器使用 [`scripts/deploy-full.sh`](../scripts/deploy-full.sh)：重建硬件模块并套用可移植主机/代理默认值；GPU 必须通过 `generate-hardware.sh` 显式选择，脚本不自动探测。
+ 使用 [`scripts/select-software.sh`](../scripts/select-software.sh) 在现有分类边界上选择模块；选择规则见 [软件选择与配置生成](software-selection_zh-CN.md)。
+ 新增系统功能
  + 在 `modules/system/` 新建单一职责模块，再从 `system.nix` 导入。
+ 新增用户应用
  + 按类别加入 `modules/home/applications/`，并从 `applications.nix` 导入。
+ 新增语言工具链
  + 放入 `modules/home/development/toolchain/` 并从 `toolchain.nix` 导入；若有 VSCode 扩展，再在 `editors.nix` 增加读取同一语言开关的条件组。

## 上游项目

+ [NixOS](https://nixos.org/)
+ [Nix flakes](https://nix.dev/concepts/flakes.html)
+ [Home Manager](https://github.com/nix-community/home-manager)
