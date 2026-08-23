# EurekaimerOS

[English](README.md)

这是一个围绕 Niri、Noctalia、Home Manager 和 flakes 组织的个人 NixOS 配置。`/etc/nixos` 是当前运行配置，本仓库是需要经常同步的长期维护副本。

![EurekaimerOS 系统展示](img/system-showcase.png)

ReGreet 登录界面与 Hyprlock 锁屏共用同一张壁纸和问候语：

![ReGreet 登录界面](img/regreet-demo.png)

![Hyprlock 锁屏](img/hyprlock-demo.png)

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
  + Noctalia、GTK、图标和核心用户工具
+ [应用软件](docs/applications_zh-CN.md)
  + Chrome 与 Throne 作为声明的浏览器
  + 文档、媒体、文件管理器、通信、下载和默认应用
  + 主要软件的官方项目地址，用于说明来源并尊重上游贡献
+ [开发环境](docs/development_zh-CN.md)
  + 编辑器、CLI、语言工具链、Notebook 和 AI 工具
+ [软件选择与配置生成](docs/software-selection_zh-CN.md)
  + 中英文 CLI 向导、分类开关、配置覆盖与可选 rebuild
+ [个人专用模块](docs/personal_zh-CN.md)
  + Lexigraph、Komari Call、南开校园认证和 docker-ass 的隔离边界
+ [构建和维护](docs/operations_zh-CN.md)
  + 重建与验证命令
  + 恢复、迁移、电源诊断和 EurekaimerOS 同步方法
+ [完整中文文档索引](docs/index_zh-CN.md)
  + 从总览进入每个独立配置主题

## 软件清单与数量

[`software.md`](software.md) 是仓库中全部声明软件包、服务、来源、用途与选择开关的唯一完整清单。新增或移除软件时，应同时更新对应模块和该清单。

当前选择实际产生的软件包数量可以直接从 Nix 求值结果生成，无需手工计数：

```bash
./scripts/software-report.sh          # 系统、Home Manager 与总数
./scripts/software-report.sh --list   # 另外列出求值后的包名
```

## 仓库结构

```text
flake.nix
├── inputs
│   ├── nixpkgs
│   ├── nixpkgs-unstable
│   ├── home-manager
│   ├── noctalia
│   ├── komari-call
│   ├── lexigraph
│   └── hot100-assistant
└── nixosConfigurations.nixos
    ├── hosts/nixos/configuration.nix
    │   ├── hardware-configuration.nix
    │   ├── hardware-extra.nix
    │   ├── host-local.nix
    │   ├── proxy-local.nix
    │   ├── software-selection.nix
    │   ├── modules/system/system.nix
    │   ├── modules/system/personal.nix
    │   └── modules/system/software.nix
    └── home-manager.users.eurekaimer
        └── home/eurekaimer/home.nix
            ├── modules/home/desktop.nix
            ├── modules/home/core.nix
            ├── modules/home/development.nix
            ├── modules/home/applications.nix
            ├── modules/home/personal.nix
            └── modules/home/software.nix

docs/
├── index.md / index_zh-CN.md
└── <主题>.md / <主题>_zh-CN.md

scripts/
├── select-software.sh
├── generate-hardware.sh
├── software-report.sh
├── deploy-full.sh
├── deploy-preserve-hardware.sh
├── deploy-desktop.sh
├── deploy-power.sh
├── deploy-software.sh
└── deploy-common.sh
```

> `host-generic.nix`、`proxy-disabled.nix` 与 `hardware-extra-generic.nix` 是新机器默认值，由 `deploy-full.sh` 部署时交换到位。

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

+ 如果准备直接从 clone 构建，先重新生成当前机器的硬件配置（旧文件会自动备份）：

```bash
./scripts/generate-hardware.sh
```

+ 然后运行双语软件选择向导。它会生成并覆盖当前主机的声明式选择文件，并可在最后帮助运行 rebuild：

```bash
./scripts/select-software.sh
```

不要在尚未生成并核对本机硬件配置时选择 `rebuild switch`。如果使用后面的 `deploy-full.sh` 流程，它会在部署阶段重新生成硬件文件。

+ 只验证构建，不切换当前系统：

```bash
nix build .#nixosConfigurations.nixos.config.system.build.toplevel --no-link
```

+ 构建并切换当前系统：

```bash
sudo nixos-rebuild switch --flake .#nixos
```

+ 新机器部署：将克隆内容部署到 `/etc/nixos`，重新生成硬件配置并套用可移植的主机/代理默认值（代理保持禁用，直到配置好后再启用）：

```bash
./scripts/deploy-full.sh
```

+ 本机重装：保留目标机现有的硬件与主机文件，重新部署：

```bash
./scripts/deploy-preserve-hardware.sh
```

+ 局部更新：只推送某一区域到已有的 `/etc/nixos`：

```bash
./scripts/deploy-desktop.sh   # 或 deploy-power.sh / deploy-software.sh
```

部署脚本执行后，统一用 `sudo nixos-rebuild switch --flake /etc/nixos#nixos` 切换。

## 当前关键决策

+ 界面文字首选 LXGW WenKai；登录/锁屏与桌面 shell 使用 LXGW WenKai Screen；终端使用 Fantasque Sans Mono Nerd Font，等宽回退为 LXGW WenKai Mono。
+ 浏览器只保留 Google Chrome 与 Throne；Firefox 和过期的窗口规则已经移除。
+ TLP 负责电源档位。一个小控制器每分钟采样电量并调整 90%/50%/20% 分档，以当前满充容量续航 6 小时为目标；空闲时使用 suspend-then-hibernate。
+ 默认使用稳定版软件包；只有快速更新的软件从 `flake.nix` 中的单一 `pkgs-unstable` 取包。
+ 启用 Docker 与 Compose，镜像通过本地代理拉取。
+ 磁盘 UUID、代理和硬件配置都与当前机器绑定，迁移前必须核对。
