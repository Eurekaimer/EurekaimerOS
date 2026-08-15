{ pkgs, ... }:

{
  programs.fastfetch.enable = true;
  xdg.configFile."fastfetch/config.jsonc".source =
    pkgs.replaceVars ../config/fastfetch-config/config.jsonc.in {
      logo = ../../../img/logo-bingo.jpg;
    };
}
