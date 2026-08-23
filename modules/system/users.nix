{
  lib,
  hostSettings,
  pkgs,
  softwareSelection,
  ...
}:

{
  users.users.${hostSettings.user.name} = {
    isNormalUser = true;
    uid = hostSettings.user.uid;
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
