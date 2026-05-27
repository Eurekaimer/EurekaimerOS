{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vim
    neovim
    git
    gh
    python3
    xclip
  ];
}
