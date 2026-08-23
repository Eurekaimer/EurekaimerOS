{ pkgs, ... }:

{
  eureka.software.system = [
    pkgs.powertop # On-demand diagnosis; no persistent auto-tune service.
  ];
}
