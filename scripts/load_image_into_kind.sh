#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

require_prereqs

IMAGE_TO_LOAD="${1:-${APP_IMAGE}}"

if ! cluster_exists; then
    echo "Kind cluster '${CLUSTER_NAME}' does not exist." >&2
    exit 1
fi

"${KIND_BIN}" load docker-image "${IMAGE_TO_LOAD}" --name "${CLUSTER_NAME}"
echo "Loaded ${IMAGE_TO_LOAD} into kind cluster ${CLUSTER_NAME}"
