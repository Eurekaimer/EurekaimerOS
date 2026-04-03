{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Famous AI IDE
    code-cursor
    # Modern packages management tool by rust
    uv
    python3
    # R language and its IDE
    rWrapper
    rstudioWrapper
    # LaTeX environment
    texlive.combined.scheme-full
    # TOP 1 IDE
    vscode-fhs
  ];
}
