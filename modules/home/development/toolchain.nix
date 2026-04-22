{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # IDE/editor
    code-cursor
    vscode
    github-desktop

    # Runtime/package toolchain
    uv
    nodejs_22
    pnpm

    # Scientific writing and analysis
    rWrapper
    rstudioWrapper
    texlive.combined.scheme-full
  ];

  home.sessionVariables = {
    UV_PYTHON = "/run/current-system/sw/bin/python3";
    UV_PYTHON_PREFERENCE = "only-system";
  };

}
