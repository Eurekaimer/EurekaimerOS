{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # IDE/editor
    code-cursor
    vscode
    github-desktop

    # Runtime/package toolchain
    uv
    python3
    nodejs_22
    pnpm

    # Scientific writing and analysis
    rWrapper
    rstudioWrapper
    texlive.combined.scheme-full
  ];
}
