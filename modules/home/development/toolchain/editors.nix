{ pkgs, pkgs-unstable, ... }:

{
  programs.helix = {
    enable = true;
    package = pkgs-unstable.helix;
  };

  home.packages = [
    pkgs-unstable.vscode
    pkgs-unstable.zed-editor
    pkgs.github-desktop
  ];

  xdg.configFile = {
    "helix/config.toml".source = ../../config/helix-config/config.toml;
    "zed/settings.json".source = ../../config/zed-config/settings.json;
  };
}
