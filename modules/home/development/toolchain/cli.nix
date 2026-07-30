{ pkgs, ... }:

{
  home.packages = with pkgs; [
    fd
    ripgrep
    sqlite
  ];
}
