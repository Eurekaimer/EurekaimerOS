# 系统层配置

系统层入口是 [`modules/system/system.nix`](../modules/system/system.nix)。它按职责导入以下模块。

## 基础系统

+ [`base.nix`](../modules/system/base.nix)
  + 启用 flakes、`nix-command`、商用软件许可和 `nix-ld`。
  + 使用中科大、清华和官方二进制缓存；每次 rebuild 时检查 generation 数量，达到 10 个即删除最旧的并立即回收 store 空间（不使用每周定时 GC），同时启用 store 自动优化。
  + 使用 systemd-boot、NetworkManager、上海时区和 NixOS `25.11` 状态版本。
+ [`users.nix`](../modules/system/users.nix)
  + 声明日常用户及其 shell、管理员和虚拟化相关用户组。
+ [`packages.nix`](../modules/system/packages.nix)
  + 聚合基础 CLI、网络、监控、归档和 DOS 工具。
  + 浏览器不在系统层安装；Google Chrome 由 Home Manager 管理。

## 中文环境与字体

+ [`locale.nix`](../modules/system/locale.nix)
  + 默认区域为 `zh_CN.UTF-8`，同时保留 `en_US.UTF-8`。
  + 使用 [Fcitx 5](https://fcitx-im.org/wiki/Fcitx_5) 及 Rime、Mozc、GTK/Qt 前端，并导出 Wayland 应用所需输入法环境变量。
  + 安装 LXGW WenKai Screen、Noto CJK、文泉驿、Sarasa、JetBrains Mono Nerd Font 和 Noto Color Emoji。
  + `LXGW WenKai Screen` 是 sans-serif、serif、常见中文 Windows 字体别名和 Noto Sans 的首选，覆盖中英文界面。
  + Kitty 终端使用 `LXGW WenKai Screen`；JetBrains Mono/Sarasa Mono 保留为代码与字形回退。
+ [`desktop.nix`](../modules/system/desktop.nix)
  + ReGreet 登录界面显式使用 LXGW，确保登录前也有一致的中文显示。

## 桌面服务和音频

+ [`desktop.nix`](../modules/system/desktop.nix)
  + 启用 Niri、greetd/ReGreet、Labwc 登录承载环境、GVfs、UDisks2、打印、PipeWire、蓝牙和 UPower。
  + 不安装 KDE/Plasma 组件，Niri 是唯一的桌面会话。
  + PipeWire 同时启用 ALSA、32 位 ALSA 和 PulseAudio 兼容层。
  + UDisks 的 NTFS 参数拒绝对脏卷强制挂载，优先要求在 Windows 中修复文件系统。

## 图形

+ [`graphics.nix`](../modules/system/graphics.nix)
  + 启用 NixOS 图形栈并安装 `libva-utils` 便于验证硬件解码。
+ [`graphics-intel.nix`](../modules/system/graphics-intel.nix)
  + 仅由当前 Intel iGPU 主机导入，安装 Intel Media Driver、旧 Intel VAAPI 驱动和 libva。

## 电源管理

+ [`power.nix`](../modules/system/power.nix)
  + 由 [TLP](https://linrunner.de/tlp/) 单独管理平台电源策略，强制关闭会与它争用的 power-profiles-daemon。
  + 根据当前满充能量计算 6 小时功耗预算，每分钟采样一次，并用 30% 新样本 + 70% 历史值的 EWMA 平滑；Intel HWP 上限采用乘法反馈收敛。
  + 容量节点分为四档：90% 以上为 `30%–75%` 与 `balance_power` EPP，50%–90% 为 `20%–60%`，20%–50% 为 `15%–45%`，20% 及以下为 `10%–30%`；后三档使用 `power` EPP。
  + 所有电池档位都使用 `powersave` governor、low-power 平台档位，并关闭 Turbo/HWP dynamic boost。
  + 电池模式启用 PCIe ASPM、设备 runtime PM、AHCI runtime PM、Wi-Fi 节能、声卡节能和 USB autosuspend。
  + 蓝牙不会再被 TLP 在开机或切换到电池供电时软阻塞，Noctalia 可正常控制开关。
  + Noctalia 使用同一套平滑保守估算：`剩余能量 / max(实测功率, 目标功率)`，因此显示值不会超过按当前电量折算的 6 小时目标。
  + 首选 `deep` suspend，声明恢复用 swap，并使用 systemd 按电池余量自适应的 suspend-then-hibernate；合盖时电池供电使用该策略，交流电使用普通 suspend。
  + 安装 `powertop` 与 `s-tui` 作为诊断工具，不运行常驻自动调优服务。

实时状态写入 `/run/power-policy/status.json`。若浏览器或代理界面 renderer 持续高负载，即使 CPU 已到当前档位下限，实测续航仍会低于目标；控制器会如实显示该差距，也不会把电池损耗伪装成可由软件恢复。

## 存储

+ [`mounts.nix`](../modules/system/mounts.nix)
  + 按 UUID 声明 `/mnt/Rina` 与 `/mnt/Eureka` 两个 NTFS3 数据卷。
  + 使用 systemd automount、`nofail` 和 5 分钟空闲卸载，不阻塞系统启动。
  + UUID、UID/GID 和 `force` 选项都与当前主机强绑定；迁移前必须核对，脏 NTFS 卷应优先在 Windows 中运行 `chkdsk`。

## 游戏和虚拟化

+ [`gaming.nix`](../modules/system/gaming.nix)
  + 配置 [Steam](https://store.steampowered.com/about/)、[GameMode](https://github.com/FeralInteractive/gamemode)、MangoHud 和 Wine。
  + Steam 使用 CEF GPU compositing 兼容参数处理 Niri/Xwayland 黑屏。
+ [`virtualisation.nix`](../modules/system/virtualisation.nix)
  + 启用 Docker/Compose，并为镜像拉取配置本机代理。
  + 同时启用 [libvirt](https://libvirt.org/)、[virt-manager](https://virt-manager.org/)、QEMU、swtpm、SPICE USB 重定向和 Windows virtio 驱动；显式关闭当前工作流不需要的 `virtchd`。

## 主机专属文件

+ [`hosts/nixos/hardware-configuration.nix`](../hosts/nixos/hardware-configuration.nix)
  + 来自 `nixos-generate-config`，换机器时重新生成。
+ [`hosts/nixos/host-local.nix`](../hosts/nixos/host-local.nix)
  + 保存当前机器本地参数。
+ [`hosts/nixos/proxy-local.nix`](../hosts/nixos/proxy-local.nix)
  + 保存日常网络代理入口；恢复系统时应先确保基本网络可用，再应用完整配置。
