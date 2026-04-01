#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

require_prereqs

REPO_URL="${1:-${REPO_URL:-}}"
IMAGE_REF="${2:-${IMAGE_REF:-}}"
APP_VERSION="${3:-${APP_VERSION:-}}"

if [[ -z "${REPO_URL}" ]]; then
    echo "Usage: $0 <repo-url> [image-ref] [app-version]" >&2
    echo "Example: $0 https://github.com/USER/self-healing-cicd-gitops.git docker.io/USER/self-healing-app:latest 1.0.0" >&2
    exit 1
fi

sed -i "s|REPO_URL_PLACEHOLDER|${REPO_URL}|g" "${ROOT_DIR}/argocd/application.yaml"

if [[ -n "${IMAGE_REF}" ]]; then
    sed -i "s|^[[:space:]]*image:.*|          image: ${IMAGE_REF}|" "${ROOT_DIR}/k8s/deployment.yaml"
fi

if [[ -n "${APP_VERSION}" ]]; then
    sed -i "s|value: \".*\"|value: \"${APP_VERSION}\"|" "${ROOT_DIR}/k8s/deployment.yaml"
fi

kubectl apply -f "${ROOT_DIR}/argocd/application.yaml"
echo "Argo CD application manifest has been configured and applied."
