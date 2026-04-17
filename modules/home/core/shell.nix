{ pkgs, ... }:

{
  home.packages = with pkgs; [
    eza
    tree
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      ignoreAllDups = true;
      share = true;
    };

    shellAliases = {
      ls = "eza --icons";
      ll = "eza -l --icons --git";
      la = "eza -la --icons --git";
    };

    initContent = ''
      # zoxide 初始化
      eval "$(zoxide init zsh)"
    '';
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  xdg.configFile."starship.toml".source = ../config/starship-config/starship.toml;

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
}
