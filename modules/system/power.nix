{ lib, softwareSelection, ... }:

let
  power = softwareSelection.system.power;
in
{
  # Preserve power.nix as the public category boundary while keeping each
  # mechanism independently selectable and reviewable.
  imports =
    lib.optionals power.tlp [ ./power/tlp.nix ]
    ++ lib.optionals power.adaptivePolicy [ ./power/adaptive-policy.nix ]
    ++ lib.optionals power.thermal [ ./power/thermal.nix ]
    ++ lib.optionals power.sleep [ ./power/sleep.nix ]
    ++ lib.optionals power.diagnostics [ ./power/diagnostics.nix ];

  assertions = [
    {
      assertion = !power.adaptivePolicy || power.tlp;
      message = "system.power.adaptivePolicy requires system.power.tlp.";
    }
  ];
}
