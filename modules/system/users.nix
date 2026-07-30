{ pkgs, ... }:

{
  users.users.eurekaimer = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "video" "audio" "libvirtd" "kvm" "docker" ];
  };

  programs.zsh.enable = true;
}
