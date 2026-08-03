{ pkgs, pkgs-unstable, ... }:

{

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

  eureka.software.home = [
    pkgs-unstable.zed-editor # Zed 编辑器（unstable）
    pkgs.github-desktop      # GitHub Desktop 图形客户端
  ];

  xdg.configFile = {
    "zed/settings.json".source = ../../config/zed-config/settings.json;
  };
}
