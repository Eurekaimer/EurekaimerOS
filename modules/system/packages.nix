{ ... }:

{
  imports = [
    ./software.nix
    ./packages/base-cli.nix
    ./packages/network.nix
    ./packages/monitoring.nix
    ./packages/archive.nix
    ./packages/dos.nix
  ];
}
