{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Git with GUI
    github-desktop
    # Proxy tool
    clash-verge-rev
    # Explore Engine
    google-chrome
    # Download tool
    motrix
  ];
}
