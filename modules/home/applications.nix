{ lib, softwareSelection, ... }:

{
  imports =
    # MIME defaults also handle the always-available image viewer, so keep that
    # module loaded and let it omit document handlers when documents are off.
    [ ./applications/mime-defaults.nix ]
    ++ lib.optionals softwareSelection.home.applications.knowledge [ ./applications/knowledge.nix ]
    ++ lib.optionals softwareSelection.home.applications.documents [ ./applications/documents.nix ]
    ++ lib.optionals softwareSelection.home.applications.media [ ./applications/media.nix ]
    ++ lib.optionals softwareSelection.home.applications.web [ ./applications/web.nix ]
    ++ lib.optionals softwareSelection.home.applications.fileManager [ ./applications/file-manager.nix ]
    ++ lib.optionals softwareSelection.home.applications.transfer [ ./applications/transfer.nix ]
    ++ lib.optionals softwareSelection.home.applications.communication [ ./applications/communication.nix ];
}
