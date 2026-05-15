# EurekaimerOS

语言：中文 | [English (README.md)](README.md)

这是我的个人 NixOS 配置仓库，核心主线是 **Niri + Noctalia**：

![](https://cdn.jsdelivr.net/gh/Eurekaimer/MyIMGs@main/img/20260417160052566.png)

- **Niri**：负责窗口管理与日常操作流（当前主力桌面体验）。
- **Noctalia**：负责壳层交互体验（状态栏/控制中心这一类能力）。
- **Flake + Home Manager**：保证配置可声明、可复现、可迁移。

如果你也想搭一套“结构清晰、以 Niri/Noctalia 为中心”的 NixOS 配置，这个仓库就是按这个目标整理的。

## 问题与经验

### 安装恢复：镜像、代理、仓库

恢复顺序尽量简单：

1. Live ISO 和首次进入系统后，都先改 `/etc/nix/nix.conf`。
2. 先装出能启动、能联网的基础系统。
3. 先恢复代理，再登录 GitHub。
4. 拿到仓库后执行 `sudo nixos-rebuild switch --flake .#nixos`。

镜像配置：

```conf
substituters = https://mirrors.ustc.edu.cn/nix-channels/store https://cache.nixos.org/
```

改完重启 Nix daemon：

```bash
sudo systemctl restart nix-daemon
```

早期恢复代理优先用 `mihomo`、`throne` 或 `nekoray` 这类更直接的方案。`clash-verge-rev` 依赖 WebView，显卡、WebView、Wayland/X11 还没稳定时更容易卡在界面渲染上。

第一次拿仓库不必执着 `git clone`：浏览器下载 ZIP、解压、右键打开终端也可以。关键是最后在仓库目录执行 rebuild。

### 硬件文件和用户目录

`hardware-configuration.nix` 只能用本机生成的版本，不能照抄别人的：

- 磁盘分区
- 文件系统 UUID
- 引导盘和根分区挂载方式

这个仓库默认使用英文用户目录，例如 `~/Pictures` 和 `~/Pictures/Screenshots`。如果系统已经生成过 `~/图片`、`~/下载`、`~/文档` 这类中文目录，先把文件迁移到英文目录，避免脚本和截图路径失效。

### fcitx5、QQ 和 Qt 应用输入法

fcitx5 需要系统层、会话层、应用层都能拿到输入法环境变量。系统层在 `modules/system/locale.nix`：

```nix
i18n.inputMethod = {
  enable = true;
  type = "fcitx5";
  fcitx5.waylandFrontend = true;
};

environment.variables = {
  GTK_IM_MODULE = "fcitx";
  QT_IM_MODULE = "fcitx";
  SDL_IM_MODULE = "fcitx";
  GLFW_IM_MODULE = "fcitx";
  INPUT_METHOD = "fcitx";
  XMODIFIERS = "@im=fcitx";
};
```

Niri 会话里还要启动 fcitx5，并把环境同步给 systemd/dbus：

```kdl
spawn-at-startup "fcitx5" "-d"
spawn-at-startup "sh" "-c" "systemctl --user import-environment WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE GTK_IM_MODULE QT_IM_MODULE SDL_IM_MODULE GLFW_IM_MODULE INPUT_METHOD XMODIFIERS NIXOS_OZONE_WL; dbus-update-activation-environment --systemd WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE GTK_IM_MODULE QT_IM_MODULE SDL_IM_MODULE GLFW_IM_MODULE INPUT_METHOD XMODIFIERS NIXOS_OZONE_WL"
```

QQ、微信、会议软件这类 Qt/Electron 应用如果输入法或窗口异常，优先显式指定：

```bash
QT_IM_MODULE=fcitx
GTK_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
```

部分只在 X11 路径下稳定的 Qt 应用还需要：

```bash
QT_QPA_PLATFORM=xcb
```

`wechat-official.nix` 已经用 FHS wrapper 显式设置了这些变量；`qq` 当前直接来自 `nixpkgs-unstable`，如果后续输入法失效，再给 QQ 单独加 wrapper。

### Steam 黑屏和启动慢

在 Niri + `xwayland-satellite` 下，Steam 主窗口可能黑屏，启动也可能很慢。日志特征通常是：

- `steamwebhelper` / CEF WebUI
- `XDG_SESSION_TYPE=wayland`
- `Ozone platform: x11`
- `BadWindow (invalid Window parameter)`

当前修复在 `modules/system/gaming.nix`：

```nix
programs.steam = {
  enable = true;
  package = pkgs.steam.override {
    extraArgs = "-cef-disable-gpu-compositing";
  };
};
```

这个参数只关 CEF GPU compositing，比 `-cef-disable-gpu` 更轻。若复发，可临时换成 `-cef-disable-gpu` 验证是否仍是 Steam WebView 渲染问题。

Intel iGPU 主机同时启用 `graphics-intel.nix`：

```nix
../../modules/system/graphics-intel.nix
```

应用后重启 Steam：

```bash
sudo nixos-rebuild switch --flake .#nixos
pkill steam
steam
```

参考：

- [NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world/zh/)
- [Niri/xwayland-satellite: Black steam window fix - NixOS Discourse](https://discourse.nixos.org/t/niri-xwayland-satellite-black-steam-window-fix/77107)
- [Steam UI Black Unless Ran Using -cef-disable-gpu - ValveSoftware/steam-for-linux](https://github.com/ValveSoftware/steam-for-linux/issues/10561)

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

`modules/home/applications.nix` 也负责通过 Home Manager 的 `xdg.mimeApps` 管理桌面默认打开方式，这样文件关联不会散落在 Niri 或 Noctalia 的配置里。

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
│   ├── development/neovim.nix
│   └── development/toolchain.nix
└── applications.nix
    ├── applications/knowledge.nix
    ├── applications/documents.nix
    ├── applications/media.nix
    ├── applications/web.nix            （浏览器、Clash Verge、Throne）
    ├── applications/transfer.nix
    └── applications/communication.nix
```

说明：

- `desktop`：桌面会话层（Noctalia + Niri）
- `core`：命令行与基础 UI 体验
- `development`：开发工具链
- `applications`：日常应用集合

当前默认打开方式：

- PDF 使用 `sioyek`
- 常见图片格式使用 `imv`
- `mihomo` 作为系统级代理核心
- `throne` 作为恢复早期优先使用的代理 GUI，`clash-verge-rev` 保留给完整桌面环境
- 这些关联统一在 `modules/home/applications.nix` 里的 `xdg.mimeApps` 管理

---

## System 层次

`configuration.nix` 保持轻量，只负责串起主机入口和系统模块：

1. `./hardware-configuration.nix`
2. `./host-local.nix`
3. `./proxy-local.nix`
4. `../../modules/system/system.nix`
5. `../../modules/system/graphics-intel.nix`

```text
modules/system
├── system.nix
├── base.nix
├── users.nix
├── locale.nix
├── desktop.nix
├── graphics.nix
├── gaming.nix
├── packages.nix        （通用命令行工具、Firefox、mihomo）
└── graphics-intel.nix   （Intel 图形/媒体支持）
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
