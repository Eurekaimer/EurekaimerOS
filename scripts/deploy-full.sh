#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=deploy-common.sh
source "$script_dir/deploy-common.sh"

deploy_full regenerate
