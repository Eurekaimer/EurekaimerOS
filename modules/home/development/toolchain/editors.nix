{ pkgs, pkgs-unstable, ... }:

{
  programs.helix = {
    enable = true;
    package = pkgs-unstable.helix;
  };

  programs.vscode = {
    enable = true;
    package = pkgs-unstable.vscode;
    profiles.default.extensions = with pkgs-unstable.vscode-extensions; [
      llvm-vs-code-extensions.vscode-clangd
      ms-vscode.cmake-tools
      vadimcn.vscode-lldb
      vscjava.vscode-java-pack
    ];
  };

  home.packages = [
    pkgs-unstable.zed-editor
    pkgs.github-desktop
  ];

  xdg.configFile = {
    "helix/config.toml".source = ../../config/helix-config/config.toml;
    "zed/settings.json".source = ../../config/zed-config/settings.json;
  };
}
