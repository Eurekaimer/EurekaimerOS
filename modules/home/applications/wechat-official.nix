{
  stdenvNoCC,
  stdenv,
  lib,
  fetchurl,
  dpkg,
  nss,
  nspr,
  libxt,
  libxtst,
  libxscrnsaver,
  libxrender,
  libxrandr,
  libxi,
  libxft,
  libxfixes,
  libxext,
  libxdamage,
  libxcursor,
  libxcomposite,
  libx11,
  libsm,
  libice,
  libxshmfence,
  libxcb,
  pango,
  zlib,
  atkmm,
  libdrm,
  libxkbcommon,
  libxcb-wm,
  libxcb-image,
  libxcb-keysyms,
  libxcb-render-util,
  libgbm,
  alsa-lib,
  wayland,
  atk,
  qt6,
  at-spi2-atk,
  at-spi2-core,
  dbus,
  cups,
  gtk3,
  libxml2,
  cairo,
  freetype,
  fontconfig,
  vulkan-loader,
  gdk-pixbuf,
  libexif,
  ffmpeg,
  pulseaudio,
  systemd,
  libuuid,
  expat,
  bzip2,
  glib,
  libva,
  libGL,
  libnotify,
  krb5,
  buildFHSEnv,
  writeShellScript,
}:

let
  pname = "wechat-official";
  version = "4.1.1";

  src = fetchurl {
    url = "https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_x86_64.deb";
    hash = "sha256-zmpcIBg5OD1qsBmMAm7OwnS9YoAwRK7GH9yiDgLHl+I=";
  };

  wechat = stdenvNoCC.mkDerivation {
    inherit pname version src;

    nativeBuildInputs = [ dpkg ];

    unpackPhase = ''
      runHook preUnpack
      dpkg -x $src ./wechat
      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall
      cp -r wechat $out
      runHook postInstall
    '';

    meta = {
      description = "Official WeChat Linux client";
      homepage = "https://linux.weixin.qq.com/";
      license = lib.licenses.unfree;
      platforms = [ "x86_64-linux" ];
      sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
      mainProgram = "wechat";
    };
  };

  wechatEnv = stdenvNoCC.mkDerivation {
    name = "wechat-official-env";
    buildCommand = ''
      mkdir -p $out/opt $out/usr
      ln -s ${wechat}/opt/wechat $out/opt/wechat
      ln -s ${wechat}/usr/share $out/usr/share
    '';
    preferLocalBuild = true;
  };

  runtimeLibs = [
    stdenv.cc.cc
    stdenv.cc.libc
    pango
    zlib
    libxcb-wm
    libxcb-image
    libxcb-keysyms
    libxcb-render-util
    libx11
    libxt
    libxext
    libsm
    libice
    libxcb
    libxkbcommon
    libxshmfence
    libxi
    libxft
    libxcursor
    libxfixes
    libxscrnsaver
    libxcomposite
    libxdamage
    libxtst
    libxrandr
    libnotify
    atk
    atkmm
    cairo
    at-spi2-atk
    at-spi2-core
    alsa-lib
    dbus
    cups
    gtk3
    gdk-pixbuf
    libexif
    ffmpeg
    libva
    freetype
    fontconfig
    libxrender
    libuuid
    expat
    glib
    nss
    nspr
    libGL
    libxml2
    libdrm
    libgbm
    vulkan-loader
    systemd
    wayland
    pulseaudio
    qt6.qt5compat
    bzip2
    krb5
  ];
in
buildFHSEnv {
  inherit pname version;
  inherit (wechat) meta;

  runScript = writeShellScript "wechat-launcher" ''
    export QT_QPA_PLATFORM=xcb
    export QT_AUTO_SCREEN_SCALE_FACTOR=1
    export LD_LIBRARY_PATH=${lib.makeLibraryPath runtimeLibs}:/opt/wechat

    if [[ ''${XMODIFIERS} =~ fcitx ]]; then
      export QT_IM_MODULE=fcitx
      export GTK_IM_MODULE=fcitx
    elif [[ ''${XMODIFIERS} =~ ibus ]]; then
      export QT_IM_MODULE=ibus
      export GTK_IM_MODULE=ibus
      export IBUS_USE_PORTAL=1
    fi

    cd /opt/wechat
    exec /opt/wechat/wechat "$@"
  '';

  targetPkgs = _pkgs: [ wechatEnv ] ++ runtimeLibs;

  extraInstallCommands = ''
    mkdir -p $out/share/applications $out/share/icons
    cp -r ${wechat}/usr/share/icons/* $out/share/icons/
    cp ${wechat}/usr/share/applications/wechat.desktop $out/share/applications/wechat.desktop
    substituteInPlace $out/share/applications/wechat.desktop \
      --replace-quiet 'Exec=/usr/bin/wechat %U' "Exec=$out/bin/wechat-official -- %U" \
      --replace-quiet 'Exec=/usr/bin/wechat' "Exec=$out/bin/wechat-official --"
    sed -i '/^\[Desktop Entry\]/a StartupWMClass=wechat' $out/share/applications/wechat.desktop
  '';
}
