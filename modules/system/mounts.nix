{
  config,
  hostSettings,
  lib,
  ...
}:

let
  renderMount = mount:
    lib.nameValuePair mount.mountPoint {
      inherit (mount) device fsType;
      options = mount.options ++ lib.optionals mount.userOwned [
        "uid=${toString hostSettings.user.uid}"
        "gid=${toString hostSettings.user.gid}"
      ];
    };
in
{
  # The repository default is empty. Add machine-specific entries only in
  # hosts/nixos/host-local.nix; deploy-full.sh never invents UUIDs.
  fileSystems = builtins.listToAttrs (map renderMount config.eureka.host.mounts);
}
