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
    fontDir.enable = true;

    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      wqy_microhei
      wqy_zenhei
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      sarasa-gothic
      noto-fonts-color-emoji
    ];

    fontconfig = {
      defaultFonts = {
        emoji = [ "Noto Color Emoji" ];
        monospace = [
          "JetBrains Mono"
          "Sarasa Mono SC"
          "Noto Sans Mono CJK SC"
        ];
        sansSerif = [
          "Noto Sans CJK SC"
          "WenQuanYi Micro Hei"
        ];
        serif = [
          "Noto Serif CJK SC"
          "Noto Sans CJK SC"
        ];
      };

      localConf = ''
        <?xml version="1.0"?>
        <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
        <fontconfig>
          <alias binding="same">
            <family>SimSun</family>
            <prefer>
              <family>Noto Serif CJK SC</family>
              <family>Noto Sans CJK SC</family>
            </prefer>
          </alias>
          <alias binding="same">
            <family>NSimSun</family>
            <prefer>
              <family>Noto Serif CJK SC</family>
              <family>Noto Sans CJK SC</family>
            </prefer>
          </alias>
          <alias binding="same">
            <family>宋体</family>
            <prefer>
              <family>Noto Serif CJK SC</family>
              <family>Noto Sans CJK SC</family>
            </prefer>
          </alias>
          <alias binding="same">
            <family>Microsoft YaHei</family>
            <prefer>
              <family>WenQuanYi Micro Hei</family>
              <family>Noto Sans CJK SC</family>
            </prefer>
          </alias>
          <alias binding="same">
            <family>微软雅黑</family>
            <prefer>
              <family>WenQuanYi Micro Hei</family>
              <family>Noto Sans CJK SC</family>
            </prefer>
          </alias>
          <alias binding="same">
            <family>DengXian</family>
            <prefer>
              <family>WenQuanYi Micro Hei</family>
              <family>Noto Sans CJK SC</family>
            </prefer>
          </alias>
          <alias binding="same">
            <family>等线</family>
            <prefer>
              <family>WenQuanYi Micro Hei</family>
              <family>Noto Sans CJK SC</family>
            </prefer>
          </alias>
          <alias binding="same">
            <family>SimHei</family>
            <prefer>
              <family>WenQuanYi Micro Hei</family>
              <family>Noto Sans CJK SC</family>
            </prefer>
          </alias>
          <alias binding="same">
            <family>黑体</family>
            <prefer>
              <family>WenQuanYi Micro Hei</family>
              <family>Noto Sans CJK SC</family>
            </prefer>
          </alias>
          <alias binding="same">
            <family>KaiTi</family>
            <prefer>
              <family>Noto Serif CJK SC</family>
              <family>Noto Sans CJK SC</family>
            </prefer>
          </alias>
          <alias binding="same">
            <family>楷体</family>
            <prefer>
              <family>Noto Serif CJK SC</family>
              <family>Noto Sans CJK SC</family>
            </prefer>
          </alias>
          <alias binding="same">
            <family>FangSong</family>
            <prefer>
              <family>Noto Serif CJK SC</family>
              <family>Noto Sans CJK SC</family>
            </prefer>
          </alias>
          <alias binding="same">
            <family>仿宋</family>
            <prefer>
              <family>Noto Serif CJK SC</family>
              <family>Noto Sans CJK SC</family>
            </prefer>
          </alias>
        </fontconfig>
      '';
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
