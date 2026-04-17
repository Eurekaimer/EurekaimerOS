{ pkgs, ... }:

{
  home.packages = with pkgs; [
    obsidian
    zotero
  ];
}
