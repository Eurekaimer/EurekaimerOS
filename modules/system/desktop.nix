{ ... }:

{
  programs.niri.enable = true;
  security.polkit.enable = true;
  services.gvfs.enable = true;
  services.udisks2 = {
    enable = true;
    settings."mount_options.conf".defaults = {
      # Safe NTFS defaults for Dolphin/udisks in niri.
      # Do not add "force" here: dirty NTFS volumes should be fixed with Windows chkdsk.
      "ntfs:ntfs3_defaults" = "uid=$UID,gid=$GID,windows_names";
      "ntfs:ntfs3_allow" = "uid=$UID,gid=$GID,umask,dmask,fmask,iocharset,discard,nodiscard,sparse,nosparse,hidden,nohidden,sys_immutable,nosys_immutable,showmeta,noshowmeta,prealloc,noprealloc,hide_dot_files,nohide_dot_files,windows_names,nocase,case";
      ntfs_drivers = "ntfs3,ntfs";
    };
  };

  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
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
  hardware.bluetooth.powerOnBoot = true;

  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
}
