{ pkgs, ... }:

{
  users.users.eurekaimer = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "video" "audio" ];
  };

  programs.zsh.enable = true;
}
