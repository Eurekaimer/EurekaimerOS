{ lib, ... }:

let
  foliateDesktop = [ "com.github.johnfactotum.Foliate.desktop" ];
  imvDesktop = [ "imv.desktop" ];

  ebookMimeTypes = [
    "application/epub+zip"
    "application/vnd.amazon.mobi8-ebook"
    "application/vnd.comicbook+zip"
    "application/x-fictionbook+xml"
    "application/x-mobipocket-ebook"
    "application/x-zip-compressed-fb2"
    "x-scheme-handler/opds"
  ];

  imageMimeTypes = [
    "image/apng"
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

  defaultApplications = {
    "application/pdf" = [ "sioyek.desktop" ];
  }
  // lib.genAttrs ebookMimeTypes (_: foliateDesktop)
  // lib.genAttrs imageMimeTypes (_: imvDesktop);

  renderMimeAppsSection =
    apps:
    lib.concatStringsSep "\n" (
      lib.mapAttrsToList (mime: desktops: "${mime}=${lib.concatStringsSep ";" desktops}") apps
    );

  mimeAppsText = ''
    [Added Associations]
    ${renderMimeAppsSection defaultApplications}

    [Default Applications]
    ${renderMimeAppsSection defaultApplications}

    [Removed Associations]
  '';
in

{
  xdg.configFile = {
    "mimeapps.list".force = true;

    # Dolphin/KDE can prefer the desktop-specific file over the generic
    # mimeapps.list that xdg-open/yazi already honor.
    "kde-mimeapps.list" = {
      force = true;
      text = mimeAppsText;
    };
  };

  xdg.desktopEntries = {
    # Override upstream desktop entries so portal/app chooser flows can
    # treat these apps as URI-capable defaults instead of file-only handlers.
    sioyek = {
      name = "Sioyek";
      comment = "PDF viewer for reading research papers and technical books";
      exec = "sioyek --new-window %U";
      terminal = false;
      icon = "sioyek-icon-linux";
      categories = [
        "Development"
        "Viewer"
      ];
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
      categories = [
        "Graphics"
        "2DGraphics"
        "Viewer"
      ];
      mimeType = imageMimeTypes;
    };
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = defaultApplications;

    associations.added = defaultApplications;
  };

  home.activation.rebuildKdeServiceCache = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    if command -v kbuildsycoca6 >/dev/null 2>&1; then
      $DRY_RUN_CMD kbuildsycoca6 --noincremental || true
    fi
  '';
}
