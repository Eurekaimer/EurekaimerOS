{ pkgs, ... }:

{
  # 终端工具与自建脚本（见各条目注释）
  eureka.software.home = with pkgs; [
    eza  # 现代化的 ls 替代（图标/文件类型着色）
    tree # 目录树展示
    (writeShellApplication {
      name = "docker-ass";
      runtimeInputs = [ docker ];
      text = ''
        action="''${1:-start}"
        case "$action" in
          start|up)
            /run/wrappers/bin/sg docker -c 'docker compose --project-directory /home/eurekaimer/Videos/ASS up -d'
            printf '%s\n' \
              'ANI-RSS:     http://127.0.0.1:7789' \
              'qBittorrent: http://127.0.0.1:8080'
            ;;
          stop)
            /run/wrappers/bin/sg docker -c 'docker compose --project-directory /home/eurekaimer/Videos/ASS stop'
            ;;
          down)
            /run/wrappers/bin/sg docker -c 'docker compose --project-directory /home/eurekaimer/Videos/ASS down'
            ;;
          restart)
            /run/wrappers/bin/sg docker -c 'docker compose --project-directory /home/eurekaimer/Videos/ASS restart'
            ;;
          status|ps)
            /run/wrappers/bin/sg docker -c 'docker compose --project-directory /home/eurekaimer/Videos/ASS ps'
            ;;
          logs)
            /run/wrappers/bin/sg docker -c 'docker compose --project-directory /home/eurekaimer/Videos/ASS logs --tail=100 -f'
            ;;
          update)
            /run/wrappers/bin/sg docker -c 'docker compose --project-directory /home/eurekaimer/Videos/ASS pull && docker compose --project-directory /home/eurekaimer/Videos/ASS up -d'
            ;;
          help|-h|--help)
            printf '%s\n' \
              '用法: docker-ass [start|stop|down|restart|status|logs|update|help]' \
              '  start    启动服务（默认）' \
              '  stop     停止服务，保留容器' \
              '  down     停止并移除容器，保留配置和下载数据' \
              '  restart  重启服务' \
              '  status   查看容器状态' \
              '  logs     持续查看最近 100 行日志，Ctrl-C 退出' \
              '  update   拉取新镜像并重新启动' \
              '  help     显示本帮助'
            ;;
          *)
            printf '未知命令: %s\n请运行 docker-ass help\n' "$action" >&2
            exit 2
            ;;
        esac
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
