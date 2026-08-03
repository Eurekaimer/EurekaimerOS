{
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
    codex           # OpenAI Codex CLI（unstable）
    codex-acp       # Codex ACP
    ompPackage      # llm-agents 提供的 omp（终端 AI 助手）
  ];

  home.file.".codex/config.toml".source = ../config/agents/codex/config.toml;
}
