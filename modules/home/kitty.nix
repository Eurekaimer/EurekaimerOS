{ ... }:

{
  programs.kitty.enable = true;

  xdg.configFile."kitty/kitty.conf".source =
    ./config/kitty-config/kitty.conf;
}
