#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=deploy-common.sh
source "$script_dir/deploy-common.sh"

begin_partial
copy_item img
copy_item modules/system/desktop.nix
copy_item modules/system/locale.nix
copy_item modules/home/desktop.nix
copy_item modules/home/desktop
copy_item modules/home/core/ui.nix
copy_item modules/home/core/fastfetch.nix
copy_item modules/home/config/niri-config
copy_item modules/home/config/hyprlock-config
copy_item modules/home/config/noctalia-config
copy_item modules/home/config/fastfetch-config
copy_item modules/home/config/kitty-config
finish_partial
