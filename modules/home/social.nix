{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Byte Dancer/NKUer must have
    feishu
    # Basic social software
    qq
    # Wemeet not support very well and you had better not use it
    wemeet
    # Basic social software
    wechat-uos
    # All-in-one cross-platform voice and text chat for gamers.
    discord
  ];
}
