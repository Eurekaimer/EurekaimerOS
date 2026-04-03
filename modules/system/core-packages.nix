{ pkgs, ... }:

{
  # 开启 Firefox
  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    # editor tool chain
    vim
    neovim
    wget
    # file manager
    git
    curl
    # memory manager
    ncdu
    # clipboard manager
    xclip

    # --- KDE 主题与美化 ---
    whitesur-kde
    whitesur-icon-theme
    kdePackages.qttranslations
  ];
}
