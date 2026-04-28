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
  --project-name=NAME     Output project directory (default: ./xmlui-weather)
  --no-run                Accepted for backward compatibility; this script no longer starts a dev server
  -h, --help              Show this message
EOF
}

TEMPLATE="xmlui-weather"
PROJECT_NAME="xmlui-weather"

for arg in "$@"; do
  case "${arg}" in
    --template=*) TEMPLATE="${arg#--template=}" ;;
    --project-name=*) PROJECT_NAME="${arg#--project-name=}" ;;
    --no-run) ;;
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

RESOLVED_PROJECT_PATH="$(cd "${PROJECT_NAME}" && pwd)"

log "Project ready: ${RESOLVED_PROJECT_PATH}"
log "To start the dev server, run this in a separate terminal:"
log "  cd ${RESOLVED_PROJECT_PATH} && ${CLI_PATH} run"
