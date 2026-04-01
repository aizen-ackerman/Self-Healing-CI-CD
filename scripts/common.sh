#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KIND_BIN="${ROOT_DIR}/.tools/bin/kind"
ARGOCD_BIN="${ROOT_DIR}/.tools/bin/argocd"

CLUSTER_NAME="${CLUSTER_NAME:-gitops-demo}"
APP_NAMESPACE="${APP_NAMESPACE:-demo-app}"
ARGOCD_NAMESPACE="${ARGOCD_NAMESPACE:-argocd}"
APP_NAME="${APP_NAME:-self-healing-app}"
APP_IMAGE="${APP_IMAGE:-self-healing-app:v1}"
BROKEN_IMAGE="${BROKEN_IMAGE:-self-healing-app:broken}"

require_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Missing required command: $1" >&2
        exit 1
    fi
}

require_prereqs() {
    require_command docker
    require_command kubectl
    require_command git

    if [[ ! -x "${KIND_BIN}" ]]; then
        echo "Kind binary not found at ${KIND_BIN}" >&2
        exit 1
    fi

    if [[ ! -x "${ARGOCD_BIN}" ]]; then
        echo "Argo CD binary not found at ${ARGOCD_BIN}" >&2
        exit 1
    fi
}

cluster_exists() {
    "${KIND_BIN}" get clusters | grep -qx "${CLUSTER_NAME}"
}

manifest_contains_placeholder_repo() {
    grep -q 'REPO_URL_PLACEHOLDER' "${ROOT_DIR}/argocd/application.yaml"
}
