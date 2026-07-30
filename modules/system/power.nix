{ lib, pkgs, ... }:

{
  powerManagement.enable = true;

  # TLP and power-profiles-daemon both try to own platform power profiles.
  # Use TLP here because it also tunes device runtime PM, PCIe ASPM, Wi-Fi,
  # audio, USB autosuspend, and CPU boost behavior.
  services.power-profiles-daemon.enable = lib.mkForce false;

  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "powersave";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
      CPU_HWP_DYN_BOOST_ON_AC = 1;
      CPU_HWP_DYN_BOOST_ON_BAT = 0;
      CPU_MIN_PERF_ON_AC = 10;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 5;
      CPU_MAX_PERF_ON_BAT = 50;

      PLATFORM_PROFILE_ON_AC = "balanced";
      PLATFORM_PROFILE_ON_BAT = "low-power";

      PCIE_ASPM_ON_AC = "default";
      PCIE_ASPM_ON_BAT = "powersupersave";
      RUNTIME_PM_ON_AC = "on";
      RUNTIME_PM_ON_BAT = "auto";
      AHCI_RUNTIME_PM_ON_AC = "on";
      AHCI_RUNTIME_PM_ON_BAT = "auto";
      AHCI_RUNTIME_PM_TIMEOUT = 15;

      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "on";
      SOUND_POWER_SAVE_ON_AC = 0;
      SOUND_POWER_SAVE_ON_BAT = 1;
      USB_AUTOSUSPEND = 1;
      NMI_WATCHDOG = 0;

      # Lenovo XiaoXin/IdeaPad exposes a fixed conservation mode instead of
      # arbitrary charge thresholds. Keep it off so charging can reach 100%;
      # switch STOP_CHARGE_THRESH_BAT0 to 1 if you want long-life 55-60% mode.
      START_CHARGE_THRESH_BAT0 = 0;
      STOP_CHARGE_THRESH_BAT0 = 0;
      RESTORE_THRESHOLDS_ON_BAT = 1;
    };
  };

  networking.networkmanager.wifi.powersave = true;

  services.thermald.enable = true;

  # Your machine exposes both s2idle and deep. Prefer deep to reduce suspend
  # drain; remove this if resume becomes unreliable on this hardware.
  boot.kernelParams = [ "mem_sleep_default=deep" ];


  environment.systemPackages = with pkgs; [
    powertop
    s-tui
  ];
}
