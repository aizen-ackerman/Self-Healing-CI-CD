#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

git -C "${ROOT_DIR}" revert --no-edit HEAD
echo "Created revert commit. Push it to restore the stable deployment through Argo CD."
