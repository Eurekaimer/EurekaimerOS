# EurekaimerOS

[English](README.md)

这是一个围绕 Niri、Noctalia、Home Manager 和 flakes 组织的个人 NixOS 配置。`/etc/nixos` 是当前运行配置，本仓库是需要经常同步的长期维护副本。

![EurekaimerOS 系统展示](img/system-showcase.png)

## 按需选择文档

+ [配置架构](docs/architecture_zh-CN.md)
  + flake 输入和软件包传递
  + 主机、系统与 Home Manager 的职责边界
  + 新增主机、系统模块、应用和工具链的方法
+ [系统层配置](docs/system_zh-CN.md)
  + 启动、网络、中文环境、LXGW 字体、图形和桌面服务
  + TLP 电源策略、存储、游戏与虚拟化
+ [桌面与用户界面](docs/desktop_zh-CN.md)
  + Niri 会话、截图和窗口规则
  + Noctalia、GTK、图标、核心用户工具和可选界面
+ [应用软件](docs/applications_zh-CN.md)
  + Chrome 与 Throne 作为声明的浏览器
  + 文档、媒体、通信、下载和默认应用
  + 主要软件的官方项目地址，用于说明来源并尊重上游贡献
+ [开发环境](docs/development_zh-CN.md)
  + 编辑器、CLI、语言工具链、Notebook 和 AI 工具
+ [构建和维护](docs/operations_zh-CN.md)
  + 重建与验证命令
  + 恢复、迁移、电源诊断和 EurekaimerOS 同步方法
+ [完整中文文档索引](docs/index_zh-CN.md)
  + 从总览进入每个独立配置主题

## 仓库结构

```text
flake.nix
├── inputs
│   ├── nixpkgs
│   ├── nixpkgs-unstable
│   ├── home-manager
│   ├── noctalia
│   ├── lexigraph
│   └── llm-agents
└── nixosConfigurations.nixos
    ├── hosts/nixos/configuration.nix
    │   ├── hardware-configuration.nix
    │   ├── host-local.nix
    │   ├── proxy-local.nix
    │   ├── modules/system/system.nix
    │   └── modules/system/graphics-intel.nix
    └── home-manager.users.eurekaimer
        └── home/eurekaimer/home.nix
            ├── modules/home/desktop.nix
            ├── modules/home/core.nix
            ├── modules/home/development.nix
            └── modules/home/applications.nix

docs/
├── index.md / index_zh-CN.md
└── <主题>.md / <主题>_zh-CN.md
```

+ [`flake.nix`](flake.nix)
  + 固定 stable/unstable 软件包输入并构建 `nixosConfigurations.nixos`。
+ [`hosts/nixos/`](hosts/nixos/)
  + 当前机器的硬件、本地参数和代理入口。
+ [`modules/system/`](modules/system/)
  + 需要 root 的 NixOS 服务、硬件、电源、字体、虚拟化和共享软件。
+ [`home/eurekaimer/`](home/eurekaimer/)
  + Home Manager 用户入口。
+ [`modules/home/`](modules/home/)
  + 桌面、用户配置、应用和开发环境。
+ [`docs/`](docs/)
  + 对本仓库自身配置的中英文解释文档。

## 构建

+ 只验证构建，不切换当前系统：

```bash
nix build .#nixosConfigurations.nixos.config.system.build.toplevel --no-link
```

+ 构建并切换当前系统：

```bash
sudo nixos-rebuild switch --flake .#nixos
```

## 当前关键决策

+ 中英文界面统一使用 LXGW WenKai Screen；终端和代码保留真正的等宽字体。
+ Google Chrome 与 Throne 是声明的浏览器；Firefox 和过期窗口规则已经移除。
+ TLP 是唯一电源档位管理器。电池模式 CPU 上限为 50%，关闭 Turbo/HWP dynamic boost，并在电池切换时关闭蓝牙。
+ 默认使用稳定版软件包；快速更新的软件只使用 `flake.nix` 传下来的单一 `pkgs-unstable`。
+ 磁盘 UUID、代理和硬件配置与当前机器绑定，迁移前必须核对。
