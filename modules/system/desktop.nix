{ pkgs, ... }:

let
  loginWallpaper = ../../img/login-wallpaper.png;
in
{
  programs.niri.enable = true;
  security.polkit.enable = true;
  services.gvfs.enable = true;
  services.udisks2 = {
    enable = true;
    settings."mount_options.conf".defaults = {
      # Safe NTFS defaults for file managers/udisks in niri.
      # Do not add "force" here: dirty NTFS volumes should be fixed with Windows chkdsk.
      "ntfs:ntfs3_defaults" = "uid=$UID,gid=$GID,windows_names";
      "ntfs:ntfs3_allow" =
        "uid=$UID,gid=$GID,umask,dmask,fmask,iocharset,discard,nodiscard,sparse,nosparse,hidden,nohidden,sys_immutable,nosys_immutable,showmeta,noshowmeta,prealloc,noprealloc,hide_dot_files,nohide_dot_files,windows_names,nocase,case";
      ntfs_drivers = "ntfs3,ntfs";
    };
  };

  # ReGreet is a small GTK greeter. Unlike the previous custom SDDM/QML
  # theme, its background is a supported declarative setting.
  programs.regreet = {
    enable = true;
    extraCss = ./config/regreet.css;
    settings = {
      skip_selection = false;
      background = {
        path = "${loginWallpaper}";
        fit = "Cover";
      };
      appearance.greeting_msg = "欢迎回来";
      GTK.application_prefer_dark_theme = true;
      widget.clock = {
        format = "%Y年%m月%d日  %H:%M";
        resolution = "1s";
        locale = "zh_CN.UTF-8";
      };
    };
    font = {
      package = pkgs.lxgw-wenkai-screen;
      name = "LXGW WenKai Screen";
      size = 16;
    };
  };

  services.xserver.enable = true;
  # Labwc handles GTK popovers reliably; Cage can misroute pointer grabs for
  # ReGreet's user/session combo boxes on this system.
  services.greetd.settings.default_session = {
    command = "${pkgs.dbus}/bin/dbus-run-session ${pkgs.labwc}/bin/labwc -s ${pkgs.regreet}/bin/regreet";
    user = "greeter";
  };
  services.xserver.xkb.layout = "us";

  services.printing.enable = true;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  hardware.bluetooth.enable = true;

  # 蓝牙芯片常驻会持续耗电：默认关闭，需要时再手动开启。
  hardware.bluetooth.powerOnBoot = false;

  services.upower.enable = true;
}
