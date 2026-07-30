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

+ 本次字体、浏览器与电源修改已完成完整 toplevel 构建。构建输出中不再包含 Firefox desktop 文件，生成的 TLP 配置包含电池 CPU 5%–50% 和电池模式禁用蓝牙。

## 修改位置速查

+ 字体、中文和输入法：[`modules/system/locale.nix`](../modules/system/locale.nix)
+ 登录界面和系统桌面服务：[`modules/system/desktop.nix`](../modules/system/desktop.nix)
+ GTK 字体与图标：[`modules/home/core/ui.nix`](../modules/home/core/ui.nix)
+ Niri：[`modules/home/config/niri-config/config.kdl`](../modules/home/config/niri-config/config.kdl)
+ Noctalia：[`modules/home/config/noctalia-config/settings.json`](../modules/home/config/noctalia-config/settings.json)
+ 应用：[`modules/home/applications/`](../modules/home/applications/)
+ 电源：[`modules/system/power.nix`](../modules/system/power.nix)

## 电源诊断

+ 查看 TLP 状态：`sudo tlp-stat -s -p -b`
+ 采样耗电：`sudo powertop --time=10 --csv=/tmp/powertop.csv`
+ 先检查应用唤醒、显示亮度、代理和浏览器标签页，再考虑更激进的内核参数。
+ 当前机器电池满充容量约为设计容量的 85%；这是可用续航下降的一部分，不能仅靠调度配置恢复。

## 恢复与迁移

+ Live ISO 或首次启动时，先配置可用二进制缓存和网络，再应用完整 flake。
+ 新机器必须重新生成 `hardware-configuration.nix`，并核对磁盘 UUID、Intel 图形模块、代理和用户名。
+ `system.stateVersion` 与 `home.stateVersion` 表示兼容基线，不应因为升级 nixpkgs 就随意修改。
+ 若 `mem_sleep_default=deep` 导致恢复失败，在 [`power.nix`](../modules/system/power.nix) 中移除该参数后重新构建。

## 与 EurekaimerOS 同步

`/etc/nixos` 是运行中配置，`/home/eurekaimer/Documents/GitHub/EurekaimerOS` 是长期维护仓库。每次完成并验证修改后，将配置同步到仓库；同步时保留目标仓库的 `.git`、LICENSE 和仓库专属文件，不使用会删除目标额外文件的镜像参数。
