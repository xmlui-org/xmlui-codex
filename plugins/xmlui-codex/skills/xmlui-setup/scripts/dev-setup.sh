#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/common.sh"

usage() {
  cat <<'EOF'
Usage: dev-setup.sh [OPTIONS]

Options:
  --template=NAME         XMLUI demo template (default: xmlui-weather)
  --project-name=NAME     Name of the project directory to create (default: xmlui-weather)
  --no-run                Do not start the dev server after scaffolding
  -h, --help              Show this message
EOF
}

TEMPLATE="xmlui-weather"
PROJECT_NAME="xmlui-weather"
NO_RUN="no"

for arg in "$@"; do
  case "${arg}" in
    --template=*) TEMPLATE="${arg#--template=}" ;;
    --project-name=*) PROJECT_NAME="${arg#--project-name=}" ;;
    --no-run) NO_RUN="yes" ;;
    -h|--help) usage; exit 0 ;;
    *) fail "Unknown argument: ${arg}" ;;
  esac
done

CLI_PATH="$(get_xmlui_command || true)"
if [[ -z "${CLI_PATH}" ]]; then
  fail "xmlui CLI is not available. Run install-cli first."
fi

if [[ -e "${PROJECT_NAME}" ]]; then
  warn "Directory '${PROJECT_NAME}' already exists. Skipping project init."
else
  log "Creating project: ${CLI_PATH} new ${TEMPLATE} --output ${PROJECT_NAME}"
  "${CLI_PATH}" new "${TEMPLATE}" --output "${PROJECT_NAME}"
fi

log "Project ready: ${PROJECT_NAME}"
log "To start the dev server, run:"
log "  cd ${PROJECT_NAME}"
log "  ${CLI_PATH} run"

if [[ "${NO_RUN}" == "yes" ]]; then
  log "Skipping dev server start because --no-run was provided."
  exit 0
fi

DEV_URL="$(get_xmlui_dev_url)"
if probe_http_url "${DEV_URL}"; then
  log "Existing dev server already responds at ${DEV_URL}"
  log "Skipping a second xmlui run for: ${PROJECT_NAME}"
  exit 0
fi

RESOLVED_PROJECT_PATH="$(cd "${PROJECT_NAME}" && pwd)"
LOG_PATH="${RESOLVED_PROJECT_PATH}/.xmlui-codex-dev.log"
ORIGINAL_PWD="$(pwd)"

log "Starting dev server in background..."
cd "${RESOLVED_PROJECT_PATH}"
if command -v nohup >/dev/null 2>&1; then
  nohup "${CLI_PATH}" run >"${LOG_PATH}" 2>&1 &
else
  "${CLI_PATH}" run >"${LOG_PATH}" 2>&1 &
fi
SERVER_PID=$!
cd "${ORIGINAL_PWD}"

if wait_for_http_url "${DEV_URL}" 15; then
  log "Dev server is responding at ${DEV_URL}"
  log "Dev server started for: ${RESOLVED_PROJECT_PATH}"
  exit 0
fi

if kill -0 "${SERVER_PID}" >/dev/null 2>&1; then
  warn "Started xmlui run (pid ${SERVER_PID}), but no response arrived from ${DEV_URL} within 15 seconds."
else
  warn "xmlui run exited before ${DEV_URL} became reachable."
fi
fail "Dev server did not become ready. Check ${LOG_PATH}."
