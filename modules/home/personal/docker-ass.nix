{ pkgs, ... }:

let
  # Override this at runtime when the media stack lives elsewhere.  Keeping the
  # historical path as a default preserves the current machine's behaviour
  # without baking it into the generic shell module.
  defaultProjectDirectory = "/home/eurekaimer/Videos/ASS";
in
{
  eureka.software.home = [
    (pkgs.writeShellApplication {
      name = "docker-ass";
      runtimeInputs = [ pkgs.docker ];

      text = ''
        set -euo pipefail

        action="''${1:-start}"
        project_directory="''${DOCKER_ASS_PROJECT_DIRECTORY:-${defaultProjectDirectory}}"

        compose() {
          local command
          printf -v command '%q ' \
            docker compose --project-directory "$project_directory" "$@"
          /run/wrappers/bin/sg docker -c "$command"
        }

        case "$action" in
          start|up)
            compose up -d
            printf '%s\n' \
              'ANI-RSS:     http://127.0.0.1:7789' \
              'qBittorrent: http://127.0.0.1:8080'
            ;;
          stop|down|restart|ps)
            compose "$action"
            ;;
          status)
            compose ps
            ;;
          logs)
            compose logs --tail=100 -f
            ;;
          update)
            compose pull
            compose up -d
            ;;
          help|-h|--help)
            printf '%s\n' \
              '用法: docker-ass [start|stop|down|restart|status|logs|update|help]' \
              '环境变量: DOCKER_ASS_PROJECT_DIRECTORY 可覆盖 Compose 项目路径。' \
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
}
