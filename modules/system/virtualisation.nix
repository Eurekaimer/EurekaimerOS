{
  lib,
  pkgs,
  softwareSelection,
  ...
}:

lib.mkMerge [
  (lib.mkIf softwareSelection.system.virtualisation.docker {
    virtualisation.docker.enable = true;
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
