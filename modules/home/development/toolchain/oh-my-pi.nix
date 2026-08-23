{
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:

let
  # These versions are an explicit owner requirement. Keep the Bun runtime and
  # Oh My Pi agent in one module so their mutable user installation cannot
  # silently drift apart.
  bunVersion = "1.3.14";
  ompVersion = "17.3.4";
in
{
  eureka.software.home = [
    pkgs-unstable.bun # Bootstrap runtime and fallback Bun on PATH.
  ];

  home.sessionVariables.BUN_INSTALL = "$HOME/.bun";
  home.sessionPath = [ "$HOME/.bun/bin" ];

  home.activation.installOhMyPi = lib.hm.dag.entryAfter [ "installPackages" ] ''
    export BUN_INSTALL="$HOME/.bun"

    installed_bun="$("$HOME/.bun/bin/bun" --version 2>/dev/null || true)"
    if [[ "$installed_bun" != "${bunVersion}" ]]; then
      ${pkgs-unstable.bun}/bin/bun add -g "bun@${bunVersion}"
    fi

    omp_package="$HOME/.bun/install/global/node_modules/@oh-my-pi/pi-coding-agent/package.json"
    installed_omp="$(${pkgs.jq}/bin/jq -r '.version // empty' "$omp_package" 2>/dev/null || true)"
    if [[ "$installed_omp" != "${ompVersion}" ]]; then
      "$HOME/.bun/bin/bun" add -g "@oh-my-pi/pi-coding-agent@${ompVersion}"
    fi
  '';

  home.file.".local/bin/omp" = {
    force = true;
    executable = true;
    text = ''
      #!/usr/bin/env bash
      exec "$HOME/.bun/bin/bun" "$HOME/.bun/install/global/node_modules/@oh-my-pi/pi-coding-agent/dist/cli.js" "$@"
    '';
  };
}
