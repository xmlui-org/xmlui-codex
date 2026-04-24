#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CREATE_PROJECT="no"
SKIP_PROJECT_PROMPT="no"
TEMPLATE="xmlui-weather"
PROJECT_NAME=""
NO_RUN="no"
DEFAULT_PROJECT_PATH="${HOME}/xmlui-weather"
CWD_PROJECT_PATH="$(pwd)/xmlui-weather"

usage() {
  cat <<'EOF'
Usage: xmlui-setup.sh [OPTIONS]

Options:
  --create-project         Scaffold a starter project without prompting
  --skip-project-prompt    Do not ask about scaffolding at the end
  --template=NAME          Template for project creation (default: xmlui-weather)
  --project-name=NAME      Output directory name (default: ~/xmlui-weather)
  --no-run                 Do not start the dev server after scaffolding
  -h, --help               Show this message
EOF
}

for arg in "$@"; do
  case "${arg}" in
    --create-project) CREATE_PROJECT="yes" ;;
    --skip-project-prompt) SKIP_PROJECT_PROMPT="yes" ;;
    --template=*) TEMPLATE="${arg#--template=}" ;;
    --project-name=*) PROJECT_NAME="${arg#--project-name=}" ;;
    --no-run) NO_RUN="yes" ;;
    -h|--help) usage; exit 0 ;;
    *) echo "[xmlui-codex] ERROR: Unknown argument: ${arg}" >&2; exit 1 ;;
  esac
done

if [[ -z "${PROJECT_NAME}" ]]; then
  PROJECT_NAME="${DEFAULT_PROJECT_PATH}"
fi

if [[ "${PROJECT_NAME}" == "~" ]]; then
  PROJECT_NAME="${HOME}"
elif [[ "${PROJECT_NAME}" == ~/* ]]; then
  PROJECT_NAME="${HOME}/${PROJECT_NAME#~/}"
fi

"${SCRIPT_DIR}/preflight.sh"

if ! command -v xmlui >/dev/null 2>&1; then
  "${SCRIPT_DIR}/install-cli.sh"
fi

"${SCRIPT_DIR}/configure-mcp.sh"

if [[ "${CREATE_PROJECT}" == "yes" ]]; then
  if [[ "${NO_RUN}" == "yes" ]]; then
    "${SCRIPT_DIR}/dev-setup.sh" --template="${TEMPLATE}" --project-name="${PROJECT_NAME}" --no-run
  else
    "${SCRIPT_DIR}/dev-setup.sh" --template="${TEMPLATE}" --project-name="${PROJECT_NAME}"
  fi
elif [[ "${SKIP_PROJECT_PROMPT}" != "yes" ]]; then
  if [[ -t 0 && -t 1 ]]; then
    read -r -p "Scaffold starter project (${TEMPLATE})? [Y/n] " scaffold_answer
    if [[ "${scaffold_answer,,}" == n* ]]; then
      echo "[xmlui-codex] Skipping starter project scaffolding."
      exit 0
    fi

    echo "[xmlui-codex] Choose where to create the starter project"
    echo "[xmlui-codex] Recommended: ${DEFAULT_PROJECT_PATH}"
    echo "[xmlui-codex] Alternative (current directory): ${CWD_PROJECT_PATH}"
    read -r -p "Project path [${PROJECT_NAME}] " project_answer
    if [[ -n "${project_answer}" ]]; then
      PROJECT_NAME="${project_answer}"
      if [[ "${PROJECT_NAME}" == "~" ]]; then
        PROJECT_NAME="${HOME}"
      elif [[ "${PROJECT_NAME}" == ~/* ]]; then
        PROJECT_NAME="${HOME}/${PROJECT_NAME#~/}"
      fi
    fi
    if [[ "${NO_RUN}" == "yes" ]]; then
      "${SCRIPT_DIR}/dev-setup.sh" --template="${TEMPLATE}" --project-name="${PROJECT_NAME}" --no-run
    else
      "${SCRIPT_DIR}/dev-setup.sh" --template="${TEMPLATE}" --project-name="${PROJECT_NAME}"
    fi
  else
    echo "[xmlui-codex] Non-interactive shell detected; skipping automatic scaffolding."
    echo "[xmlui-codex] Scaffold prompt: create starter project from '${TEMPLATE}' at '${DEFAULT_PROJECT_PATH}' (default)."
    echo "[xmlui-codex] To scaffold now, rerun with --create-project [--project-name=<path>]."
    echo "[xmlui-codex] To explicitly skip this prompt behavior, rerun with --skip-project-prompt."
  fi
fi
