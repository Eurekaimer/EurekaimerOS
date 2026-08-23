# Central identity and preference data for this configuration. The committed
# values intentionally remain the repository owner's defaults.
#
# Machine-only values (disk UUIDs, USB quirks, firewall exceptions) belong in
# host-local.nix. Network-only proxy endpoints belong in proxy-local.nix.
let
  userName = "eurekaimer";
  homeDirectory = "/home/${userName}";
in
{
  system = "x86_64-linux";
  hostName = "nixos";

  user = {
    name = userName;
    inherit homeDirectory;
    uid = 1000;
    gid = 100;
  };

  locale = {
    default = "zh_CN.UTF-8";
    supported = [
      "zh_CN.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
    ];
    timeZone = "Asia/Shanghai";
  };

  # Compatibility baselines, not package versions. Do not change these merely
  # because nixpkgs or Home Manager was upgraded.
  stateVersion = {
    nixos = "25.11";
    homeManager = "25.11";
  };

  personal = {
    campusLoginUrl = "https://netauth.nankai.edu.cn/";
    dockerAss = {
      projectDirectory = "${homeDirectory}/Videos/ASS";
      endpoints = [
        "ANI-RSS:     http://127.0.0.1:7789"
        "qBittorrent: http://127.0.0.1:8080"
      ];
    };
  };
}
