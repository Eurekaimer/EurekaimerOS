{ lib, ... }:

{
  # Stable option boundary for machine/network data. Host files provide only
  # values; reusable modules decide how those values become NixOS settings.
  options.eureka.host = {
    mounts = lib.mkOption {
      default = [ ];
      description = "Host-local filesystems; empty in the repository default.";
      type = lib.types.listOf (lib.types.submodule {
        options = {
          mountPoint = lib.mkOption { type = lib.types.str; };
          device = lib.mkOption { type = lib.types.str; };
          fsType = lib.mkOption {
            type = lib.types.str;
            default = "auto";
          };
          userOwned = lib.mkOption {
            type = lib.types.bool;
            default = false;
          };
          options = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
          };
        };
      });
    };

    proxy = {
      enable = lib.mkEnableOption "the host-local proxy";
      host = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
      };
      httpPort = lib.mkOption {
        type = lib.types.port;
        default = 7897;
      };
      socksPort = lib.mkOption {
        type = lib.types.port;
        default = 7897;
      };
      noProxy = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "localhost"
          "127.0.0.1"
          "::1"
        ];
      };
    };
  };
}
