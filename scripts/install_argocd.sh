#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

require_prereqs

kubectl create namespace "${ARGOCD_NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -
kubectl apply --server-side --force-conflicts -n "${ARGOCD_NAMESPACE}" -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl patch svc argocd-server -n "${ARGOCD_NAMESPACE}" -p '{"spec":{"type":"NodePort","ports":[{"name":"https","port":443,"protocol":"TCP","targetPort":8080,"nodePort":30443}]}}'

kubectl rollout status deployment/argocd-server -n "${ARGOCD_NAMESPACE}" --timeout=180s
kubectl rollout status deployment/argocd-repo-server -n "${ARGOCD_NAMESPACE}" --timeout=180s

echo "Argo CD is installed in namespace ${ARGOCD_NAMESPACE}"
echo "Start CLI access with:"
echo "kubectl port-forward svc/argocd-server -n ${ARGOCD_NAMESPACE} 8081:443"
