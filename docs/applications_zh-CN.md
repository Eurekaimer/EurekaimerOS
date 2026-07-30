# 应用软件

入口 [`modules/home/applications.nix`](../modules/home/applications.nix) 按用途拆分应用。这里列出仓库实际声明的软件及其官方项目地址；Nix 软件包版本由 flake 输入锁定。

## 浏览器与网络

+ [`applications/web.nix`](../modules/home/applications/web.nix)
  + [Google Chrome](https://www.google.com/chrome/) 是唯一声明安装的网页浏览器；Firefox 已从系统配置移除。
  + [Clash Verge Rev](https://github.com/clash-verge-rev/clash-verge-rev) 和 [Throne](https://github.com/throneproj/Throne) 提供代理图形界面。
  + [Sunshine](https://app.lizardbyte.dev/Sunshine/) 提供串流主机程序。
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
  + [Crow Translate](https://crow-translate.github.io/)：桌面翻译。

## 媒体

+ [`applications/media.nix`](../modules/home/applications/media.nix)
  + [OBS Studio](https://obsproject.com/) 使用 unstable 包，并加入 multi-RTMP、PipeWire 音频捕获和 VAAPI 插件。
  + [mpv](https://mpv.io/) 使用仓库内完整配置目录；同时安装 [FFmpeg](https://ffmpeg.org/) 与 MediaInfo。
  + [Spotify](https://www.spotify.com/)、[yt-dlp](https://github.com/yt-dlp/yt-dlp)、[MusicFox](https://github.com/go-musicfox/go-musicfox) 和 [Netease Cloud Music GTK](https://github.com/gmg137/netease-cloud-music-gtk) 提供音乐与媒体获取。
  + `trash-cli` 让脚本和终端删除操作进入回收站。

## 通信

+ [`applications/communication.nix`](../modules/home/applications/communication.nix)
  + [飞书](https://www.feishu.cn/)、[QQ](https://im.qq.com/)、[微信](https://weixin.qq.com/) 和 [Zoom](https://zoom.us/)。
  + 微信由 [`wechat-official.nix`](../modules/home/applications/wechat-official.nix) 封装官方 Linux 包及其运行库，而不是使用另一套非官方客户端。

## 下载与图片上传

+ [`applications/transfer.nix`](../modules/home/applications/transfer.nix)
  + [Motrix](https://motrix.app/)：多协议下载。
  + [qBittorrent](https://www.qbittorrent.org/)：BitTorrent。
  + [PicGo](https://github.com/Molunerfinn/PicGo)：图片上传。

## 默认应用

+ [`applications/mime-defaults.nix`](../modules/home/applications/mime-defaults.nix)
  + 集中生成通用和 KDE 的 MIME 默认项，避免两套桌面数据库指向不同应用。
  + 修改默认程序时应改此模块，而不是手动编辑 `~/.config/mimeapps.list`。
