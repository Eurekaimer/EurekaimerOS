{ pkgs, ... }:

{
  home.packages = with pkgs; [
    pdfarranger
    foliate
    readest
    sioyek
    crow-translate
  ];
}
