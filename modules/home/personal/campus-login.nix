{ pkgs, ... }:

{
  # Nankai campus authentication helper.  It deliberately uses an isolated
  # browser profile and clears all common proxy variables so authentication
  # never mutates or depends on the normal browser session.
  eureka.software.home = [
    (pkgs.writeShellApplication {
      name = "campus-login";
      runtimeInputs = [ pkgs.coreutils ];

      text = ''
        set -euo pipefail

        profile="''${CAMPUS_CHROME_PROFILE:-/tmp/chrome-campus-login}"

        unset http_proxy https_proxy all_proxy
        unset HTTP_PROXY HTTPS_PROXY ALL_PROXY
        unset no_proxy NO_PROXY

        if command -v google-chrome-stable >/dev/null 2>&1; then
          chrome="google-chrome-stable"
        elif command -v google-chrome >/dev/null 2>&1; then
          chrome="google-chrome"
        elif command -v chromium >/dev/null 2>&1; then
          chrome="chromium"
        else
          echo "错误：没有找到 Chrome / Chromium。" >&2
          echo "请启用 home.applications.web，或自行安装兼容浏览器。" >&2
          exit 1
        fi

        mkdir -p "$profile"

        printf '%s\n' \
          "正在使用直连模式打开校园网认证窗口……" \
          "浏览器：$chrome" \
          "临时用户目录：$profile" \
          ""

        exec "$chrome" \
          --user-data-dir="$profile" \
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
