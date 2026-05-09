{ ... }:

{
  imports = [
    ./applications/knowledge.nix
    ./applications/documents.nix
    ./applications/media.nix
    ./applications/web.nix
    ./applications/transfer.nix
    ./applications/communication.nix
    ./applications/flathub.nix
  ];

  xdg.configFile."mimeapps.list".force = true;

  xdg.desktopEntries = {
    # Override upstream desktop entries so portal/app chooser flows can
    # treat these apps as URI-capable defaults instead of file-only handlers.
    sioyek = {
      name = "Sioyek";
      comment = "PDF viewer for reading research papers and technical books";
      exec = "sioyek %U";
      terminal = false;
      icon = "sioyek-icon-linux";
      categories = [ "Development" "Viewer" ];
      mimeType = [ "application/pdf" ];
    };

    imv = {
      name = "imv";
      genericName = "Image viewer";
      comment = "Fast Image Viewer";
      exec = "imv %U";
      terminal = false;
      noDisplay = false;
      icon = "multimedia-photo-viewer";
      categories = [ "Graphics" "2DGraphics" "Viewer" ];
      mimeType = [
        "image/avif"
        "image/bmp"
        "image/gif"
        "image/heic"
        "image/heif"
        "image/jpeg"
        "image/jpg"
        "image/jxl"
        "image/png"
        "image/qoi"
        "image/svg+xml"
        "image/tiff"
        "image/webp"
        "image/x-bmp"
        "image/x-farbfeld"
        "image/x-png"
        "image/x-portable-bitmap"
        "image/x-portable-graymap"
        "image/x-portable-pixmap"
      ];
    };
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/pdf" = [ "sioyek.desktop" ];

      "image/avif" = [ "imv.desktop" ];
      "image/bmp" = [ "imv.desktop" ];
      "image/gif" = [ "imv.desktop" ];
      "image/heic" = [ "imv.desktop" ];
      "image/heif" = [ "imv.desktop" ];
      "image/jpeg" = [ "imv.desktop" ];
      "image/jxl" = [ "imv.desktop" ];
      "image/png" = [ "imv.desktop" ];
      "image/svg+xml" = [ "imv.desktop" ];
      "image/tiff" = [ "imv.desktop" ];
      "image/webp" = [ "imv.desktop" ];
      "image/x-portable-bitmap" = [ "imv.desktop" ];
      "image/x-portable-graymap" = [ "imv.desktop" ];
      "image/x-portable-pixmap" = [ "imv.desktop" ];
    };

    associations.added = {
      "application/pdf" = [ "sioyek.desktop" ];

      "image/avif" = [ "imv.desktop" ];
      "image/bmp" = [ "imv.desktop" ];
      "image/gif" = [ "imv.desktop" ];
      "image/heic" = [ "imv.desktop" ];
      "image/heif" = [ "imv.desktop" ];
      "image/jpeg" = [ "imv.desktop" ];
      "image/jxl" = [ "imv.desktop" ];
      "image/png" = [ "imv.desktop" ];
      "image/svg+xml" = [ "imv.desktop" ];
      "image/tiff" = [ "imv.desktop" ];
      "image/webp" = [ "imv.desktop" ];
      "image/x-portable-bitmap" = [ "imv.desktop" ];
      "image/x-portable-graymap" = [ "imv.desktop" ];
      "image/x-portable-pixmap" = [ "imv.desktop" ];
    };
  };
}
