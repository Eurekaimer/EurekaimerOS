{ ... }:

{
  # Optional local proxy module.
  # Enable this only after the system is installed and the local proxy service
  # on 127.0.0.1:7897 is actually available.
  systemd.services.nix-daemon.serviceConfig.Environment = [
    "http_proxy=http://127.0.0.1:7897"
    "https_proxy=http://127.0.0.1:7897"
    "all_proxy=socks5://127.0.0.1:7897"
  ];

  environment.variables = {
    http_proxy = "http://127.0.0.1:7897";
    https_proxy = "http://127.0.0.1:7897";
    all_proxy = "socks5://127.0.0.1:7897";
  };
}
