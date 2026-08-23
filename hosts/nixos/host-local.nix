{ hostSettings, ... }:

{
  # Host-specific settings for this machine.
  networking.hostName = hostSettings.hostName;
  networking.firewall = {
    enable = false;
    allowedTCPPorts = [ 21301 ];
    allowedUDPPorts = [ 21301 ];
  };

  # Verified quirks for the repository owner's current laptop.
  boot.kernelParams = [
    "usb-storage.quirks=0x0bda:0x9210:u"
    "i915.enable_fbc=1"
  ];

  boot.resumeDevice = "/dev/disk/by-uuid/5a54b4dc-0a71-4d17-b452-d025c4f50110";
  swapDevices = [
    { device = "/dev/disk/by-uuid/5a54b4dc-0a71-4d17-b452-d025c4f50110"; }
  ];

  # Add only values verified on the target machine. Example:
  # eureka.host.mounts = [{
  #   mountPoint = "/mnt/data";
  #   device = "/dev/disk/by-uuid/<UUID>";
  #   fsType = "ntfs3";
  #   userOwned = true;
  #   options = [ "nofail" "x-systemd.automount" "windows_names" ];
  # }];
  eureka.host.mounts = [
    {
      mountPoint = "/mnt/Rina";
      device = "/dev/disk/by-uuid/A000D74300D71EDA";
      fsType = "ntfs3";
      userOwned = true;
      options = [
        "nofail"
        "x-systemd.automount"
        "x-systemd.idle-timeout=5min"
        "force"
        "dmask=022"
        "fmask=133"
        "windows_names"
      ];
    }
    {
      mountPoint = "/mnt/Eureka";
      device = "/dev/disk/by-uuid/8402CA3202CA28CE";
      fsType = "ntfs3";
      userOwned = true;
      options = [
        "nofail"
        "x-systemd.automount"
        "x-systemd.idle-timeout=5min"
        "force"
        "dmask=022"
        "fmask=133"
        "windows_names"
      ];
    }
  ];
}
