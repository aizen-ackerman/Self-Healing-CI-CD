#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

FAIL_IMAGE="${1:-${BROKEN_IMAGE}}"
MANIFEST="${ROOT_DIR}/k8s/deployment.yaml"

sed -i "s|^[[:space:]]*image:.*|          image: ${FAIL_IMAGE}|" "${MANIFEST}"

git -C "${ROOT_DIR}" add k8s/deployment.yaml

if git -C "${ROOT_DIR}" diff --cached --quiet; then
    echo "No manifest change detected."
    exit 0
fi

git -C "${ROOT_DIR}" commit -m "Simulate broken deployment"
echo "Committed failing image '${FAIL_IMAGE}'. Push this commit to trigger the self-healing demo."
