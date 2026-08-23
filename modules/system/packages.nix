{ lib, softwareSelection, ... }:

{
  # software.nix owns the shared package accumulator and must always be
  # imported.  Category modules stay unchanged and are selected only here.
  imports =
    [ ./software.nix ]
    ++ lib.optionals softwareSelection.system.packages.baseCli [ ./packages/base-cli.nix ]
    ++ lib.optionals softwareSelection.system.packages.network [ ./packages/network.nix ]
    ++ lib.optionals softwareSelection.system.packages.monitoring [ ./packages/monitoring.nix ]
    ++ lib.optionals softwareSelection.system.packages.archive [ ./packages/archive.nix ]
    ++ lib.optionals softwareSelection.system.packages.dos [ ./packages/dos.nix ];
}
