{
  lib,
  pkgs,
  softwareSelection,
  ...
}:

lib.mkMerge [
  (lib.mkIf softwareSelection.system.virtualisation.docker {
    virtualisation.docker.enable = true;

    # Pull images through the host proxy.  This remains a host-local policy;
    # proxy-local.nix documents and owns the matching endpoint.
    systemd.services.docker.environment = {
      HTTP_PROXY = "http://127.0.0.1:7897";
      HTTPS_PROXY = "http://127.0.0.1:7897";
      NO_PROXY = "localhost,127.0.0.1,::1";
    };
  })

  (lib.mkIf softwareSelection.system.virtualisation.virtualMachines {
    programs.dconf.enable = true;
    programs.virt-manager.enable = true;

    virtualisation.libvirtd = {
      enable = true;
      qemu.swtpm.enable = true;
    };

    # The Windows VM workflow only needs QEMU/libvirt.  Disabling virtchd
    # avoids pulling cloud-hypervisor when a mirror lacks that package.
    systemd.services.virtchd.enable = false;

    # Needed for attaching USB devices to Windows guests from virt-manager.
    virtualisation.spiceUSBRedirection.enable = true;

    eureka.software.system = with pkgs; [
      virt-viewer # SPICE/VNC 虚拟机图形客户端
      virtio-win # Windows 客户机 virtio 驱动镜像
    ];
  })
]
