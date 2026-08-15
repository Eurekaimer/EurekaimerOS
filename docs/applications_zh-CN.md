# 应用软件

入口 [`modules/home/applications.nix`](../modules/home/applications.nix) 按用途拆分应用。这里列出仓库实际声明的软件及其官方项目地址；Nix 软件包版本由 flake 输入锁定。

## Komari Call

+ flake 输入 `komari-call` 提供终端聊天程序。直接运行 `komari-call` 一定会先进入 TUI；缺少或已有错误的 API Key 都不会再阻止界面启动。
+ 在 TUI 内输入 `/login`、`/login deepseek` 或 `/login opencode-go`。Key 会以圆点隐藏，验证成功后写入系统 Keyring。
+ 若要使用 OpenCode Go 套餐而不是 DeepSeek，启动前执行：

  ```bash
  komari-call config --provider opencode-go --model deepseek-v4-flash
  ```

+ `komari-call models --provider opencode-go` 会检查保存的 Go 凭据并列出套餐当前可用模型。

## 浏览器与网络

+ [`applications/web.nix`](../modules/home/applications/web.nix)
  + [Google Chrome](https://www.google.com/chrome/) 与 [Throne](https://github.com/throneproj/Throne) 是声明的浏览器。
  + [Clash Verge Rev](https://github.com/clash-verge-rev/clash-verge-rev) 和 [Throne](https://github.com/throneproj/Throne) 提供代理图形界面。
  + `campus-login` 生成隔离的临时 Chrome profile，清空代理环境并直连校园认证页，不污染日常浏览器 profile。
+ 后台耗电
  + Powertop 实测活动 Chrome renderer 与 Clash Verge 是较高唤醒来源。只保留一个代理核心、关闭闲置标签页，比同时常驻多个代理 GUI 更省电。

## 知识与文档

+ [`applications/knowledge.nix`](../modules/home/applications/knowledge.nix)
  + [Obsidian](https://obsidian.md/)：Markdown 知识库。
  + [Zotero](https://www.zotero.org/)：文献管理。
+ [`applications/documents.nix`](../modules/home/applications/documents.nix)
  + [PDF Arranger](https://github.com/pdfarranger/pdfarranger)：PDF 页面整理。
  + [Foliate](https://johnfactotum.github.io/foliate/) 与 [Readest](https://readest.com/)：电子书阅读。
  + [Sioyek](https://sioyek.info/)：PDF 阅读与研究导航。

## 媒体

+ [`applications/media.nix`](../modules/home/applications/media.nix)
  + [OBS Studio](https://obsproject.com/) 使用 unstable 包，并加入 multi-RTMP、PipeWire 音频捕获和 VAAPI 插件。
  + [mpv](https://mpv.io/) 使用仓库内完整配置目录；同时安装 [FFmpeg](https://ffmpeg.org/) 与 MediaInfo。
  + [yt-dlp](https://github.com/yt-dlp/yt-dlp) 负责媒体获取。
  + `trash-cli` 让脚本和终端删除操作进入回收站。

## 通信

+ [`applications/communication.nix`](../modules/home/applications/communication.nix)
  + [飞书](https://www.feishu.cn/)、[QQ](https://im.qq.com/)、[微信](https://weixin.qq.com/) 和 [Zoom](https://zoom.us/)。
  + 微信由 [`wechat-official.nix`](../modules/home/applications/wechat-official.nix) 封装官方 Linux 包及其运行库，而不是使用另一套非官方客户端。

## 下载与图片上传

+ [`applications/transfer.nix`](../modules/home/applications/transfer.nix)
  + [qBittorrent](https://www.qbittorrent.org/)：BitTorrent。
  + [PicGo](https://github.com/Molunerfinn/PicGo)：图片上传。

## 默认应用

+ [`applications/mime-defaults.nix`](../modules/home/applications/mime-defaults.nix)
  + 集中生成通用的 MIME 默认项，避免桌面数据库指向不同应用。
  + 修改默认程序时应改此模块，而不是手动编辑 `~/.config/mimeapps.list`。
