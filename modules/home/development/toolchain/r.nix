{ pkgs, ... }:

let
  commonRPackages = with pkgs.rPackages; [
    # R Markdown / reports
    rmarkdown
    knitr
    tinytex
    IRkernel
    languageserver
    renv

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
  home.packages = [
    rWithPackages
    rstudioWithPackages
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
}
