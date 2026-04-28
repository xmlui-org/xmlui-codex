#!/usr/bin/env bash

set -euo pipefail

MARKETPLACE_NAME="xmlui-codex"
PLUGIN_KEY='xmlui-codex@xmlui-codex'
CODEX_DIR="${HOME}/.codex"
CONFIG_PATH="${CODEX_DIR}/config.toml"
MARKETPLACE_CACHE_DIR="${CODEX_DIR}/.tmp/marketplaces/${MARKETPLACE_NAME}"
PLUGIN_CACHE_DIR="${CODEX_DIR}/plugins/cache/${MARKETPLACE_NAME}"
PLUGIN_DATA_DIR="${CODEX_DIR}/plugins/data/${MARKETPLACE_NAME}-${MARKETPLACE_NAME}"
LEGACY_PLUGIN_DATA_DIR="${CODEX_DIR}/plugins/data/${MARKETPLACE_NAME}"
DEFAULT_PROJECT_PATH="${HOME}/xmlui-weather"

APPLY_CHANGES="no"
NUCLEAR_RESET="no"
REMOVE_PROJECT="no"
PROJECT_PATH="${DEFAULT_PROJECT_PATH}"

log() {
  printf "[xmlui-reset] %s\n" "$*"
}

warn() {
  printf "[xmlui-reset] WARN: %s\n" "$*" >&2
}

usage() {
  cat <<'EOF'
Usage: xmlui-reset.sh [OPTIONS]

Reset locally persisted xmlui-codex state from ~/.codex.

Default mode is dry-run. Pass --apply to perform the reset.

Options:
  --apply                 Perform the reset. Without this flag, only print actions.
  --nuclear               Also remove Codex history, sessions, shell snapshots, and sqlite state/log DBs.
  --remove-project        Also remove the starter project directory.
  --project-path=PATH     Project directory to remove with --remove-project (default: ~/xmlui-weather).
  -h, --help              Show this message.

Examples:
  ./xmlui-reset.sh
  ./xmlui-reset.sh --apply
  ./xmlui-reset.sh --apply --nuclear
  ./xmlui-reset.sh --apply --remove-project --project-path=~/xmlui-weather
EOF
}

for arg in "$@"; do
  case "${arg}" in
    --apply) APPLY_CHANGES="yes" ;;
    --nuclear) NUCLEAR_RESET="yes" ;;
    --remove-project) REMOVE_PROJECT="yes" ;;
    --project-path=*) PROJECT_PATH="${arg#--project-path=}" ;;
    -h|--help) usage; exit 0 ;;
    *) warn "Unknown argument: ${arg}"; usage; exit 1 ;;
  esac
done

if [[ "${PROJECT_PATH}" == "~" ]]; then
  PROJECT_PATH="${HOME}"
