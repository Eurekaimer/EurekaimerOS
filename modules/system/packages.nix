{ pkgs, ... }:

{
  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    neovim
    wget
    git
    gh
    curl
    mihomo
    python3
    ncdu
    btop
    xclip
    activitywatch
    unrar
    peazip
  ];
}
