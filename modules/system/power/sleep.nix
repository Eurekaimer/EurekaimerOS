{ ... }:

{
  # Resume-device and swap UUID declarations are host data and therefore live
  # in hosts/nixos/host-local.nix, not in this portable policy module.
  boot.kernelParams = [ "mem_sleep_default=deep" ];
  systemd.sleep.extraConfig = ''
    SuspendEstimationSec=30min
  '';
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "ignore";
  };
}