elif [[ "${PROJECT_PATH}" == ~/* ]]; then
  PROJECT_PATH="${HOME}/${PROJECT_PATH#~/}"
fi

print_action() {
  local description="$1"
  if [[ "${APPLY_CHANGES}" == "yes" ]]; then
    log "${description}"
  else
    log "Would ${description}"
  fi
}

remove_path() {
  local path="$1"
  if [[ -e "${path}" ]]; then
    print_action "remove ${path}"
    if [[ "${APPLY_CHANGES}" == "yes" ]]; then
      rm -rf "${path}"
    fi
  else
    log "Already absent: ${path}"
  fi
}

remove_plugin_block_from_config() {
  local config_path="$1"
  local tmp_path

  [[ -f "${config_path}" ]] || return 0

  tmp_path="$(mktemp)"
  awk '
    BEGIN { skip = 0 }
    /^\[plugins\."xmlui-codex@xmlui-codex"\]/ { skip = 1; next }
    skip && /^\[/ { skip = 0 }
    !skip { print }
  ' "${config_path}" >"${tmp_path}"

  if cmp -s "${config_path}" "${tmp_path}"; then
    rm -f "${tmp_path}"
    log "Plugin enabled-state block already absent in ${config_path}"
    return 0
  fi

  print_action "remove plugin enabled-state block from ${config_path}"
  if [[ "${APPLY_CHANGES}" == "yes" ]]; then
    mv "${tmp_path}" "${config_path}"
  else
    rm -f "${tmp_path}"
  fi
}

remove_marketplace_block_from_config() {
  local config_path="$1"
  local tmp_path

  [[ -f "${config_path}" ]] || return 0

  tmp_path="$(mktemp)"
  awk '
    BEGIN { skip = 0 }
    /^\[marketplaces\.xmlui-codex\]/ { skip = 1; next }
    skip && /^\[/ { skip = 0 }
    !skip { print }
  ' "${config_path}" >"${tmp_path}"

  if cmp -s "${config_path}" "${tmp_path}"; then
    rm -f "${tmp_path}"
    log "Marketplace block already absent in ${config_path}"
    return 0
  fi

  print_action "remove marketplace block from ${config_path}"
  if [[ "${APPLY_CHANGES}" == "yes" ]]; then
    mv "${tmp_path}" "${config_path}"
  else
    rm -f "${tmp_path}"
  fi
}

remove_marketplace_registration() {
  if ! command -v codex >/dev/null 2>&1; then
    warn "codex CLI not found; skipping 'codex plugin marketplace remove'."
    return 0
  fi

  print_action "run codex plugin marketplace remove ${MARKETPLACE_NAME}"
  if [[ "${APPLY_CHANGES}" == "yes" ]]; then
    if ! codex plugin marketplace remove "${MARKETPLACE_NAME}"; then
      warn "codex plugin marketplace remove ${MARKETPLACE_NAME} failed; continuing with file cleanup."
    fi
  fi
}

maybe_remove_plugin_managed_mcp() {
  local mcp_output

  if ! command -v codex >/dev/null 2>&1; then
    warn "codex CLI not found; skipping MCP server inspection."
    return 0
  fi

  mcp_output="$(codex mcp get xmlui 2>/dev/null || true)"
  if [[ -z "${mcp_output}" ]]; then
    log "No xmlui MCP server configured."
    return 0
  fi

  if [[ "${mcp_output}" == *".codex/plugins/data/xmlui-codex-xmlui-codex/bin/xmlui"* ]] \
     || [[ "${mcp_output}" == *".codex/plugins/data/xmlui-codex/bin/xmlui"* ]] \
     || [[ "${mcp_output}" == *".codex\\plugins\\data\\xmlui-codex-xmlui-codex\\bin\\xmlui.exe"* ]] \
     || [[ "${mcp_output}" == *".codex\\plugins\\data\\xmlui-codex\\bin\\xmlui.exe"* ]]; then
    print_action "run codex mcp remove xmlui"
    if [[ "${APPLY_CHANGES}" == "yes" ]]; then
      codex mcp remove xmlui
    fi
  else
    warn "An xmlui MCP server entry exists in config.toml but does not point at the plugin-managed CLI."
    warn "It will shadow the plugin's .mcp.json registration. To remove it: codex mcp remove xmlui"
  fi
}

log "Reset mode: $([[ "${APPLY_CHANGES}" == "yes" ]] && printf 'apply' || printf 'dry-run')"
log "Plugin data root: ${PLUGIN_DATA_DIR}"
if [[ "${NUCLEAR_RESET}" == "yes" ]]; then
  log "Nuclear reset enabled."
fi
if [[ "${REMOVE_PROJECT}" == "yes" ]]; then
  log "Project removal enabled for: ${PROJECT_PATH}"
fi
warn "Quit all Codex sessions before applying this reset."

remove_marketplace_registration
remove_marketplace_block_from_config "${CONFIG_PATH}"
remove_plugin_block_from_config "${CONFIG_PATH}"
maybe_remove_plugin_managed_mcp

remove_path "${MARKETPLACE_CACHE_DIR}"
remove_path "${PLUGIN_CACHE_DIR}"
remove_path "${PLUGIN_DATA_DIR}"
remove_path "${LEGACY_PLUGIN_DATA_DIR}"

if [[ "${REMOVE_PROJECT}" == "yes" ]]; then
  remove_path "${PROJECT_PATH}"
fi

if [[ "${NUCLEAR_RESET}" == "yes" ]]; then
  remove_path "${CODEX_DIR}/history.jsonl"
  remove_path "${CODEX_DIR}/sessions"
  remove_path "${CODEX_DIR}/shell_snapshots"
  remove_path "${CODEX_DIR}/state_5.sqlite"
  remove_path "${CODEX_DIR}/state_5.sqlite-shm"
  remove_path "${CODEX_DIR}/state_5.sqlite-wal"
  remove_path "${CODEX_DIR}/logs_2.sqlite"
  remove_path "${CODEX_DIR}/logs_2.sqlite-shm"
  remove_path "${CODEX_DIR}/logs_2.sqlite-wal"
fi

if [[ "${APPLY_CHANGES}" == "yes" ]]; then
  log "Reset complete."
  log "Next steps:"
  log "  1. Start a new Codex session."
  log "  2. Re-add the marketplace with: codex plugin marketplace add xmlui-org/xmlui-codex"
  log "  3. Re-enable the plugin in /plugins."
else
  log "Dry-run complete. Re-run with --apply to perform the reset."
fi
