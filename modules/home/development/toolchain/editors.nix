{
  inputs,
  lib,
  pkgs,
  pkgs-unstable,
  softwareSelection,
  ...
}:

let
  hot100Assistant = pkgs-unstable.buildNpmPackage {
    pname = "vscode-extension-eurekaimer-hot100-assistant";
    version = "1.2.2";
    src = inputs.hot100-assistant;
    npmDepsHash = "sha256-gj45He36R1iu2/S06AyQUw1likFA2XK3JImvaT6uM7c=";
    npmBuildScript = "compile";

    installPhase = ''
      runHook preInstall
      npm prune --omit=dev --ignore-scripts
      extensionDir="$out/share/vscode/extensions/eurekaimer.hot100-assistant"
      mkdir -p "$extensionDir"
      cp -r LICENSE README.md THIRD_PARTY_NOTICES node_modules out package.json resources web "$extensionDir/"
      runHook postInstall
    '';
    passthru = {
      vscodeExtPublisher = "eurekaimer";
      vscodeExtName = "hot100-assistant";
      vscodeExtUniqueId = "eurekaimer.hot100-assistant";
    };
  };

  # Base UI and remote extensions belong to the editor itself. Language and
  # container extensions follow the same switches as their actual toolchains.
  baseVscodeExtensions = with pkgs-unstable.vscode-extensions; [
    enkia.tokyo-night
    oderwat.indent-rainbow
    pkief.material-icon-theme
    ms-ceintl.vscode-language-pack-zh-hans
    ms-vscode.remote-explorer
    ms-vscode-remote.remote-ssh
    ms-vscode-remote.remote-ssh-edit
  ];

  initialVscodeExtensions =
    baseVscodeExtensions
    ++ lib.optionals softwareSelection.home.development.python (
      with pkgs-unstable.vscode-extensions;
      [
        ms-python.debugpy
        ms-python.python
        ms-python.vscode-pylance
        ms-toolsai.jupyter
        ms-toolsai.jupyter-keymap
        ms-toolsai.jupyter-renderers
        ms-toolsai.vscode-jupyter-cell-tags
        ms-toolsai.vscode-jupyter-slideshow
      ]
    )
    ++ lib.optionals softwareSelection.home.development.cpp (
      with pkgs-unstable.vscode-extensions;
      [
        llvm-vs-code-extensions.vscode-clangd
        ms-vscode.cmake-tools
        vadimcn.vscode-lldb
      ]
    )
    ++ lib.optionals softwareSelection.system.virtualisation.docker (
      with pkgs-unstable.vscode-extensions;
      [
        ms-vscode-remote.remote-containers
      ]
    )
    ++ lib.optionals softwareSelection.home.development.java (
      with pkgs-unstable.vscode-extensions;
      [
        redhat.java
        vscjava.vscode-gradle
        vscjava.vscode-java-debug
        vscjava.vscode-java-dependency
        vscjava.vscode-java-pack
        vscjava.vscode-java-test
        vscjava.vscode-maven
      ]
    )
    ++ lib.optionals softwareSelection.home.development.latex (
      with pkgs-unstable.vscode-extensions;
      [ james-yu.latex-workshop ]
    )
    ++ lib.optionals softwareSelection.personal.hot100Assistant [ hot100Assistant ];

  vscodeExtensionSeed = pkgs.symlinkJoin {
    name = "vscode-extension-seed";
    paths = initialVscodeExtensions;
  };

  vscodeWithSyncDisabled = pkgs.symlinkJoin {
    name = "vscode-with-settings-sync-disabled";
    paths = [ pkgs-unstable.vscode ];
    passthru = {
      inherit (pkgs-unstable.vscode) pname version;
    };
    meta = pkgs-unstable.vscode.meta // {
      mainProgram = "code";
    };
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram "$out/bin/code" --add-flags "--disable-settings-sync"
    '';
  };

  vscodeDefaultSettings = pkgs.writeText "vscode-default-settings.json" (
    builtins.toJSON (
      {
        "window.zoomLevel" = 1.5;
        "editor.fontSize" = 18;
        "terminal.integrated.fontSize" = 17;
        "debug.console.fontSize" = 16;
        "workbench.colorTheme" = "Tokyo Night";
        "workbench.iconTheme" = "material-icon-theme";
      }
      // lib.optionalAttrs softwareSelection.home.development.latex {
        "latex-workshop.view.pdf.viewer" = "tab";
        "latex-workshop.synctex.afterBuild.enabled" = true;
        "latex-workshop.latex.autoBuild.run" = "onSave";
        "latex-workshop.latex.recipe.default" = "lastUsed";
        "latex-workshop.latex.clean.enabled" = true;
        "latex-workshop.latex.clean.subfolder.enabled" = true;
        "latex-workshop.latex.clean.method" = "onBuilt";
      }
    )
  );

  vscodeDefaultArgv = pkgs.writeText "vscode-argv.json" ''
    {
      "locale": "zh-cn",
      "password-store": "basic"
    }
  '';
