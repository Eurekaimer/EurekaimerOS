{ pkgs, ... }:

{
  home.packages = with pkgs; [
    google-chrome
    clash-verge-rev
  ];
}
