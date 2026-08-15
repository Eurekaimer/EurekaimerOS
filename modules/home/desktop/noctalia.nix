{ inputs, pkgs, ... }:

{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia-shell = {
    enable = true;
    systemd.enable = true;
    package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [
        ../../../patches/noctalia-battery-estimate.patch
      ];
    });
    settings = pkgs.replaceVars ../config/noctalia-config/settings.json.in {
      wallpaperDirectory = ../../../img;
    };
  };
}
