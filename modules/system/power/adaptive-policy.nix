{ lib, pkgs, ... }:

let
  # Adaptive layer only: samples battery telemetry and asks TLP to switch the
  # AC/battery baseline before applying a bounded Intel HWP ceiling. The
  # aggregator asserts the TLP dependency.
  refreshPowerPolicy = pkgs.writeShellApplication {
    name = "refresh-power-policy";
    text = ''
      set -euo pipefail

      sysfs_root="''${POWER_POLICY_SYSFS_ROOT:-/sys}"
      state_dir="''${POWER_POLICY_STATE_DIR:-/var/lib/power-policy}"
      runtime_dir="''${POWER_POLICY_RUNTIME_DIR:-/run/power-policy}"
      tlp_bin="''${POWER_POLICY_TLP_BIN:-${pkgs.tlp}/bin/tlp}"
      state_file="$state_dir/controller-state"

      ${pkgs.coreutils}/bin/mkdir -p "$state_dir" "$runtime_dir"

      ac_online=0
      battery_count=0
      fallback_capacity=0
      energy_now_uwh=0
      energy_full_uwh=0
      power_now_uw=0

      for supply in "$sysfs_root"/class/power_supply/*; do
        [[ -r "$supply/type" ]] || continue
        read -r supply_type < "$supply/type"
        case "$supply_type" in
          Battery)
            (( battery_count += 1 ))

            if [[ -r "$supply/capacity" ]]; then
              read -r capacity < "$supply/capacity"
              (( capacity > fallback_capacity )) && fallback_capacity=$capacity
            fi

            if [[ -r "$supply/energy_now" && -r "$supply/energy_full" ]]; then
              read -r battery_energy_now < "$supply/energy_now"
              read -r battery_energy_full < "$supply/energy_full"
              (( energy_now_uwh += battery_energy_now ))
              (( energy_full_uwh += battery_energy_full ))
            fi

            if [[ -r "$supply/power_now" ]]; then
              read -r battery_power_now < "$supply/power_now"
              (( power_now_uw += battery_power_now ))
            elif [[ -r "$supply/current_now" && -r "$supply/voltage_now" ]]; then
              read -r battery_current_now < "$supply/current_now"
              read -r battery_voltage_now < "$supply/voltage_now"
              (( power_now_uw += battery_current_now * battery_voltage_now / 1000000 ))
            fi
            ;;
          Mains|USB|USB_C)
            if [[ -r "$supply/online" ]]; then
              read -r online < "$supply/online"
              [[ "$online" == 1 ]] && ac_online=1
            fi
            ;;
        esac
      done

      capacity=$fallback_capacity
      if (( energy_full_uwh > 0 )); then
        capacity=$((energy_now_uwh * 100 / energy_full_uwh))
      fi
      (( capacity < 0 )) && capacity=0
      (( capacity > 100 )) && capacity=100

      write_status() {
        local mode=$1
        local tier=$2
        local budget_state=$3
        local average_uw=$4
        local budget_uw=$5
        local estimate_seconds=$6
        local target_seconds=$7
        local cpu_cap=$8
        local tmp="$runtime_dir/status.json.tmp"

        printf \
          '{"mode":"%s","tier":"%s","budgetState":"%s","capacityPercent":%d,"energyNowUWh":%d,"energyFullUWh":%d,"powerNowUW":%d,"averagePowerUW":%d,"targetPowerUW":%d,"estimatedSeconds":%d,"targetSeconds":%d,"cpuMaxPercent":%d}\n' \
          "$mode" "$tier" "$budget_state" "$capacity" "$energy_now_uwh" \
          "$energy_full_uwh" "$power_now_uw" "$average_uw" "$budget_uw" \
          "$estimate_seconds" "$target_seconds" "$cpu_cap" > "$tmp"
        ${pkgs.coreutils}/bin/mv -f "$tmp" "$runtime_dir/status.json"
      }

      if (( ac_online == 1 )); then
        "$tlp_bin" ac
        ${pkgs.coreutils}/bin/rm -f "$state_file"

        if (( battery_count > 0 && capacity > 90 )); then
          for policy in "$sysfs_root"/devices/system/cpu/cpufreq/policy*; do
            [[ -d "$policy" ]] || continue
            [[ -w "$policy/scaling_governor" ]] &&
              printf '%s\n' performance > "$policy/scaling_governor"
            [[ -w "$policy/energy_performance_preference" ]] &&
              printf '%s\n' performance > "$policy/energy_performance_preference"
          done

          [[ -w "$sysfs_root/devices/system/cpu/intel_pstate/max_perf_pct" ]] &&
            printf '%s\n' 100 > "$sysfs_root/devices/system/cpu/intel_pstate/max_perf_pct"
          [[ -w "$sysfs_root/devices/system/cpu/intel_pstate/min_perf_pct" ]] &&
            printf '%s\n' 100 > "$sysfs_root/devices/system/cpu/intel_pstate/min_perf_pct"
          [[ -w "$sysfs_root/devices/system/cpu/intel_pstate/no_turbo" ]] &&
            printf '%s\n' 0 > "$sysfs_root/devices/system/cpu/intel_pstate/no_turbo"

          if [[ -r "$sysfs_root/firmware/acpi/platform_profile_choices" &&
            -w "$sysfs_root/firmware/acpi/platform_profile" ]]; then
            read -r profile_choices < "$sysfs_root/firmware/acpi/platform_profile_choices"
            if [[ " $profile_choices " == *" performance "* ]]; then
              printf '%s\n' performance > "$sysfs_root/firmware/acpi/platform_profile"
            fi
          fi
          write_status "ac" "performance" "unlimited" "$power_now_uw" 0 0 0 100
        else
          write_status "ac" "balanced" "unlimited" "$power_now_uw" 0 0 0 100
        fi
        exit 0
      fi

      "$tlp_bin" bat

      if (( capacity > 90 )); then
        tier="above-90"
        ceiling=75
        floor=30
        minimum=10
        epp="balance_power"
      elif (( capacity > 50 )); then
        tier="50-to-90"
        ceiling=60
        floor=20
        minimum=8
        epp="power"
      elif (( capacity > 20 )); then
        tier="20-to-50"
        ceiling=45
        floor=15
        minimum=5
        epp="power"
      else
        tier="at-or-below-20"
        ceiling=30
        floor=10
        minimum=5
        epp="power"
      fi

      previous_average=0
      previous_tier=""
      previous_cap=0
      previous_timestamp=0
      if [[ -r "$state_file" ]]; then
        read -r previous_average previous_tier previous_cap previous_timestamp < "$state_file" || true
      fi

      state_is_fresh=0
      if (( previous_timestamp > 0 && EPOCHSECONDS >= previous_timestamp &&
        EPOCHSECONDS - previous_timestamp <= 600 )); then
        state_is_fresh=1
      fi

      average_uw=$power_now_uw
      if (( power_now_uw > 0 && previous_average > 0 && state_is_fresh == 1 )); then
        # 30% current sample + 70% history rejects short workload spikes.
        average_uw=$((power_now_uw * 3 / 10 + previous_average * 7 / 10))
      elif (( power_now_uw == 0 && previous_average > 0 && state_is_fresh == 1 )); then
        average_uw=$previous_average
      fi

      target_power_uw=0
      target_seconds=0
      estimated_seconds=0
      budget_state="unknown"
      desired_cap=$ceiling
      control_base=$ceiling
      if (( state_is_fresh == 1 )) && [[ "$previous_tier" == "$tier" ]] &&
        (( previous_cap >= floor && previous_cap <= ceiling )); then
        control_base=$previous_cap
      fi

      if (( energy_full_uwh > 0 )); then
        # Six hours from the battery's current full-charge capacity.
        target_power_uw=$((energy_full_uwh / 6))
        target_seconds=$((energy_now_uwh * 21600 / energy_full_uwh))
      fi

      if (( target_power_uw > 0 && average_uw > 0 )); then
        if (( average_uw > target_power_uw )); then
          budget_state="over-budget"
          # Multiplicative feedback converges even when non-CPU power is fixed.
          desired_cap=$((control_base * target_power_uw / average_uw))
          (( desired_cap < floor )) && desired_cap=$floor
        else
          budget_state="on-target"
        fi

        estimate_power_uw=$average_uw
        (( estimate_power_uw < target_power_uw )) && estimate_power_uw=$target_power_uw
        estimated_seconds=$((energy_now_uwh * 3600 / estimate_power_uw))
      fi

      cpu_cap=$desired_cap
      if (( state_is_fresh == 1 )) && [[ "$previous_tier" == "$tier" ]] &&
        (( previous_cap >= floor && previous_cap <= ceiling )); then
        # Fast reduction, slow recovery: avoids oscillation while reacting to load.
        (( cpu_cap < previous_cap - 10 )) && cpu_cap=$((previous_cap - 10))
        (( cpu_cap > previous_cap + 5 )) && cpu_cap=$((previous_cap + 5))
        (( cpu_cap < floor )) && cpu_cap=$floor
        (( cpu_cap > ceiling )) && cpu_cap=$ceiling
      fi

      for policy in "$sysfs_root"/devices/system/cpu/cpufreq/policy*; do
        [[ -d "$policy" ]] || continue
        [[ -w "$policy/scaling_governor" ]] &&
          printf '%s\n' powersave > "$policy/scaling_governor"
        [[ -w "$policy/energy_performance_preference" ]] &&
          printf '%s\n' "$epp" > "$policy/energy_performance_preference"
      done

      [[ -w "$sysfs_root/devices/system/cpu/intel_pstate/min_perf_pct" ]] &&
        printf '%s\n' "$minimum" > "$sysfs_root/devices/system/cpu/intel_pstate/min_perf_pct"
      [[ -w "$sysfs_root/devices/system/cpu/intel_pstate/max_perf_pct" ]] &&
        printf '%s\n' "$cpu_cap" > "$sysfs_root/devices/system/cpu/intel_pstate/max_perf_pct"
      [[ -w "$sysfs_root/devices/system/cpu/intel_pstate/no_turbo" ]] &&
        printf '%s\n' 1 > "$sysfs_root/devices/system/cpu/intel_pstate/no_turbo"

      if [[ -r "$sysfs_root/firmware/acpi/platform_profile_choices" &&
        -w "$sysfs_root/firmware/acpi/platform_profile" ]]; then
        read -r profile_choices < "$sysfs_root/firmware/acpi/platform_profile_choices"
        if [[ " $profile_choices " == *" low-power "* ]]; then
          printf '%s\n' low-power > "$sysfs_root/firmware/acpi/platform_profile"
        fi
      fi

      printf '%d %s %d %d\n' "$average_uw" "$tier" "$cpu_cap" "$EPOCHSECONDS" > "$state_file"
      write_status "battery" "$tier" "$budget_state" "$average_uw" \
        "$target_power_uw" "$estimated_seconds" "$target_seconds" "$cpu_cap"
    '';
  };
in
{
  # Baseline tuning, thermal control, and sleep policy live in sibling modules.
  systemd.services.power-policy-refresh = {
    description = "Apply adaptive six-hour power budget";
    after = [ "tlp.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = lib.getExe refreshPowerPolicy;
      StateDirectory = "power-policy";
      RuntimeDirectory = "power-policy";
      RuntimeDirectoryPreserve = "yes";
      UMask = "0022";
    };
  };

  systemd.timers.power-policy-refresh = {
    description = "Refresh adaptive battery power policy";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "30s";
      OnUnitActiveSec = "1min";
      AccuracySec = "10s";
      Persistent = true;
      Unit = "power-policy-refresh.service";
    };
  };

  services.udev.extraRules = ''
    ACTION=="change", SUBSYSTEM=="power_supply", TAG+="systemd", ENV{SYSTEMD_WANTS}+="power-policy-refresh.service"
  '';
}
