{ ... }:

{
  # Host-specific settings for this machine.
  networking.hostName = "nixos";

  networking.firewall = {
    enable = false;
    allowedTCPPorts = [ 21301 ];
    allowedUDPPorts = [ 21301 ];
  };

  # USB storage quirk for this specific hardware adapter.
  boot.kernelParams = [
    "usb-storage.quirks=0x0bda:0x9210:u"
  ];
}
