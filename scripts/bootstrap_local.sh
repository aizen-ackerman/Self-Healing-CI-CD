#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

require_prereqs

if ! cluster_exists; then
    "${KIND_BIN}" create cluster --config "${ROOT_DIR}/kind/cluster.yaml" --name "${CLUSTER_NAME}"
fi

docker build -t "${APP_IMAGE}" "${ROOT_DIR}"
"${KIND_BIN}" load docker-image "${APP_IMAGE}" --name "${CLUSTER_NAME}"

kubectl apply -f "${ROOT_DIR}/k8s/namespace.yaml"
kubectl apply -f "${ROOT_DIR}/k8s/deployment.yaml"
kubectl apply -f "${ROOT_DIR}/k8s/service.yaml"
kubectl rollout status deployment/"${APP_NAME}" -n "${APP_NAMESPACE}" --timeout=180s

"${ROOT_DIR}/scripts/install_argocd.sh"

if manifest_contains_placeholder_repo; then
    echo "Argo CD is installed, but argocd/application.yaml still contains REPO_URL_PLACEHOLDER."
    echo "Run ./scripts/configure_gitops.sh <repo-url> [image-ref] [app-version] after your Git remote exists."
else
    kubectl apply -f "${ROOT_DIR}/argocd/application.yaml"
fi

echo "Local bootstrap completed."
echo "Application URL: http://127.0.0.1:8080"
echo "Argo CD URL: https://127.0.0.1:8081"
