{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    unrar
    peazip
  ];
}
