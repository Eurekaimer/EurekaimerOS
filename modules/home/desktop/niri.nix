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

  niriSessionPackages = with pkgs; [
    xwayland-satellite
    pamixer
    brightnessctl
    hyprlock
    imv
    pavucontrol
    kdePackages.polkit-kde-agent-1
  ];

  niriCapturePackages = with pkgs; [
    grim
    slurp
    wf-recorder
    wl-clipboard
  ];

  niriScripts = [
    niri-window-shot
  ];
in
{
  home.packages = niriSessionPackages ++ niriCapturePackages ++ niriScripts;

  services.swayosd.enable = false;
  home.activation.createScreenshotsDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD mkdir -p "${screenshotDir}"
  '';
  xdg.configFile."niri/config.kdl".source = ../config/niri-config/config.kdl;
}
