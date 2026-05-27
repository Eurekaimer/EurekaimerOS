# EurekaimerOS

语言：中文 | [English](README.md)

这是我的个人 NixOS 配置，核心是 **Niri**、**Noctalia**、**Home Manager** 和 **flakes**。

![](https://cdn.jsdelivr.net/gh/Eurekaimer/MyIMGs@main/img/20260417160052566.png)

## 特点

- 基于 Niri 的 Wayland 桌面工作流
- Noctalia 壳层组件
- 声明式系统和用户环境
- 可复用模块与主机专属配置分离

## 恢复要点

重装或恢复时，先让 Nix 下载走镜像，再装基础系统。这样可以避免把初始安装绑定到代理 GUI、浏览器登录或完整桌面渲染环境上。

在 Live ISO 里先处理 `/etc/nix/nix.conf`。直接按“可能是只读或受管链接”的情况处理，复制粘贴下面这一段即可：

```bash
sudo cp -L /etc/nix/nix.conf /etc/nix/nix.conf.bak
sudo rm /etc/nix/nix.conf
sudo tee /etc/nix/nix.conf >/dev/null <<'EOF'
experimental-features = nix-command flakes
substituters = https://mirrors.ustc.edu.cn/nix-channels/store https://cache.nixos.org/
EOF
```

然后重启 Nix daemon：

```bash
sudo systemctl restart nix-daemon
```

接下来先用图形安装器或常规安装流程装出一个能启动、能联网的基础系统。第一次进入新系统后，再重复上面的 `/etc/nix/nix.conf` 镜像设置。

早期恢复网络时，优先使用 `throne` 或 `nekoray` 这类轻量代理客户端；如果只需要核心转发，也可以直接用 `mihomo`。等代理、浏览器和 GitHub 访问都恢复后，再获取这个仓库。第一次恢复不必执着 `git clone`，浏览器下载 ZIP、解压、在仓库目录打开终端也可以。

拿到仓库后执行：

```bash
sudo nixos-rebuild switch --flake .#nixos
```

当前系统配置在 `modules/system/base.nix` 中优先使用国内镜像。如果某个镜像缺对象或不稳定，可以临时换源后再 rebuild。

## 结构

```text
flake.nix
├── inputs
│   ├── nixpkgs              稳定系统包集
│   ├── nixpkgs-unstable     供少量快速更新软件使用
│   ├── home-manager
│   └── noctalia             跟随 nixpkgs-unstable
├── pkgs-unstable            只在这里 import 一次，并传给各模块
└── nixosConfigurations.nixos
    ├── hosts/nixos/configuration.nix
    │   ├── hardware-configuration.nix
    │   ├── host-local.nix
    │   ├── proxy-local.nix
    │   ├── ../../modules/system/system.nix
    │   └── ../../modules/system/graphics-intel.nix
    └── home-manager.users.eurekaimer
        └── home/eurekaimer/home.nix
            ├── ../../modules/home/desktop.nix
            ├── ../../modules/home/core.nix
            ├── ../../modules/home/development.nix
            └── ../../modules/home/applications.nix
```

主要入口：

- `flake.nix`
- `hosts/nixos/configuration.nix`
- `home/eurekaimer/home.nix`
- `modules/home/development/toolchain.nix`
- `home-layer-map.txt`
- `system-layer-map.txt`

`nixpkgs-unstable` 的统一设置位置是 `flake.nix`。这里把它 import 为
`pkgs-unstable`，并同时传给 NixOS modules 与 Home Manager modules。需要使用
unstable 软件包的模块，只接收 `pkgs-unstable` 参数并在本模块标注用途；不要在
模块里再次 `import inputs.nixpkgs-unstable`。

## 重建

```bash
sudo nixos-rebuild switch --flake .#nixos
```

## R 和 Notebook

R 通过 Nix wrapper 提供。开发工具链包含 R Markdown、常用统计包、绘图包、Jupyter，以及声明式生成的 `R (Nix)` kernel。

重建后可以检查：

```bash
jupyter kernelspec list
```

列表里应该包含 `r-nix`。

## 排障记录

- `hardware-configuration.nix` 绑定具体机器，迁移时应重新生成。
- 新机器上可能需要调整 host-local 和代理相关配置。
- 早期恢复网络时，优先用 `throne`、`nekoray` 或 `mihomo`；`clash-verge-rev` 依赖 WebView，更适合完整桌面环境稳定后再用。
- 当前 nixpkgs 中 `httpgd` 被标记为 broken，因此暂不启用。

### Steam 黑屏

在 Niri + `xwayland-satellite` 下，Steam 主窗口可能黑屏或启动很慢。日志里常见线索包括：

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

这个参数只关闭 CEF 的 GPU compositing，比直接 `-cef-disable-gpu` 更轻。若问题复发，可以临时把参数换成 `-cef-disable-gpu` 验证是否仍是 Steam WebView 渲染问题。

参考：

- [Niri/xwayland-satellite: Black steam window fix - NixOS Discourse](https://discourse.nixos.org/t/niri-xwayland-satellite-black-steam-window-fix/77107)
- [Steam UI Black Unless Ran Using -cef-disable-gpu - ValveSoftware/steam-for-linux](https://github.com/ValveSoftware/steam-for-linux/issues/10561)

## 备注

- 新主机应新建独立的 `hosts/<name>/` 入口，不要盲目复用机器绑定文件。
