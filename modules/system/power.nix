{ lib, pkgs, ... }:
# 续航调优指南（从省电到更省电，按需自行开启）：
#   - 默认档（当前）：电池下 powersave + 关 boost + CPU 上限 50% + EPP=power
#   - 更激进档（改一行即可）：
#       CPU_MAX_PERF_ON_BAT = 30;                    # 上限降到 30%
#       CPU_MIN_PERF_ON_BAT = 2;                     # 空闲更低
#       START_CHARGE_THRESH_BAT0 = 1;                # 联想长寿命充电模式（55-60% 停止）
#   - 行为层（收益最大，见下方注释）：
#       调低屏幕亮度 > 刷新率降到 60Hz > 减少后台常驻
#
# 注意：CPU_MAX_PERF_ON_BAT 影响电池下性能，调太低会明显变慢。
#

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
      SCHED_POWERSAVE_ON_BAT = 1;  # CFS 调度器省电模式（仅电池下生效）

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


  eureka.software.system = with pkgs; [
    powertop # 电源管理诊断与调优（TLP 的配套工具）
    s-tui    # 终端内 CPU 压力/温度监控
  ];
}
