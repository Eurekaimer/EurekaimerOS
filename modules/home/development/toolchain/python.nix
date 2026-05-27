{ pkgs, ... }:

{
  home.packages = with pkgs; [
    uv
    jupyter
    pyright
  ];
}
