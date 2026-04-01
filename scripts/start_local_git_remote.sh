#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

REMOTE_ROOT="${REMOTE_ROOT:-/tmp/gitops-remote}"
REMOTE_NAME="${REMOTE_NAME:-local-demo}"
REMOTE_REPO_NAME="${REMOTE_REPO_NAME:-self-healing-cicd-gitops.git}"
REMOTE_REPO_PATH="${REMOTE_ROOT}/${REMOTE_REPO_NAME}"
REMOTE_HOST="${REMOTE_HOST:-172.22.0.1}"
REMOTE_URL="git://${REMOTE_HOST}/${REMOTE_REPO_NAME}"
PID_FILE="${REMOTE_ROOT}/git-daemon.pid"
LOG_FILE="${REMOTE_ROOT}/git-daemon.log"

require_prereqs
mkdir -p "${REMOTE_ROOT}"

if [[ ! -d "${REMOTE_REPO_PATH}" ]]; then
    git init --bare "${REMOTE_REPO_PATH}"
    git --git-dir="${REMOTE_REPO_PATH}" symbolic-ref HEAD refs/heads/main
fi

if ! git -C "${ROOT_DIR}" remote | grep -qx "${REMOTE_NAME}"; then
    git -C "${ROOT_DIR}" remote add "${REMOTE_NAME}" "${REMOTE_REPO_PATH}"
fi

git -C "${ROOT_DIR}" push "${REMOTE_NAME}" main

if [[ -f "${PID_FILE}" ]] && kill -0 "$(cat "${PID_FILE}")" 2>/dev/null; then
    echo "Git daemon already running for ${REMOTE_URL}"
else
    nohup git daemon \
        --reuseaddr \
        --base-path="${REMOTE_ROOT}" \
        --export-all \
        --informative-errors \
        --verbose \
        --listen=0.0.0.0 \
        --port=9418 \
        "${REMOTE_ROOT}" >"${LOG_FILE}" 2>&1 &
    echo $! > "${PID_FILE}"
    sleep 1
fi

echo "${REMOTE_URL}"
