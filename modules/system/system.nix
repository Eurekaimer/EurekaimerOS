{ lib, softwareSelection, ... }:

{
  # Keep the existing responsibility-based module layout.  Optional groups are
  # selected here so individual modules remain small and self-contained.
  imports =
    [
      ./base.nix
      ./kernel.nix
      ./users.nix
      ./locale.nix
      ./desktop.nix
      ./graphics.nix
      ./packages.nix
      ./personal.nix
    ]
    ++ lib.optionals
      (lib.any (enabled: enabled) (lib.attrValues softwareSelection.system.power))
      [ ./power.nix ]
    ++ lib.optionals softwareSelection.system.mounts [ ./mounts.nix ]
    ++ lib.optionals softwareSelection.system.gaming [ ./gaming.nix ]
    ++ lib.optionals
      (softwareSelection.system.virtualisation.docker
        || softwareSelection.system.virtualisation.virtualMachines)
      [ ./virtualisation.nix ];
}
