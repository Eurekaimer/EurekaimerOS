{ pkgs, ... }:

{
  programs.dconf.enable = true;
  programs.virt-manager.enable = true;

  virtualisation.docker.enable = true;

  # Pull images through the host proxy; containers that use host networking
  # receive the same proxy endpoint in their Compose environment.
  systemd.services.docker.environment = {
    HTTP_PROXY = "http://127.0.0.1:7897";
    HTTPS_PROXY = "http://127.0.0.1:7897";
    NO_PROXY = "localhost,127.0.0.1,::1";
  };

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