in
{
  programs.vscode = {
    enable = true;
    package = vscodeWithSyncDisabled;
    mutableExtensionsDir = true;
  };

  home.activation.seedMutableVscodeExtensions = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    legacy_marker="$HOME/.local/state/eurekaimeros/vscode-extension-seed-v1"
    marker_dir="$HOME/.local/state/eurekaimeros/vscode-extension-seeds"
    extension_dir="$HOME/.vscode/extensions"
    ${pkgs.coreutils}/bin/mkdir -p "$extension_dir" "$marker_dir"
    for source in ${vscodeExtensionSeed}/share/vscode/extensions/*; do
      name="$(${pkgs.coreutils}/bin/basename "$source")"
      marker="$marker_dir/$name"
      destination="$extension_dir/$name"
      [[ -e "$marker" ]] && continue

      # The old scheme seeded every language at once. During migration, record
      # the current selection without restoring extensions the user removed.
      if [[ -e "$legacy_marker" ]]; then
        ${pkgs.coreutils}/bin/install -m 0644 /dev/null "$marker"
        continue
      fi

      if [[ ! -e "$destination" ]]; then
        resolved="$(${pkgs.coreutils}/bin/readlink -f "$source")"
        ${pkgs.coreutils}/bin/cp -a --no-preserve=mode,ownership -- "$resolved" "$destination"
        ${pkgs.coreutils}/bin/chmod -R u+rwX -- "$destination"
      fi
      ${pkgs.coreutils}/bin/install -m 0644 /dev/null "$marker"
    done
  '';


  # Preserve user edits while Home Manager refreshes the managed handoff link.
  home.activation.stageVscodeSettings = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
    settings_file="$HOME/.config/Code/User/settings.json"
    staged_file="$HOME/.cache/home-manager/vscode-settings.json.staged"
    if [[ -f "$settings_file" && ! -L "$settings_file" ]]; then
      ${pkgs.coreutils}/bin/install -D -m 0600 "$settings_file" "$staged_file"
    fi
  '';

  # Seed a normal writable settings file once; VSCode owns it afterwards.
  home.activation.initializeVscodeSettings = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    settings_file="$HOME/.config/Code/User/settings.json"
    staged_file="$HOME/.cache/home-manager/vscode-settings.json.staged"
    ${pkgs.coreutils}/bin/rm -f -- "$settings_file"
    if [[ -f "$staged_file" ]]; then
      ${pkgs.coreutils}/bin/install -D -m 0644 "$staged_file" "$settings_file"
      ${pkgs.coreutils}/bin/rm -f -- "$staged_file"
    else
      ${pkgs.coreutils}/bin/install -D -m 0644 ${vscodeDefaultSettings} "$settings_file"
    fi
  '';

  # Seed writable launch arguments once; VSCode may update this file itself.
  home.activation.initializeVscodeArgv = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    argv_file="$HOME/.vscode/argv.json"
    if [[ -L "$argv_file" ]]; then
      ${pkgs.coreutils}/bin/rm -f -- "$argv_file"
    fi
    if [[ ! -e "$argv_file" ]]; then
      ${pkgs.coreutils}/bin/install -D -m 0644 ${vscodeDefaultArgv} "$argv_file"
    fi
  '';

  eureka.software.home = [
    pkgs.github-desktop
  ];
}
