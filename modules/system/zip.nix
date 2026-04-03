{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # zip and unzip tool
    unrar
    peazip
  ];
}
