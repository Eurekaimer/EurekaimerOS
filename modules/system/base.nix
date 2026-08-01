{ lib, pkgs, ... }:

{
  nix.settings = {
    substituters = lib.mkForce [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://cache.nixos.org/"
    ];
    trusted-users = [
      "root"
      "eurekaimer"
    ];
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
  };

  # generation 管理: 每次 nixos-rebuild switch 时检测 profile 中的
  # generation 数量，达到 10 个即删除最旧的（保留 9 个），并立即
  # 运行 store GC 回收空间。不使用每周定时 GC。
  # 注意: Nix ≥2.21 已移除 `nix-collect-garbage --delete-generations`，
  # 需用 `nix-env --delete-generations +N`（+9 = 保留最近 9 个）。
  system.activationScripts.pruneGenerations = lib.stringAfter [ "var" ] ''
    ${pkgs.nix}/bin/nix-env -p /nix/var/nix/profiles/system --delete-generations +9 || true
    ${pkgs.nix}/bin/nix-env -p /home/eurekaimer/.local/state/nix/profiles/home-manager --delete-generations +9 || true
    ${pkgs.nix}/bin/nix-collect-garbage || true
  '';

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" ];

  networking.networkmanager.enable = true;
  programs.nix-ld.enable = true;

  time.timeZone = "Asia/Shanghai";
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "25.11";
}
