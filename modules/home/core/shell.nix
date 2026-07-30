{ pkgs, ... }:

{
  home.packages = with pkgs; [
    eza
    tree
    (writeShellApplication {
      name = "docker-ass";
      runtimeInputs = [ docker ];
      text = ''
        /run/wrappers/bin/sg docker -c 'docker compose --project-directory /home/eurekaimer/Videos/ASS up -d'
        printf '%s\n' \
          'ANI-RSS:     http://127.0.0.1:7789' \
          'qBittorrent: http://127.0.0.1:8080'
      '';
    })
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
