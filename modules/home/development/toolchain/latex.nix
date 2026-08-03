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
      algorithms
      algorithmicx
      siunitx
      latexindent
      latexmk
      ;
  };
in
{
  eureka.software.home = with pkgs; [
    texlab          # LaTeX 语言服务器
    texliveWriting  # TeX Live 组合（中英日文 + xetex + latexmk，见上方 let）
  ];
}
