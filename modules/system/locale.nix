{ pkgs, ... }:

{
  i18n = {
    defaultLocale = "zh_CN.UTF-8";

    supportedLocales = [
      "zh_CN.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
    ];

    inputMethod = {
      enable = true;
      type = "fcitx5";

      fcitx5.addons = with pkgs; [
        qt6Packages.fcitx5-chinese-addons
        qt6Packages.fcitx5-configtool
        kdePackages.fcitx5-qt
        fcitx5-gtk
        fcitx5-rime
        fcitx5-mozc
      ];

      fcitx5.waylandFrontend = true;
    };
  };

  fonts = {
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      wqy_zenhei
      noto-fonts-cjk-sans
      sarasa-gothic
      noto-fonts-color-emoji
    ];

    fontconfig = {
      defaultFonts = {
        emoji = [ "Noto Color Emoji" ];
        monospace = [ "JetBrains Mono" "Sarasa Mono SC" ];
        sansSerif = [ "Noto Sans CJK SC" ];
        serif = [ "Noto Serif CJK SC" ];
      };
    };
  };

  environment.variables = {
    GTK_IM_MODULE = "fcitx";
    GLFW_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    SDL_IM_MODULE = "fcitx";
    INPUT_METHOD = "fcitx";
    IMSETTINGS_MODULE = "fcitx";
    NIXOS_OZONE_WL = "1";
    XMODIFIERS = "@im=fcitx";
  };
}
