# Applications

[`modules/home/applications.nix`](../modules/home/applications.nix) groups applications by purpose. The links below identify the upstream projects; exact package revisions remain pinned by the flake.

## Komari Call

+ The `komari-call` flake input provides the terminal chat client. Starting `komari-call` always enters the TUI; a missing or invalid credential no longer blocks startup.
+ Inside the TUI, use `/login`, `/login deepseek`, or `/login opencode-go`. The key is masked, validated, and then stored in the system keyring.
+ To select the OpenCode Go subscription rather than DeepSeek before launch:

  ```bash
  komari-call config --provider opencode-go --model deepseek-v4-flash
  ```

+ `komari-call models --provider opencode-go` checks the saved Go credential and lists the models available to that subscription.

## Browser and networking

+ [`applications/web.nix`](../modules/home/applications/web.nix)
  + [Google Chrome](https://www.google.com/chrome/) and [Throne](https://github.com/throneproj/Throne) are the declared browsers.
  + [Clash Verge Rev](https://github.com/clash-verge-rev/clash-verge-rev) and [Throne](https://github.com/throneproj/Throne) provide proxy GUIs.
  + The generated `campus-login` command clears proxy variables and starts Chrome with an isolated temporary profile for campus authentication.
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
  + Change defaults in this module rather than manually editing `~/.config/mimeapps.list`.
