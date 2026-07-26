{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    ncdu
    btop
  ];
}
