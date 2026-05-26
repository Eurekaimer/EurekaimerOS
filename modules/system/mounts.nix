{ ... }:

{
  fileSystems."/mnt/Rina" = {
    device = "/dev/disk/by-uuid/A000D74300D71EDA";
    fsType = "ntfs3";
    options = [
      "nofail"
      "x-systemd.automount"
      "x-systemd.idle-timeout=5min"
      "force"
      "uid=1000"
      "gid=100"
      "dmask=022"
      "fmask=133"
      "windows_names"
    ];
  };

  fileSystems."/mnt/Eureka" = {
    device = "/dev/disk/by-uuid/8402CA3202CA28CE";
    fsType = "ntfs3";
    options = [
      "nofail"
      "x-systemd.automount"
      "x-systemd.idle-timeout=5min"
      "force"
      "uid=1000"
      "gid=100"
      "dmask=022"
      "fmask=133"
      "windows_names"
    ];
  };
}
