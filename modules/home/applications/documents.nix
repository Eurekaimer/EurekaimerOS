{ pkgs, ... }:

{
  home.packages = with pkgs; [
    pdfarranger
    foliate
    sioyek
    crow-translate
  ];
}
