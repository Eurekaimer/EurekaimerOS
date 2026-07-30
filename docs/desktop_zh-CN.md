# 桌面与用户界面

用户桌面入口是 [`modules/home/desktop.nix`](../modules/home/desktop.nix)，当前启用 Niri 与 Noctalia；Rofi 和 Waybar 保留为可选模块，不会重复启动另一套面板或启动器。

## Niri 会话

+ [`desktop/niri.nix`](../modules/home/desktop/niri.nix)
  + 安装 Xwayland Satellite、音量与亮度工具、Hyprlock、图片查看器、音量控制和 KDE Polkit agent。
  + 安装 grim、slurp、wf-recorder、wl-clipboard，并创建 `~/Pictures/Screenshots`。
  + 生成 `niri-window-shot`：通过 Niri IPC 选择真实窗口 ID，再调用原生窗口截图，保留圆角、阴影和透明区域。
  + 将 [`config/niri-config/config.kdl`](../modules/home/config/niri-config/config.kdl) 映射到 `~/.config/niri/config.kdl`。
+ Niri 配置
  + 启动 Fcitx 5、Polkit agent、Xwayland Satellite、托盘代理和 Noctalia。
  + 管理输入、布局、动画、窗口规则和快捷键。
  + Chrome 画中画窗口自动浮动；Firefox 规则已移除。
  + 截图快捷键：`Print` 显示器、`Alt+Print` 当前窗口、`Mod+Alt+Print` 选择窗口、`Shift+Print` 区域。

上游：[Niri](https://niri-wm.github.io/niri/)、[Xwayland Satellite](https://github.com/Supreeeme/xwayland-satellite)。

## Noctalia

+ [`desktop/noctalia.nix`](../modules/home/desktop/noctalia.nix)
  + 导入 Noctalia Home Manager 模块并加载仓库内 JSON 设置。
+ [`config/noctalia-config/settings.json`](../modules/home/config/noctalia-config/settings.json)
  + 负责面板、通知、OSD、启动器和系统状态界面。
  + 默认界面字体显式设为 `LXGW WenKai Screen`；固定宽度内容保留系统 `monospace`。
  + 壁纸渲染已禁用，减少重复桌面合成；通知声音关闭。

上游：[Noctalia Shell](https://docs.noctalia.dev/)、[Quickshell](https://quickshell.org/)。

## GTK、图标和字体

+ [`core/ui.nix`](../modules/home/core/ui.nix)
  + GTK 2/3/4 默认字体为 LXGW WenKai Screen 11。
  + 使用 Papirus Dark 图标和 Bibata Modern Ice 光标。
  + 固定 XDG 用户目录为英文路径，避免应用因本地化目录名变化而失效。

上游：[GTK](https://www.gtk.org/)、[Papirus](https://github.com/PapirusDevelopmentTeam/papirus-icon-theme)、[Bibata Cursor](https://github.com/ful1e5/Bibata_Cursor)。

## 核心用户工具

+ [`modules/home/core.nix`](../modules/home/core.nix)
  + Shell：Zsh 辅助工具及常用命令。
  + Kitty：从仓库映射终端配置；终端继续使用 JetBrainsMono Nerd Font，保证代码列对齐和图标字形。
  + Fastfetch：映射展示配置。
  + Yazi：终端文件管理器。
  + Trash cleanup：声明用户级清理服务，集中处理回收站策略。

上游：[Kitty](https://sw.kovidgoyal.net/kitty/)、[Yazi](https://yazi-rs.github.io/)、[Fastfetch](https://github.com/fastfetch-cli/fastfetch)。

## 可选界面

+ [`desktop/rofi.nix`](../modules/home/desktop/rofi.nix)
  + 当前未从桌面入口导入；启用后使用 LXGW 字体和 Google Chrome 应用列表。
+ [`desktop/waybar.nix`](../modules/home/desktop/waybar.nix)
  + 当前未启用 Waybar 服务；样式保留 LXGW 文本与 Nerd Font 图标回退。
