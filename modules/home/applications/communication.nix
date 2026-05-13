{ pkgs, inputs, ... }:

let
  unstable = import inputs.nixpkgs-unstable {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnfree = true;
  };

  wechat = unstable.callPackage ./wechat-official.nix { };
in
{
  home.packages = [
    unstable.feishu
    unstable.qq
    wechat
    unstable.wemeet
  ];
}
