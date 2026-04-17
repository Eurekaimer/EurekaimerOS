# EurekaimerOS

语言：中文 | [English (README.md)](README.md)

这是我的个人 NixOS 配置仓库，核心主线是 **Niri + Noctalia**：

![](https://cdn.jsdelivr.net/gh/Eurekaimer/MyIMGs@main/img/20260417160052566.png)

- **Niri**：负责窗口管理与日常操作流（当前主力桌面体验）。
- **Noctalia**：负责壳层交互体验（状态栏/控制中心这一类能力）。
- **Flake + Home Manager**：保证配置可声明、可复现、可迁移。

如果你也想搭一套“结构清晰、以 Niri/Noctalia 为中心”的 NixOS 配置，这个仓库就是按这个目标整理的。

## 这个仓库在意什么

- 分层清楚：避免把所有逻辑塞进一个大文件。
- 可迁移：把“可复用模块”和“主机专属差异”分开。
- 可维护：入口固定，读配置时路径稳定。

---

## 入口文件

- 系统入口：`hosts/nixos/configuration.nix`
- 用户入口：`home/eurekaimer/home.nix`

`home.nix` 只导入 4 个顶层模块：

1. `modules/home/desktop.nix`
2. `modules/home/core.nix`
3. `modules/home/development.nix`
4. `modules/home/applications.nix`

---

## Home 层次（重点：Niri/Noctalia）

```text
modules/home
├── desktop.nix
│   ├── desktop/noctalia.nix
│   ├── desktop/niri.nix
│   ├── desktop/rofi.nix       （可选，默认不启用）
│   └── desktop/waybar.nix     （可选，默认不启用）
├── core.nix
│   ├── core/shell.nix
│   ├── core/kitty.nix
│   ├── core/fastfetch.nix
│   ├── core/ui.nix
│   └── core/yazi.nix
├── development.nix
│   └── development/toolchain.nix
└── applications.nix
    ├── applications/knowledge.nix
    ├── applications/documents.nix
    ├── applications/media.nix
    ├── applications/web.nix
    ├── applications/transfer.nix
    ├── applications/communication.nix
    └── applications/flathub.nix
```

说明：

- `desktop`：桌面会话层（Noctalia + Niri）
- `core`：命令行与基础 UI 体验
- `development`：开发工具链
- `applications`：日常应用集合

---

## System 层次

`configuration.nix` 只保留三类导入：

1. `./hardware-configuration.nix`
2. `./host-local.nix`
3. `../../modules/system/system.nix`

```text
modules/system
├── system.nix
├── base.nix
├── users.nix
├── locale.nix
├── desktop.nix
├── graphics.nix
├── gaming.nix
├── packages.nix
└── graphics-intel.nix   （可选，Intel 机器按需启用）
```

---

## 硬件文件放置（非常重要）

`hardware-configuration.nix` 是**机器绑定文件**，应放在：

- `hosts/<hostname>/hardware-configuration.nix`

当前仓库示例：

- `hosts/nixos/hardware-configuration.nix`

迁移到新电脑时：

1. 在新机器生成硬件文件。
2. 放到 `hosts/<new-host>/hardware-configuration.nix`。
3. 新建 `hosts/<new-host>/configuration.nix` 与 `hosts/<new-host>/host-local.nix`。
4. 复用 `modules/system/*` 与 `modules/home/*` 通用层。

建议把主机差异（主机名、代理、端口、特殊内核参数）统一收敛到 `host-local.nix`。

---

## 重建命令

```bash
sudo nixos-rebuild switch --flake .#nixos
```

---
