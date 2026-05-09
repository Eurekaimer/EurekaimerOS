{ pkgs, ... }:

{
  home.packages = with pkgs; [
    papirus-icon-theme
    font-awesome
    libnotify
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
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    cursorTheme = {
      name = "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
    };
  };
}
