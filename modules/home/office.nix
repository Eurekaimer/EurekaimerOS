{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # An open source tool that arrange the PDF doc
    pdfarranger
    # My favourite note software
    obsidian
    # A paper manage tool
    zotero
  ];
}
