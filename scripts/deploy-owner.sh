#!/usr/bin/env bash
set -euo pipefail

# Restore the repository owner's committed machine configuration exactly.
# Do not use this profile on another machine: it intentionally includes disk
# UUIDs, resume swap, USB quirks, the Intel graphics module, and local proxy.
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=deploy-common.sh
source "$script_dir/deploy-common.sh"

deploy_full owner
