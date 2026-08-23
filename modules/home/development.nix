{ lib, softwareSelection, ... }:

{
  # toolchain.nix is the category selector; Neovim remains an independent
  # editor choice instead of being tied to any particular language.
  imports =
    [ ./development/toolchain.nix ]
    ++ lib.optionals softwareSelection.home.development.neovim [ ./development/neovim.nix ];
}
