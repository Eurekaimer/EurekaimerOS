# 构建和维护

## 常规验证

+ 只构建、不切换当前系统：

```bash
nix build .#nixosConfigurations.nixos.config.system.build.toplevel --no-link
```

+ 构建并切换：

```bash
sudo nixos-rebuild switch --flake .#nixos
```

+ 已完成完整 toplevel 构建与实机切换，并验证自适应控制器、受 systemd 管理的 Noctalia/swayidle、恢复用 swap 和按电池余量休眠的配置。
+ 校验 flake 与源码卫生：`nix flake check`。

## 部署

[`scripts/`](../scripts/) 工具集统一先暂存新文件，再原子替换目标目录并保留带时间戳的备份：

+ `./scripts/deploy-full.sh` — 新机器首次部署：重新生成 `hardware-configuration.nix`，并把 `host-local.nix`、`proxy-local.nix`、`hardware-extra.nix` 换成可移植默认值（`host-generic.nix`、`proxy-disabled.nix`、`hardware-extra-generic.nix`）；检测到 Intel iGPU 时恢复 Intel 图形模块。
+ `./scripts/deploy-preserve-hardware.sh` — 本机重装：保留目标机的硬件与主机文件。
+ `./scripts/deploy-desktop.sh` / `deploy-power.sh` / `deploy-software.sh` — 局部更新：只推送单一区域到已有的 `/etc/nixos`，被替换项备份到带时间戳的 `.partial-backup-*` 目录。
+ 环境变量 `EUREKAIMEROS_TARGET=/path` 可覆盖部署目标（默认 `/etc/nixos`）。

任何部署脚本执行后，统一用 `sudo nixos-rebuild switch --flake /etc/nixos#nixos` 激活。

### 新机器 checklist

1. 安装 NixOS 并创建用户 `eurekaimer` —— `users.nix` 与 `home.nix` 固定该用户名。
2. 克隆仓库并运行 `./scripts/deploy-full.sh`。
3. 人工核对机器专属值：`power.nix` 中的恢复 swap UUID、`mounts.nix` 的 NTFS UUID、`host-local.nix` 的 USB quirks。
4. 代理默认禁用（`proxy-disabled.nix`）；配置好 127.0.0.1:7897 的代理后再启用 `proxy-local.nix` 与 Docker 代理。
5. 用 `sudo nixos-rebuild switch --flake /etc/nixos#nixos` 切换。二进制缓存（中科大/清华/官方）已在 `base.nix` 预配置。

## 修改位置速查

+ 字体、中文和输入法：[`modules/system/locale.nix`](../modules/system/locale.nix)
+ 登录界面和系统桌面服务：[`modules/system/desktop.nix`](../modules/system/desktop.nix)
+ GTK 字体与图标：[`modules/home/core/ui.nix`](../modules/home/core/ui.nix)
+ Niri：[`modules/home/config/niri-config/config.kdl.in`](../modules/home/config/niri-config/config.kdl.in)
+ Noctalia：[`modules/home/config/noctalia-config/settings.json.in`](../modules/home/config/noctalia-config/settings.json.in)
+ 应用：[`modules/home/applications/`](../modules/home/applications/)
+ 电源：[`modules/system/power.nix`](../modules/system/power.nix)

## 电源诊断

+ 查看控制器：`cat /run/power-policy/status.json`
+ 查看 TLP：`sudo tlp-stat -s -p -b`
+ 查看受管理的桌面服务：`systemctl --user status swayidle noctalia-shell`
+ 采样耗电：`sudo powertop --time=10 --csv=/tmp/powertop.csv`；先检查应用唤醒、显示亮度、代理和浏览器标签页，再考虑内核调优。
+ 当前电池满充容量约为设计容量的 86.5%；调度可以降低功耗，但不能恢复这部分物理损耗。

## 恢复与迁移

+ Live ISO 或首次启动时，先配置可用二进制缓存和网络，再应用完整 flake。
+ 新机器必须重新生成 `hardware-configuration.nix`，并核对磁盘 UUID、Intel 图形模块、代理和用户名。
+ 部署脚本只替换可移植文件；机器专属值——`power.nix` 的恢复 swap UUID、`mounts.nix` 的 NTFS UUID、`users.nix`/`home.nix` 的用户名——不会被触碰，新机器上必须人工核对。
+ `system.stateVersion` 与 `home.stateVersion` 表示兼容基线，不应因为升级 nixpkgs 就随意修改。
+ 若 `mem_sleep_default=deep` 导致恢复失败，在 [`power.nix`](../modules/system/power.nix) 中移除该参数后重新构建。

## 与 EurekaimerOS 同步

`/etc/nixos` 是运行中配置，`/home/eurekaimer/Documents/GitHub/EurekaimerOS` 是长期维护的仓库副本。每次完成并验证修改后，将配置同步到仓库；同步时保留目标仓库的 `.git`、LICENSE 和仓库专属文件，不使用会删除目标额外文件的镜像参数。

部署的方向是 仓库→`/etc/nixos`，同步的方向是 `/etc/nixos`→仓库，两者互补。
