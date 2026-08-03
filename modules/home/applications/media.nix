{ pkgs, pkgs-unstable, ... }:

{
  eureka.software.home = [
    # OBS Studio（unstable，带多路推流/音频捕获/VAAPI 插件）
    (pkgs-unstable.wrapOBS {
      plugins = with pkgs-unstable.obs-studio-plugins; [
        obs-multi-rtmp
        obs-pipewire-audio-capture
        obs-vaapi
      ];
    })
    pkgs-unstable.mpv                 # 视频播放器（unstable，配置见 config/mpv-config）
    pkgs.ffmpeg                       # 音视频转码工具
    pkgs.mediainfo                    # 媒体文件信息查看
    pkgs.trash-cli                    # 命令行回收站（trash-put）
    pkgs.yt-dlp                       # YouTube/视频下载
  ];

  xdg.configFile."mpv" = {
    source = ../config/mpv-config;
    recursive = true;
  };
}
