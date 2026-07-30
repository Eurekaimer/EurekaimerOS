# Applications

[`modules/home/applications.nix`](../modules/home/applications.nix) groups applications by purpose. The links below identify the upstream projects; exact package revisions remain pinned by the flake.

## Browser and networking

+ [`applications/web.nix`](../modules/home/applications/web.nix)
  + [Google Chrome](https://www.google.com/chrome/) is the only declared web browser; Firefox has been removed from the system configuration.
  + [Clash Verge Rev](https://github.com/clash-verge-rev/clash-verge-rev) and [Throne](https://github.com/throneproj/Throne) provide proxy GUIs.
  + [Sunshine](https://app.lizardbyte.dev/Sunshine/) provides game/desktop streaming.
  + The generated `campus-login` command clears proxy variables and starts Chrome with an isolated temporary profile for campus authentication.
+ Power note
  + Powertop identified active Chrome renderers and Clash Verge among the largest wakeup sources during the sample. Closing idle tabs and running one proxy core is more useful than stacking extra kernel tunables.

## Knowledge and documents

+ [`applications/knowledge.nix`](../modules/home/applications/knowledge.nix)
  + [Obsidian](https://obsidian.md/) for Markdown knowledge bases.
  + [Zotero](https://www.zotero.org/) for reference management.
+ [`applications/documents.nix`](../modules/home/applications/documents.nix)
  + [PDF Arranger](https://github.com/pdfarranger/pdfarranger), [Foliate](https://johnfactotum.github.io/foliate/), [Readest](https://readest.com/), [Sioyek](https://sioyek.info/), and [Crow Translate](https://crow-translate.github.io/).

## Media

+ [`applications/media.nix`](../modules/home/applications/media.nix)
  + [OBS Studio](https://obsproject.com/) from unstable with multi-RTMP, PipeWire audio capture, and VAAPI plugins.
  + [mpv](https://mpv.io/) with the repository-owned configuration, plus [FFmpeg](https://ffmpeg.org/) and MediaInfo.
  + [Spotify](https://www.spotify.com/), [yt-dlp](https://github.com/yt-dlp/yt-dlp), [MusicFox](https://github.com/go-musicfox/go-musicfox), and [Netease Cloud Music GTK](https://github.com/gmg137/netease-cloud-music-gtk).
  + `trash-cli` keeps command-line deletions recoverable.

## Communication

+ [`applications/communication.nix`](../modules/home/applications/communication.nix)
  + [Feishu](https://www.feishu.cn/), [QQ](https://im.qq.com/), [WeChat](https://weixin.qq.com/), and [Zoom](https://zoom.us/).
  + [`wechat-official.nix`](../modules/home/applications/wechat-official.nix) wraps the official Linux package and its runtime libraries.

## Transfers

+ [`applications/transfer.nix`](../modules/home/applications/transfer.nix)
  + [Motrix](https://motrix.app/), [qBittorrent](https://www.qbittorrent.org/), and [PicGo](https://github.com/Molunerfinn/PicGo).

## Default applications

+ [`applications/mime-defaults.nix`](../modules/home/applications/mime-defaults.nix)
  + Generates both generic and KDE MIME defaults so desktop databases do not disagree.
  + Change defaults in this module rather than manually editing `~/.config/mimeapps.list`.
