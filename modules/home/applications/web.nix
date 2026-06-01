{ pkgs, ... }:

{
  home.packages = with pkgs; [
    google-chrome
    clash-verge-rev
    throne
    sunshine
    (writeShellApplication {
      name = "campus-login";

      runtimeInputs = [
        coreutils
      ];

      text = ''
        set -euo pipefail

        PROFILE="''${CAMPUS_CHROME_PROFILE:-/tmp/chrome-campus-login}"

        unset http_proxy
        unset https_proxy
        unset all_proxy
        unset HTTP_PROXY
        unset HTTPS_PROXY
        unset ALL_PROXY
        unset no_proxy
        unset NO_PROXY

        if command -v google-chrome-stable >/dev/null 2>&1; then
          CHROME="google-chrome-stable"
        elif command -v google-chrome >/dev/null 2>&1; then
          CHROME="google-chrome"
        elif command -v chromium >/dev/null 2>&1; then
          CHROME="chromium"
        else
          echo "错误：没有找到 Chrome / Chromium。" >&2
          echo "请先安装 google-chrome 或 chromium。" >&2
          exit 1
        fi

        mkdir -p "$PROFILE"

        echo "正在使用直连模式打开校园网认证窗口..."
        echo "浏览器：$CHROME"
        echo "临时用户目录：$PROFILE"
        echo

        exec "$CHROME" \
          --user-data-dir="$PROFILE" \
          --no-first-run \
          --disable-extensions \
          --proxy-server="direct://" \
          --proxy-bypass-list="*" \
          --new-window \
          "https://netauth.nankai.edu.cn/"
      '';
    })
  ];
}
