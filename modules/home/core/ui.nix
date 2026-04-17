{ pkgs, ... }:

{
  home.packages = with pkgs; [
    papirus-icon-theme
    font-awesome
    libnotify
  ];

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
