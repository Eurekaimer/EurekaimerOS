{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    dosbox-staging
  ];
}
