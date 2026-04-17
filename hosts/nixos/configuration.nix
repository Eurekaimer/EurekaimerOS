{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./host-local.nix
    ../../modules/system/system.nix
    # optional on Intel iGPU machines:
    # ../../modules/system/graphics-intel.nix
  ];
}
