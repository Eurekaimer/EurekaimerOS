{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./hardware-extra.nix # Explicit per-host GPU choice; never inferred by deployment scripts.
    ./host-local.nix
    # Daily-use config keeps the local proxy enabled by default.
    # In the graphical-install flow, this does not matter until you actually
    # apply the repository configuration via nixos-rebuild.
    ./proxy-local.nix
    ../../modules/system/system.nix
  ];
}
