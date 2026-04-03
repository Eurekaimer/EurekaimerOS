{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # .epub
    foliate
    # .pdf and you can use it without mouse like vim
    sioyek
    # epub editor
    calibre
    # Simple and lightweight translator that allows to translate and speak text using Google
    crow-translate
  ];
}
