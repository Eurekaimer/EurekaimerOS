{ pkgs, pkgs-unstable, ... }:

let
  commonRPackages = with pkgs.rPackages; [
    # R Markdown / reports
    rmarkdown
    knitr
    tinytex
    IRkernel
    languageserver

    # Tidyverse and plotting
    tidyverse
    ggplot2
    dplyr
    tidyr
    readr
    tibble
    purrr
    stringr
    forcats
    lubridate

    # Statistics / course packages
    boot
    bootstrap
    MASS
    Matrix
    survival
    car
    lmtest
    sandwich
    lme4
    maps
    mapdata
  ];

  rWithPackages = pkgs.rWrapper.override {
    packages = commonRPackages;
  };

  rstudioWithPackages = pkgs.rstudioWrapper.override {
    packages = commonRPackages;
  };

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
      latexmk;
  };

  rKernelSpec = builtins.toJSON {
    argv = [
      "${rWithPackages}/bin/R"
      "--slave"
      "-e"
      "IRkernel::main()"
      "--args"
      "{connection_file}"
    ];
    display_name = "R (Nix)";
    language = "R";
  };
in
{
  home.packages = with pkgs; [
    # IDE/editor
    pkgs-unstable.vscode
    github-desktop

    # Runtime/package toolchain
    uv
    jupyter
    nodejs_22
    pnpm

    # Scientific writing and analysis
    rWithPackages
    rstudioWithPackages
    texliveWriting
  ];

  xdg.dataFile = {
    "jupyter/kernels/r-nix/kernel.json".text = rKernelSpec + "\n";
    "jupyter/kernels/r-nix/kernel.js".source =
      "${pkgs.rPackages.IRkernel}/library/IRkernel/kernelspec/kernel.js";
    "jupyter/kernels/r-nix/logo-svg.svg".source =
      "${pkgs.rPackages.IRkernel}/library/IRkernel/kernelspec/logo-svg.svg";
    "jupyter/kernels/r-nix/logo-64x64.png".source =
      "${pkgs.rPackages.IRkernel}/library/IRkernel/kernelspec/logo-64x64.png";
  };

  home.sessionVariables = {
    UV_PYTHON = "/run/current-system/sw/bin/python3";
    UV_PYTHON_PREFERENCE = "only-system";
  };

}
