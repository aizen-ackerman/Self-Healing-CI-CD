#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

require_prereqs

echo "[Kubernetes]"
kubectl get all -n "${APP_NAMESPACE}"
echo
echo "[Argo CD]"
kubectl get applications -n "${ARGOCD_NAMESPACE}" 2>/dev/null || true
