{
  config,
  lib,
  softwareSelection,
  ...
}:

let
  proxy = config.eureka.host.proxy;
  httpUrl = "http://${proxy.host}:${toString proxy.httpPort}";
  socksUrl = "socks5://${proxy.host}:${toString proxy.socksPort}";
  noProxy = lib.concatStringsSep "," proxy.noProxy;
in
{
  config = lib.mkIf proxy.enable (lib.mkMerge [
    {
      systemd.services.nix-daemon.serviceConfig.Environment = [
        "http_proxy=${httpUrl}"
        "https_proxy=${httpUrl}"
        "all_proxy=${socksUrl}"
      ];
      environment.variables = {
        http_proxy = httpUrl;
        https_proxy = httpUrl;
        all_proxy = socksUrl;
        no_proxy = noProxy;
      };
    }
    (lib.mkIf softwareSelection.system.virtualisation.docker {
      systemd.services.docker.environment = {
        HTTP_PROXY = httpUrl;
        HTTPS_PROXY = httpUrl;
        NO_PROXY = noProxy;
      };
    })
  ]);
}
