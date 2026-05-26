{ pkgs, ... }:

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
in
{
  home.packages = with pkgs; [
    # IDE/editor
    vscode
    github-desktop

    # Runtime/package toolchain
    uv
    nodejs_22
    pnpm

    # Scientific writing and analysis
    (rWrapper.override {
      packages = commonRPackages;
    })
    (rstudioWrapper.override {
      packages = commonRPackages;
    })
    texlive.combined.scheme-full
  ];

  home.sessionVariables = {
    UV_PYTHON = "/run/current-system/sw/bin/python3";
    UV_PYTHON_PREFERENCE = "only-system";
  };

}
