{ pkgs, ... }:

{
  # 通用终端工具。与个人目录或服务绑定的脚本放在
  # modules/home/personal/，避免基础 shell 模块依赖本机路径。
  eureka.software.home = with pkgs; [
    eza  # 现代化的 ls 替代（图标/文件类型着色）
    tree # 目录树展示
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
