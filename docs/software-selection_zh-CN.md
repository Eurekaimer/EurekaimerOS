# 软件选择与配置生成

EurekaimerOS 保留原有的系统、桌面、应用、开发工具链分类。软件选择机制只控制现有聚合器是否导入某个分类模块，不复制包清单，也不直接调用 `nix-env` 安装软件。

## 数据流

[`hosts/nixos/software-selection.nix`](../hosts/nixos/software-selection.nix) 是当前主机的软件选择文件。它是一个纯 Nix 属性集，由 [`flake.nix`](../flake.nix) 同时传给 NixOS 与 Home Manager：

```text
software-selection.nix
├── system       → modules/system 的聚合器与服务开关
├── home         → modules/home 的 core/application/development 聚合器
└── personal     → 个人项目与个人命令模块
```

各分类模块仍然只负责自己的软件和配置。例如 Java 包仍全部位于 `modules/home/development/toolchain/java.nix`；选择器只决定 `toolchain.nix` 是否导入它。

## 交互选择

运行：

```bash
./scripts/select-software.sh
```

向导首先询问中文或 English，然后依次处理：

1. 系统服务：TLP、自适应功耗、温控、睡眠、诊断、挂载、游戏、打印、蓝牙、Docker、虚拟机。
2. 系统软件包：基础 CLI、网络、监控、压缩、DOSBox。
3. 用户核心环境：Zsh、Kitty、Fastfetch、GTK UI、Yazi、回收站清理。
4. 图形应用：知识管理、文档、媒体、浏览器、文件管理、下载、通信。
5. 开发环境：编辑器、通用 CLI，以及每一种语言工具链。
6. 个人模块：Lexigraph、Komari Call、campus-login、docker-ass、Hot100 Assistant。

当前完整配置是默认值，直接按 Enter 会保留对应分类。生成前会自动处理四项依赖：

- 启用 `campus-login` 时必须启用浏览器分类。
- 启用 `docker-ass` 时必须启用 Docker。
- 自适应功耗控制器依赖 TLP。
- Hot100 Assistant 依赖 VSCode 编辑器分类。

Oh My Pi 与其固定 Bun 运行时是仓库所有者要求的基础功能，不属于可选开关；即使关闭通用 JavaScript 工具链，它仍由 `toolchain/oh-my-pi.nix` 安装。

选择器不会重写 Niri 的个人快捷键。若关闭 Kitty、Yazi、Obsidian 或 VSCode，对应的 `Mod+Return`、`Mod+Y`、`Mod+O`、`Mod+V` 仍保留但无法启动程序；这是有意保持“软件选择”和“桌面按键定制”两个职责分离。需要关闭这些软件时，请同时调整 `modules/home/config/niri-config/config.kdl.in`。

旧选择文件会备份为 `software-selection.nix.backup-<时间>`，新文件通过临时文件原子覆盖。生成后可以选择：只写配置、运行 `nixos-rebuild build`、或运行 `nixos-rebuild switch`。

## 非交互使用

```bash
# 启用全部分类，不执行 rebuild
./scripts/select-software.sh --all --language zh --rebuild none

# 生成精简配置并验证构建
./scripts/select-software.sh --minimal --language en --rebuild build

# 写到测试位置，不覆盖当前选择
./scripts/select-software.sh --minimal --output /tmp/software-selection.nix
```

`--minimal` 仍保留 Niri 桌面所需的核心 UI、浏览器、PCManFM、基础 CLI、网络与 Nix 开发工具。它是一个方便的起点，不是新的仓库架构或不可修改的 profile。

## 开关与模块对应关系

| 选择分组 | 聚合/实现位置 |
|---|---|
| `system.packages.*` | `modules/system/packages.nix` |
| `system.power.*` | `modules/system/power.nix`、`modules/system/power/` |
| `system.mounts/gaming` | `modules/system/system.nix` |
| `system.virtualisation.*` | `modules/system/virtualisation.nix` |
| `system.desktop.*` | `modules/system/desktop.nix` |
| `home.core.*` | `modules/home/core.nix` |
| `home.applications.*` | `modules/home/applications.nix` |
| `home.development.*` | `modules/home/development.nix`、`development/toolchain.nix` |
| `personal.*` | `modules/system/personal.nix`、`modules/home/personal.nix` |

新增分类时应遵循原有模式：建立单一职责模块、在对应聚合器增加一项选择、在 `software-selection.nix` 和选择脚本增加同名布尔值，并更新 [`software.md`](../software.md)。

## 软件数量报告

```bash
./scripts/software-report.sh
./scripts/software-report.sh --list
```

报告通过 `nix eval` 读取当前选择真正产生的 `environment.systemPackages` 与 `home.packages`，因此数量不会依赖手工维护的统计数字。服务型功能不一定出现在包列表中，它们仍在 [`software.md`](../software.md) 的“系统服务”部分单独记录。

[English](software-selection.md)
