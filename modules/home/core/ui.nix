{ pkgs, ... }:

{
  # 桌面 UI 相关
  eureka.software.home = with pkgs; [
    papirus-icon-theme # Papirus 图标主题
    font-awesome       # Font Awesome 图标字体
    libnotify          # 桌面通知命令（notify-send）
  ];

  # Keep user dirs stable across reinstalls so app configs that expect
  # ~/Pictures, ~/Downloads, etc. do not break on systems that default to
  # localized Chinese directory names.
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    desktop = "$HOME/Desktop";
    documents = "$HOME/Documents";
    download = "$HOME/Downloads";
    music = "$HOME/Music";
    pictures = "$HOME/Pictures";
    publicShare = "$HOME/Public";
    templates = "$HOME/Templates";
    videos = "$HOME/Videos";
  };

  gtk = {
    enable = true;
    font = {
      name = "LXGW WenKai";
      package = pkgs.lxgw-wenkai;
      size = 11;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };
  home.pointerCursor = {
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };
}
