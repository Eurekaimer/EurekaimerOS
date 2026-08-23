{ ... }:

{
  # thermald handles thermal limits; it does not replace TLP device tuning.
  services.thermald.enable = true;
}
