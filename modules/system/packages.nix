{ pkgs, ... }:

{
  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    neovim
    wget
    git
    curl
    ncdu
    btop
    xclip
    activitywatch
    unrar
    peazip
  ];
}
