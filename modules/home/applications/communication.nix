{ pkgs, inputs, ... }:

let
  unstable = import inputs.nixpkgs-unstable {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnfree = true;
  };
in
{
  home.packages = [
    unstable.feishu
    unstable.qq
    unstable.wemeet
    pkgs.discord
  ];
}
