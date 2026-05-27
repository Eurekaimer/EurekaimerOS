{ pkgs, ... }:

let
  texliveWriting = pkgs.texlive.combine {
    inherit (pkgs.texlive)
      scheme-small
      collection-latexrecommended
      collection-latexextra
      collection-fontsrecommended
      collection-xetex
      collection-langchinese
      collection-langenglish
      collection-langjapanese
      siunitx
      latexindent
      latexmk
      ;
  };
in
{
  home.packages = with pkgs; [
    texlab
    texliveWriting
  ];
}
