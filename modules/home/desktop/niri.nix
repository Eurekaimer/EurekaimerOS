{
  lib,
  pkgs,
  ...
}:

let
  screenshotDir = "$HOME/Pictures/Screenshots";

  niri-window-shot = pkgs.writeShellApplication {
    name = "niri-window-shot";
    runtimeInputs = [
      pkgs.jq
      pkgs.niri
    ];
    text = ''
      set -euo pipefail

      window_json="$(niri msg --json pick-window 2>/dev/null || true)"
      [ -n "$window_json" ] || exit 0

      window_id="$(
        jq -er '
          if type == "object" then
            .id? // .window?.id? // .window_id? // empty
          elif type == "number" then
            .
          else
            empty
          end
        ' <<<"$window_json" 2>/dev/null || true
      )"

      [ -n "$window_id" ] || exit 0
      case "$window_id" in
        *[!0-9]*) exit 0 ;;
      esac

      niri msg action screenshot-window --id "$window_id" --write-to-disk true >/dev/null
    '';
  };

  battery-idle-suspend = pkgs.writeShellApplication {
    name = "battery-idle-suspend";
    runtimeInputs = [ pkgs.systemd ];
    text = ''
      set -euo pipefail

      requested_tier="''${1:?battery tier is required}"
      sysfs_root="''${BATTERY_IDLE_SYSFS_ROOT:-/sys}"
      systemctl_bin="''${BATTERY_IDLE_SYSTEMCTL:-systemctl}"
      ac_online=0
      battery_found=0
      capacity=0

      for supply in "$sysfs_root"/class/power_supply/*; do
        [[ -r "$supply/type" ]] || continue
        read -r supply_type < "$supply/type"
        case "$supply_type" in
          Battery)
            (( battery_found += 1 ))
            if [[ -r "$supply/capacity" ]]; then
              read -r battery_capacity < "$supply/capacity"
              (( battery_capacity > capacity )) && capacity=$battery_capacity
            fi
            ;;
          Mains|USB|USB_C)
            if [[ -r "$supply/online" ]]; then
              read -r online < "$supply/online"
              [[ "$online" == 1 ]] && ac_online=1
            fi
            ;;
        esac
      done

      (( battery_found > 0 && ac_online == 0 )) || exit 0

      case "$requested_tier" in
        at-or-below-20) (( capacity <= 20 )) || exit 0 ;;
        20-to-50) (( capacity > 20 && capacity <= 50 )) || exit 0 ;;
        50-to-90) (( capacity > 50 && capacity <= 90 )) || exit 0 ;;
        above-90) (( capacity > 90 )) || exit 0 ;;
        *) exit 2 ;;
      esac

      exec "$systemctl_bin" suspend-then-hibernate
    '';
  };

  adaptive-swayidle = pkgs.writeShellApplication {
    name = "adaptive-swayidle";
    text = ''
      exec ${pkgs.swayidle}/bin/swayidle -w \
        timeout 900 '${pkgs.hyprlock}/bin/hyprlock' \
        timeout 1200 '${pkgs.niri}/bin/niri msg action power-off-monitors' \
        resume '${pkgs.niri}/bin/niri msg action power-on-monitors' \
        timeout 1500 '${lib.getExe battery-idle-suspend} at-or-below-20' \
        timeout 2400 '${lib.getExe battery-idle-suspend} 20-to-50' \
        timeout 3600 '${lib.getExe battery-idle-suspend} 50-to-90' \
        timeout 5400 '${lib.getExe battery-idle-suspend} above-90'
    '';
  };

  niriSessionPackages = with pkgs; [
    xwayland-satellite
    pamixer
    brightnessctl
    hyprlock
    imv
    pavucontrol
    polkitAgent        # Polkit 认证代理（替代 KDE agent，见上方 let）
    swayidle           # 空闲锁屏、熄屏与分级挂起（由 systemd user service 管理）
  ];

  niriCapturePackages = with pkgs; [
    grim
    slurp
    wf-recorder
    wl-clipboard
  ];

  niriScripts = [
    niri-window-shot
    battery-idle-suspend
    adaptive-swayidle
  ];
  # Polkit 认证代理（轻量替代 KDE 的 polkit-kde-agent-1）
  polkitAgent = pkgs.writeShellApplication {
    name = "polkit-auth-agent";
    runtimeInputs = [ pkgs.polkit_gnome ];
    text = ''
      exec ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1 "$@"
    '';
  };

in
{
  eureka.software.home = niriSessionPackages ++ niriCapturePackages ++ niriScripts;

  systemd.user.services.swayidle = {
    Unit = {
      Description = "Adaptive lock, display-off, and battery suspend policy";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = lib.getExe adaptive-swayidle;
      Restart = "on-failure";
      RestartSec = 1;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  services.swayosd.enable = false;
  home.activation.createScreenshotsDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD mkdir -p "${screenshotDir}"
  '';
  xdg.configFile."niri/config.kdl".source = pkgs.replaceVars ../config/niri-config/config.kdl.in {
    desktopWallpaper = ../../../img/wallpaper-nozomi.png;
  };
  xdg.configFile."hypr/hyprlock.conf".source = pkgs.replaceVars ../config/hyprlock-config/hyprlock.conf.in {
    loginWallpaper = ../../../img/login-wallpaper.png;
  };
}
