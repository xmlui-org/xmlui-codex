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

if ! command -v xmlui >/dev/null 2>&1; then
  fail "xmlui CLI is not available on PATH. Run install-cli first."
fi

if [[ -e "${PROJECT_NAME}" ]]; then
  warn "Directory '${PROJECT_NAME}' already exists. Skipping project init."
else
  log "Creating project: xmlui new ${TEMPLATE} --output ${PROJECT_NAME}"
  xmlui new "${TEMPLATE}" --output "${PROJECT_NAME}"
fi

log "Project ready: ${PROJECT_NAME}"
log "To start the dev server, run:"
log "  cd ${PROJECT_NAME}"
log "  xmlui run"

if [[ "${NO_RUN}" == "yes" ]]; then
  log "Skipping dev server start because --no-run was provided."
  exit 0
fi

log "Starting dev server in background..."
(
  cd "${PROJECT_NAME}"
  if command -v nohup >/dev/null 2>&1; then
    nohup xmlui run >/dev/null 2>&1 &
  else
    xmlui run >/dev/null 2>&1 &
  fi
)
log "Dev server started for: ${PROJECT_NAME}"
