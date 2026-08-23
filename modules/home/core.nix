{ lib, softwareSelection, ... }:

{
  imports =
    lib.optionals softwareSelection.home.core.shell [ ./core/shell.nix ]
    ++ lib.optionals softwareSelection.home.core.kitty [ ./core/kitty.nix ]
    ++ lib.optionals softwareSelection.home.core.fastfetch [ ./core/fastfetch.nix ]
    ++ lib.optionals softwareSelection.home.core.ui [ ./core/ui.nix ]
    ++ lib.optionals softwareSelection.home.core.yazi [ ./core/yazi.nix ]
    ++ lib.optionals softwareSelection.home.core.trashCleanup [ ./core/trash-cleanup.nix ];
}
