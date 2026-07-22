{ inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./host-local.nix
    # Daily-use config keeps the local proxy enabled by default.
    # In the graphical-install flow, this does not matter until you actually
    # apply the repository configuration via nixos-rebuild.
    ./proxy-local.nix
    ../../modules/system/system.nix
    ../../modules/system/graphics-intel.nix
    inputs.lexigraph.nixosModules.default
  ];
}
