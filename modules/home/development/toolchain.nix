{ lib, softwareSelection, ... }:

{
  # Select at the existing language-module boundary.  No package list is
  # duplicated here. Adding a language means one module plus one aggregator
  # line; add a conditional group to editors.nix only when it has VSCode
  # extensions.
  imports =
    # Oh My Pi and its pinned Bun runtime are mandatory owner requirements,
    # independent of the optional general JavaScript toolchain.
    [ ./toolchain/oh-my-pi.nix ]
    ++ lib.optionals softwareSelection.home.development.editors [ ./toolchain/editors.nix ]
    ++ lib.optionals softwareSelection.home.development.cli [ ./toolchain/cli.nix ]
    ++ lib.optionals softwareSelection.home.development.shell [ ./toolchain/shell.nix ]
    ++ lib.optionals softwareSelection.home.development.nix [ ./toolchain/nix.nix ]
    ++ lib.optionals softwareSelection.home.development.lua [ ./toolchain/lua.nix ]
    ++ lib.optionals softwareSelection.home.development.markdown [ ./toolchain/markdown.nix ]
    ++ lib.optionals softwareSelection.home.development.python [ ./toolchain/python.nix ]
    ++ lib.optionals softwareSelection.home.development.javascript [ ./toolchain/javascript.nix ]
    ++ lib.optionals softwareSelection.home.development.java [ ./toolchain/java.nix ]
    ++ lib.optionals softwareSelection.home.development.go [ ./toolchain/go.nix ]
    ++ lib.optionals softwareSelection.home.development.rust [ ./toolchain/rust.nix ]
    ++ lib.optionals softwareSelection.home.development.cpp [ ./toolchain/c-cpp.nix ]
    ++ lib.optionals softwareSelection.home.development.latex [ ./toolchain/latex.nix ];
}
