#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=deploy-common.sh
source "$script_dir/deploy-common.sh"

begin_partial
copy_item flake.nix
copy_item flake.lock
# Deploy the choices made in this clone together with the selected modules.
copy_item hosts/nixos/software-selection.nix
copy_item hosts/nixos/configuration.nix
copy_item home/eurekaimer/home.nix
copy_item modules/system/software.nix
copy_item modules/system/personal.nix
copy_item modules/system/system.nix
copy_item modules/system/power.nix
copy_item modules/system/power
copy_item modules/system/users.nix
copy_item modules/system/desktop.nix
copy_item modules/system/virtualisation.nix
copy_item modules/system/packages
copy_item modules/home/software.nix
copy_item modules/home/core.nix
copy_item modules/home/core/shell.nix
copy_item modules/home/applications.nix
copy_item modules/home/applications
copy_item modules/home/development.nix
copy_item modules/home/development
copy_item modules/home/personal.nix
copy_item modules/home/personal
copy_item modules/home/config/mpv-config
copy_item modules/home/config/nvim-config
finish_partial
