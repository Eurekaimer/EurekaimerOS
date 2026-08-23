#!/usr/bin/env bash
set -euo pipefail

# Report the package lists produced by the current software selection.  Counts
# come from evaluated NixOS/Home Manager configuration rather than duplicated
# metadata, so they stay accurate when modules change.
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
repo_root="$(cd -- "$script_dir/.." && pwd -P)"
show_list=false

case "${1:-}" in
  "") ;;
  --list) show_list=true ;;
  -h|--help)
    cat <<'EOF'
Usage: software-report.sh [--list]

Show the number of explicitly selected system and Home Manager packages.
Pass --list to also print their evaluated package names.

System services such as Niri, PipeWire, Docker, and libvirt are documented
separately in software.md because they are not all members of a package list.
EOF
    exit 0
    ;;
  *)
    printf 'Unknown argument: %s\n' "$1" >&2
    exit 2
    ;;
esac

command -v nix >/dev/null 2>&1 || {
  echo "nix was not found." >&2
  exit 1
}

flake="$repo_root#nixosConfigurations.nixos.config"
system_path="$flake.environment.systemPackages"
home_path="$flake.home-manager.users.eurekaimer.home.packages"
count_expression='packages: builtins.toString (builtins.length packages)'
name_expression='packages: map (package: package.pname or package.name) packages'

system_count="$(nix eval --raw "$system_path" --apply "$count_expression")"
home_count="$(nix eval --raw "$home_path" --apply "$count_expression")"
total_count=$((system_count + home_count))

printf '%-24s %s\n' \
  'System package entries:' "$system_count" \
  'Home package entries:' "$home_count" \
  'Total package entries:' "$total_count"

if $show_list; then
  printf '\nSystem packages:\n'
  nix eval "$system_path" --apply "$name_expression"
  printf '\nHome Manager packages:\n'
  nix eval "$home_path" --apply "$name_expression"
fi
