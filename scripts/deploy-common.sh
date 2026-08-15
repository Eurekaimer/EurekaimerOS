#!/usr/bin/env bash
set -euo pipefail

# `$PWD` is safe in a quoted flake command because the calling shell expands it
# before sudo starts. Scripts use BASH_SOURCE instead so they also work from
# outside the clone's current working directory.
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
repo_root="$(cd -- "$script_dir/.." && pwd -P)"
target="${EUREKAIMEROS_TARGET:-/etc/nixos}"
root_command=()
[[ "$target" == /etc/nixos ]] && root_command=(sudo)

as_root() {
  "${root_command[@]}" "$@"
}

require_clone() {
  if [[ "$repo_root" == "$target" ]]; then
    echo "Run deployment scripts from a EurekaimerOS clone outside $target." >&2
    exit 1
  fi
  [[ -f "$repo_root/flake.nix" ]] || {
    echo "flake.nix not found under $repo_root" >&2
    exit 1
  }
}

print_rebuild() {
  printf '\nDeployment complete. Activate it with:\n'
  printf '  sudo nixos-rebuild switch --flake %s#nixos\n' "$target"
}

deploy_full() {
  local hardware_mode=$1
  local stage="${target}.deploy.$$"
  local backup="${target}.backup-$(date +%Y%m%d-%H%M%S)"
  local old_moved=false

  require_clone

  cleanup_full() {
    as_root rm -rf -- "$stage"
    if $old_moved && [[ ! -e "$target" && -e "$backup" ]]; then
      as_root mv -- "$backup" "$target"
    fi
  }
  trap cleanup_full EXIT

  as_root install -d -m 0755 -- "$stage"
  as_root cp -a -- "$repo_root/." "$stage/"
  as_root rm -rf -- "$stage/.git" "$stage/result"
  as_root find "$stage" -name '*.backup*' -delete

  # New machines start without this computer's mounts, proxy, or kernel quirks.
  as_root cp -- "$repo_root/hosts/nixos/host-generic.nix" \
    "$stage/hosts/nixos/host-local.nix"
  as_root cp -- "$repo_root/hosts/nixos/proxy-disabled.nix" \
    "$stage/hosts/nixos/proxy-local.nix"
  as_root cp -- "$repo_root/hosts/nixos/hardware-extra-generic.nix" \
    "$stage/hosts/nixos/hardware-extra.nix"

  case "$hardware_mode" in
    regenerate)
      hardware_source="${EUREKAIMEROS_HARDWARE_CONFIG:-}"
      if [[ -z "$hardware_source" ]]; then
        for candidate in \
          "$target/hosts/nixos/hardware-configuration.nix" \
          "$target/hardware-configuration.nix" \
          /etc/nixos/hosts/nixos/hardware-configuration.nix \
          /etc/nixos/hardware-configuration.nix; do
          if [[ -f "$candidate" ]]; then
            hardware_source=$candidate
            break
          fi
        done
      fi

      if [[ -n "$hardware_source" ]]; then
        as_root cp -a -- "$hardware_source" \
          "$stage/hosts/nixos/hardware-configuration.nix"
      else
        as_root nixos-generate-config --show-hardware-config |
          as_root tee "$stage/hosts/nixos/hardware-configuration.nix" >/dev/null
      fi

      for vendor_file in /sys/class/drm/card*/device/vendor; do
        [[ -r "$vendor_file" ]] || continue
        read -r vendor < "$vendor_file"
        if [[ "$vendor" == 0x8086 ]]; then
          as_root cp -- "$repo_root/hosts/nixos/hardware-extra.nix" \
            "$stage/hosts/nixos/hardware-extra.nix"
          break
        fi
      done
      ;;
    preserve)
      if [[ ! -f "$target/hosts/nixos/hardware-configuration.nix" ]]; then
        echo "No existing hardware configuration found under $target." >&2
        exit 1
      fi
      for host_file in hardware-configuration.nix hardware-extra.nix host-local.nix proxy-local.nix; do
        if [[ -f "$target/hosts/nixos/$host_file" ]]; then
          as_root cp -a -- "$target/hosts/nixos/$host_file" \
            "$stage/hosts/nixos/$host_file"
        fi
      done
      ;;
    *)
      echo "Unknown hardware mode: $hardware_mode" >&2
      exit 1
      ;;
  esac

  if [[ -e "$target" ]]; then
    as_root mv -- "$target" "$backup"
    old_moved=true
  fi
  as_root mv -- "$stage" "$target"
  old_moved=false
  trap - EXIT

  [[ -e "$backup" ]] && printf 'Previous configuration: %s\n' "$backup"
  print_rebuild
}

begin_partial() {
  require_clone
  [[ -d "$target" ]] || {
    echo "$target does not exist; use deploy-full.sh first." >&2
    exit 1
  }
  partial_backup="${target}.partial-backup-$(date +%Y%m%d-%H%M%S)"
  as_root install -d -m 0755 -- "$partial_backup"
}

copy_item() {
  local relative=$1
  local source="$repo_root/$relative"
  local destination="$target/$relative"
  local backup_destination="$partial_backup/$relative"

  [[ -e "$source" ]] || {
    echo "Source item does not exist: $relative" >&2
    exit 1
  }

  if [[ -e "$destination" || -L "$destination" ]]; then
    as_root install -d -m 0755 -- "$(dirname -- "$backup_destination")"
    as_root cp -a -- "$destination" "$backup_destination"
  fi

  as_root rm -rf -- "$destination"
  as_root install -d -m 0755 -- "$(dirname -- "$destination")"
  as_root cp -a -- "$source" "$destination"
  as_root find "$destination" -name '*.backup*' -delete
}

finish_partial() {
  printf 'Partial backup: %s\n' "$partial_backup"
  print_rebuild
}
