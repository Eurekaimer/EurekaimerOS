{ ... }:

{
  # Host-specific settings for this machine.
  networking.hostName = "nixos";

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 21301 ];
    allowedUDPPorts = [ 21301 ];
  };

  systemd.services.nix-daemon.serviceConfig.Environment = [
    "http_proxy=http://127.0.0.1:7897"
    "https_proxy=http://127.0.0.1:7897"
    "all_proxy=socks5://127.0.0.1:7897"
  ];

  environment.variables = {
    http_proxy = "http://127.0.0.1:7897";
    https_proxy = "http://127.0.0.1:7897";
    all_proxy = "socks5://127.0.0.1:7897";
  };

  # USB storage quirk for this specific hardware adapter.
  boot.kernelParams = [
    "usb-storage.quirks=0x0bda:0x9210:u"
  ];
}
