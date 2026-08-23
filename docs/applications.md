# Applications

[`modules/home/applications.nix`](../modules/home/applications.nix) groups applications by purpose. The links below identify the upstream projects; exact package revisions remain pinned by the flake.

> Lexigraph, Komari Call, campus-login, and docker-ass now live under [Personal modules](personal.md). This page documents reusable application categories only.

## Browser and networking

+ [`applications/web.nix`](../modules/home/applications/web.nix)
  + [Google Chrome](https://www.google.com/chrome/) and [Throne](https://github.com/throneproj/Throne) are the declared browsers.
  + [Clash Verge Rev](https://github.com/clash-verge-rev/clash-verge-rev) and [Throne](https://github.com/throneproj/Throne) provide proxy GUIs.
+ Power note
  + Powertop identified active Chrome renderers and Clash Verge among the largest wakeup sources during the sample. Closing idle tabs and running one proxy core is more useful than stacking extra kernel tunables.

## Knowledge and documents

+ [`applications/knowledge.nix`](../modules/home/applications/knowledge.nix)
  + [Obsidian](https://obsidian.md/) for Markdown knowledge bases.
  + [Zotero](https://www.zotero.org/) for reference management.
+ [`applications/documents.nix`](../modules/home/applications/documents.nix)
  + [PDF Arranger](https://github.com/pdfarranger/pdfarranger), [Foliate](https://johnfactotum.github.io/foliate/), [Readest](https://readest.com/), and [Sioyek](https://sioyek.info/).

## File manager

+ [`applications/file-manager.nix`](../modules/home/applications/file-manager.nix)
  + [PCManFM](https://wiki.lxde.org/en/PCManFM) as the lightweight GTK3 file manager; terminal-side browsing stays with Yazi.

## Media

+ [`applications/media.nix`](../modules/home/applications/media.nix)
  + [OBS Studio](https://obsproject.com/) from unstable with multi-RTMP, PipeWire audio capture, and VAAPI plugins.
  + [mpv](https://mpv.io/) from unstable with the repository-owned configuration, plus [FFmpeg](https://ffmpeg.org/) and MediaInfo.
  + [yt-dlp](https://github.com/yt-dlp/yt-dlp) for media acquisition.
  + `trash-cli` keeps command-line deletions recoverable.

## Communication

+ [`applications/communication.nix`](../modules/home/applications/communication.nix)
  + [Feishu](https://www.feishu.cn/), [QQ](https://im.qq.com/), [WeChat](https://weixin.qq.com/), and [Zoom](https://zoom.us/).
  + [`wechat-official.nix`](../modules/home/applications/wechat-official.nix) wraps the official Linux package and its runtime libraries.

## Transfers

+ [`applications/transfer.nix`](../modules/home/applications/transfer.nix)
  + [qBittorrent](https://www.qbittorrent.org/) and [PicGo](https://github.com/Molunerfinn/PicGo).

## Default applications

+ [`applications/mime-defaults.nix`](../modules/home/applications/mime-defaults.nix)
  + Generates generic MIME defaults so desktop databases do not disagree.
  + Disabling documents removes Sioyek/Foliate handlers; the Niri-provided imv image handler remains valid.
  + Change defaults in this module rather than manually editing `~/.config/mimeapps.list`.

Every application category is independently selectable; see [Software selection](software-selection.md) for the complete mapping.
