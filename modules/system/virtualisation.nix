{ pkgs, ... }:

{
  programs.dconf.enable = true;
  programs.virt-manager.enable = true;

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      swtpm.enable = true;
    };
  };

  # The Windows VM workflow only needs QEMU/libvirt. Disabling virtchd avoids
  # pulling cloud-hypervisor when the binary cache mirror is incomplete.
  systemd.services.virtchd.enable = false;

  # Needed for attaching USB devices to Windows guests from virt-manager.
  virtualisation.spiceUSBRedirection.enable = true;

  environment.systemPackages = with pkgs; [
    virt-viewer
    virtio-win
  ];
}
