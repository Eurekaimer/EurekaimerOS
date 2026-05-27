{ pkgs, pkgs-unstable, ... }:

{
  home.packages = [
    pkgs-unstable.vscode
    pkgs.github-desktop
  ];
}
