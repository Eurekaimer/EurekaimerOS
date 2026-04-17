{ ... }:

{
  nix.settings = {
    substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://cache.nixos.org/"
    ];
    trusted-users = [ "root" "eurekaimer" ];
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" ];

  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Shanghai";
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "25.11";
}
