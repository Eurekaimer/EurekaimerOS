{
  lib,
  pkgs,
  pkgs-unstable,
  inputs,
  ...
}:

let
  ompPackage = inputs.llm-agents.packages.${pkgs.system}.omp;
in
{
  eureka.software.home = with pkgs-unstable; [
    claude-code     # Claude Code CLI（Anthropic，unstable）
    claude-code-acp # Claude Code ACP（Agent Client Protocol）
    codex           # OpenAI Codex CLI（unstable）
    codex-acp       # Codex ACP
    ompPackage      # llm-agents 提供的 omp（终端 AI 助手）
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
