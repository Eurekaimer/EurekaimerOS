#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=deploy-common.sh
source "$script_dir/deploy-common.sh"

begin_partial
copy_item flake.nix
copy_item flake.lock
copy_item modules/system/software.nix
copy_item modules/system/packages
copy_item modules/home/software.nix
copy_item modules/home/applications.nix
copy_item modules/home/applications
copy_item modules/home/development.nix
copy_item modules/home/development
copy_item modules/home/config/mpv-config
copy_item modules/home/config/nvim-config
finish_partial
