{
  lib,
  pkgs,
  softwareSelection,
  ...
}:

{
  users.users.eurekaimer = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups =
      [
        "networkmanager"
        "wheel"
        "video"
        "audio"
      ]
      ++ lib.optionals softwareSelection.system.virtualisation.docker [ "docker" ]
      ++ lib.optionals softwareSelection.system.virtualisation.virtualMachines [
        "libvirtd"
        "kvm"
      ];
  };

  programs.zsh.enable = true;
}
