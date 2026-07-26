{ pkgs, ... }:

{
  home.packages = with pkgs; [
    pdfarranger
    foliate
    sioyek
    calibre
    crow-translate
  ];
}
