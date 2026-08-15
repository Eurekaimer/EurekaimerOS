#!/usr/bin/env bash
set -euo pipefail

source_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
target=/etc/nixos
if [[ "$source_root" == "$target" ]]; then
  echo "Run this script from a EurekaimerOS clone outside $target." >&2
  exit 1
fi

stage="${target}.deploy.$$"
backup="${target}.backup-$(date +%Y%m%d-%H%M%S)"
hardware="$(mktemp)"
stage_created=false

cleanup() {
  rm -f -- "$hardware"
  if $stage_created; then
    sudo rm -rf -- "$stage"
  fi
}
trap cleanup EXIT

sudo nixos-generate-config --show-hardware-config >"$hardware"
sudo install -d -m 0755 -- "$stage"
stage_created=true
sudo cp -a -- "$source_root/." "$stage/"
sudo rm -rf -- "$stage/.git" "$stage/result"
sudo install -m 0644 -- "$hardware" "$stage/hosts/nixos/hardware-configuration.nix"

nix build "$stage#nixosConfigurations.nixos.config.system.build.toplevel" --no-link

if [[ -e "$target" ]]; then
  sudo mv -- "$target" "$backup"
fi

if ! sudo mv -- "$stage" "$target"; then
  if [[ -e "$backup" && ! -e "$target" ]]; then
    sudo mv -- "$backup" "$target"
  fi
  exit 1
fi
stage_created=false

printf 'Installed %s with regenerated hardware configuration.\n' "$target"
if [[ -e "$backup" ]]; then
  printf 'Previous configuration: %s\n' "$backup"
fi
