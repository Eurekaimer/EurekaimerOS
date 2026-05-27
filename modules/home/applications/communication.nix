{ pkgs-unstable, ... }:

let
  wechat = pkgs-unstable.callPackage ./wechat-official.nix { };
in
{
  home.packages = [
    pkgs-unstable.feishu
    pkgs-unstable.qq
    wechat
    pkgs-unstable.wemeet
  ];
}
