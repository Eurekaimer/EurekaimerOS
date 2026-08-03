{ pkgs, ... }:

{
  eureka.software.home = with pkgs; [
    pdfarranger  # PDF 合并/拆分/重排
    foliate      # 电子书阅读器（epub 等，见 mime-defaults.nix）
    readest      # 电子书阅读器（Readest）
    sioyek       # 论文 PDF 阅读器（默认 PDF 应用，见 mime-defaults.nix）
  ];
}
