#!/usr/bin/env bash
set -euo pipefail

# Generate only hardware-configuration.nix.  Host policy such as proxy, data
# disks, USB quirks, and power settings belongs in the neighbouring host files
# and is intentionally never inferred or overwritten here.
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
repo_root="$(cd -- "$script_dir/.." && pwd -P)"
output="$repo_root/hosts/nixos/hardware-configuration.nix"
graphics_output="$repo_root/hosts/nixos/hardware-extra.nix"
use_sudo=auto
language=""
graphics=""

usage() {
  cat <<'EOF'
Usage: generate-hardware.sh [--output PATH] [--graphics generic|intel]
                            [--graphics-output PATH] [--language zh|en]
                            [--sudo | --no-sudo]

Generate a NixOS hardware module and install it atomically at PATH. The default
is hosts/nixos/hardware-configuration.nix inside the current clone.

The script backs up existing destinations. It never detects or chooses a GPU
driver automatically: select generic or Intel explicitly. It does not edit
host-local.nix, mounts.nix, power.nix, proxy-local.nix, or software selection.
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
    --graphics-output)
      [[ $# -ge 2 ]] || {
        echo "--graphics-output requires a path." >&2
        exit 2
      }
      graphics_output=$2
      shift 2
      ;;
    --graphics)
      [[ $# -ge 2 && ( "$2" == generic || "$2" == intel ) ]] || {
        echo "--graphics must be generic or intel." >&2
        exit 2
      }
      graphics=$2
      shift 2
      ;;
    --language)
      [[ $# -ge 2 && ( "$2" == zh || "$2" == en ) ]] || {
        echo "--language must be zh or en." >&2
        exit 2
      }
      language=$2
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

choose_language() {
  [[ -n "$language" ]] && return
  [[ -t 0 ]] || {
    echo "Non-interactive use requires --language zh|en and --graphics generic|intel." >&2
    exit 2
  }
  printf '%s\n' \
    '请选择界面语言 / Choose interface language:' \
    '  1) 中文' \
    '  2) English'
  while true; do
    read -r -p '> ' reply
    case "$reply" in
      1|zh|ZH|中文) language=zh; return ;;
      2|en|EN|English|english) language=en; return ;;
      *) echo '请输入 1 或 2 / Enter 1 or 2.' ;;
    esac
  done
}

message() {
  if [[ "$language" == zh ]]; then
    printf '%s' "$1"
  else
    printf '%s' "$2"
  fi
}

choose_graphics() {
  [[ -n "$graphics" ]] && return
  [[ -t 0 ]] || {
    echo "Non-interactive use requires --graphics generic|intel." >&2
    exit 2
  }
  printf '\n%s\n' "$(message '请选择额外图形驱动；脚本不会自动探测：' 'Choose graphics extras; the script will not auto-detect:')"
  printf '%s\n' \
    "$(message '  1) Generic（AMD/通用 Mesa；NVIDIA 需之后手工配置）' '  1) Generic (AMD/general Mesa; configure NVIDIA manually)')" \
    "$(message '  2) Intel（intel-media-driver / VAAPI）' '  2) Intel (intel-media-driver / VAAPI)')"
  while true; do
    read -r -p '> ' reply
    case "$reply" in
      1|generic) graphics=generic; return ;;
      2|intel) graphics=intel; return ;;
      *) printf '%s\n' "$(message '请输入 1 或 2。' 'Enter 1 or 2.')" ;;
    esac
  done
}

choose_language
choose_graphics

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

output="$(realpath -m -- "$output")"
graphics_output="$(realpath -m -- "$graphics_output")"
output_dir="$(dirname -- "$output")"
graphics_output_dir="$(dirname -- "$graphics_output")"
tmp_file="$(mktemp)"
destination_command_for() {
  local destination=$1
  local probe_dir
  probe_dir="$(dirname -- "$destination")"
  while [[ ! -e "$probe_dir" && "$probe_dir" != / ]]; do
    probe_dir="$(dirname -- "$probe_dir")"
  done
  if [[ "$use_sudo" == yes || ( "$use_sudo" == auto && ! -w "$probe_dir" ) ]]; then
    printf 'sudo'
  fi
}

as_destination() {
  local destination=$1
  shift
  local command
  command="$(destination_command_for "$destination")"
  if [[ -n "$command" ]]; then
    "$command" "$@"
  else
    "$@"
  fi
}

stage="${output}.tmp.$$"
cleanup() {
  rm -f -- "$tmp_file"
  as_destination "$stage" rm -f -- "$stage" 2>/dev/null || true
  if [[ -n "${graphics_stage:-}" ]]; then
    as_destination "$graphics_stage" rm -f -- "$graphics_stage" 2>/dev/null || true
  fi
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
  as_destination "$backup" cp -a -- "$output" "$backup"
  printf 'Previous hardware module: %s\n' "$backup"
fi

as_destination "$output_dir" mkdir -p -- "$output_dir"
as_destination "$stage" install -m 0644 -- "$tmp_file" "$stage"
as_destination "$output" mv -f -- "$stage" "$output"
rm -f -- "$tmp_file"

case "$graphics" in
  generic) graphics_source="$repo_root/hosts/nixos/hardware-extra-generic.nix" ;;
  intel) graphics_source="$repo_root/hosts/nixos/hardware-extra-intel.nix" ;;
esac

as_destination "$graphics_output_dir" mkdir -p -- "$graphics_output_dir"
if [[ -e "$graphics_output" ]]; then
  graphics_backup="$graphics_output.backup-$(date +%Y%m%d-%H%M%S)"
  as_destination "$graphics_backup" cp -a -- "$graphics_output" "$graphics_backup"
  printf 'Previous graphics module: %s\n' "$graphics_backup"
fi
graphics_stage="${graphics_output}.tmp.$$"
as_destination "$graphics_stage" install -m 0644 -- "$graphics_source" "$graphics_stage"
as_destination "$graphics_output" mv -f -- "$graphics_stage" "$graphics_output"
trap - EXIT

printf '%s\n' \
  "Hardware module written to: $output" \
  "Graphics module written to: $graphics_output ($graphics)" \
  '' \
  'Review these machine-specific items separately:' \
  '  - hosts/nixos/host-local.nix (hostname/firewall/USB quirks)' \
  '  - hosts/nixos/host-local.nix (resume swap and data disks)' \
  '  - modules/system/power/ (portable power and sleep policy)' \
  '' \
  'Then validate with: nix flake check'
