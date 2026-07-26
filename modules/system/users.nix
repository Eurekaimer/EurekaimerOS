{ pkgs, ... }:

{
  users.users.eurekaimer = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "video" "audio" "libvirtd" "kvm" ];
  };

  programs.zsh.enable = true;
}
