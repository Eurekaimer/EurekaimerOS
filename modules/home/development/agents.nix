{
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:

{
  home.packages = with pkgs-unstable; [
    claude-code
    claude-code-acp
    codex
    codex-acp
  ];

  home.file.".codex/config.toml".source = ../config/agents/codex/config.toml;

  home.activation.ensureClaudeCodeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    claude_dir="$HOME/.claude"
    claude_settings="$claude_dir/settings.json"

    if [ ! -e "$claude_settings" ]; then
      run ${pkgs.coreutils}/bin/mkdir -p "$claude_dir"
      run ${pkgs.coreutils}/bin/cp ${../config/agents/claude-code/settings.template.json} "$claude_settings"
      run ${pkgs.coreutils}/bin/chmod 600 "$claude_settings"
    fi
  '';
}
