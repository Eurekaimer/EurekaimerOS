#!/usr/bin/env bash
set -euo pipefail

# Generate only hardware-configuration.nix.  Host policy such as proxy, data
# disks, USB quirks, and power settings belongs in the neighbouring host files
# and is intentionally never inferred or overwritten here.
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
repo_root="$(cd -- "$script_dir/.." && pwd -P)"
output="$repo_root/hosts/nixos/hardware-configuration.nix"
use_sudo=auto

usage() {
  cat <<'EOF'
Usage: generate-hardware.sh [--output PATH] [--sudo | --no-sudo]

Generate a NixOS hardware module and install it atomically at PATH. The default
is hosts/nixos/hardware-configuration.nix inside the current clone.

The script backs up an existing destination. It does not edit host-local.nix,
mounts.nix, power.nix, proxy-local.nix, or software-selection.nix.
EOF
}

while (( $# > 0 )); do
  case "$1" in
    --output)
      [[ $# -ge 2 ]] || {
        echo "--output requires a path." >&2
        exit 2
      }
      output=$2
      shift 2
      ;;
    --sudo)
      use_sudo=yes
      shift
      ;;
    --no-sudo)
      use_sudo=no
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown argument: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

command -v nixos-generate-config >/dev/null 2>&1 || {
  echo "nixos-generate-config was not found; run this script on NixOS." >&2
  exit 1
}

generator=(nixos-generate-config --show-hardware-config)
if [[ "$use_sudo" == yes || ( "$use_sudo" == auto && $EUID -ne 0 ) ]]; then
  command -v sudo >/dev/null 2>&1 || {
    echo "sudo was not found; retry as root or pass --no-sudo." >&2
    exit 1
  }
  generator=(sudo "${generator[@]}")
fi

output_dir="$(dirname -- "$output")"
tmp_file="$(mktemp)"
destination_command=()
write_probe_dir=$output_dir
while [[ ! -e "$write_probe_dir" && "$write_probe_dir" != / ]]; do
  write_probe_dir="$(dirname -- "$write_probe_dir")"
done

# Keep files in a user-owned clone user-owned.  Use sudo for destination I/O
# only when explicitly requested or when the existing destination directory is
# not writable (for example /etc/nixos).
if [[ "$use_sudo" == yes || ( "$use_sudo" == auto && ! -w "$write_probe_dir" ) ]]; then
  destination_command=(sudo)
fi

as_destination() {
  "${destination_command[@]}" "$@"
}

stage="${output}.tmp.$$"
cleanup() {
  rm -f -- "$tmp_file"
  as_destination rm -f -- "$stage" 2>/dev/null || true
}
trap cleanup EXIT

"${generator[@]}" > "$tmp_file"

[[ -s "$tmp_file" ]] || {
  echo "nixos-generate-config produced an empty file." >&2
  exit 1
}

# Parse validation catches truncated output and Nix syntax errors before the
# existing hardware module is touched.
if command -v nix-instantiate >/dev/null 2>&1; then
  nix-instantiate --parse "$tmp_file" >/dev/null
fi

if [[ -e "$output" ]]; then
  backup="$output.backup-$(date +%Y%m%d-%H%M%S)"
  as_destination cp -a -- "$output" "$backup"
  printf 'Previous hardware module: %s\n' "$backup"
fi

as_destination mkdir -p -- "$output_dir"
as_destination install -m 0644 -- "$tmp_file" "$stage"
as_destination mv -f -- "$stage" "$output"
rm -f -- "$tmp_file"
trap - EXIT

printf '%s\n' \
  "Hardware module written to: $output" \
  '' \
  'Review these machine-specific items separately:' \
  '  - hosts/nixos/hardware-extra.nix (GPU extras)' \
  '  - hosts/nixos/host-local.nix (hostname/firewall/USB quirks)' \
  '  - hosts/nixos/host-local.nix (resume swap and host quirks)' \
  '  - modules/system/power/ (portable power and sleep policy)' \
  '  - modules/system/mounts.nix (data-disk UUIDs)' \
  '' \
  'Then validate with: nix flake check'
