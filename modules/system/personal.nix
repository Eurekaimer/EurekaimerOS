{
  inputs,
  lib,
  softwareSelection,
  ...
}:

{
  # These inputs are projects tied to the repository owner's workflow rather
  # than general NixOS functionality.  Keeping their imports here makes that
  # boundary explicit while preserving the existing modules/system layout.
  imports =
    lib.optionals softwareSelection.personal.lexigraph [
      inputs.lexigraph.nixosModules.default
    ]
    ++ lib.optionals softwareSelection.personal.komariCall [
      inputs.komari-call.nixosModules.default
    ];
}
