#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/common.sh"

log "Configuring XMLUI MCP server for Codex"

require_cmd codex
CLI_PATH="$(get_xmlui_cli_path)"
REGISTRATION_PATH="$(get_xmlui_registration_path)"

if [[ ! -x "${CLI_PATH}" ]]; then
  fail "XMLUI CLI not found at ${CLI_PATH}. Run install-cli first."
fi

existing_config="$(codex mcp get xmlui 2>/dev/null || true)"
if [[ -n "${existing_config}" ]]; then
  if printf "%s\n" "${existing_config}" | grep -Fq "command: ${REGISTRATION_PATH}"; then
    log "MCP server 'xmlui' already configured with plugin-managed CLI"
    exit 0
  fi

  existing_command="$(printf "%s\n" "${existing_config}" | sed -n 's/^[[:space:]]*command:[[:space:]]*//p' | head -n 1)"

  if [[ -n "${existing_command}" ]] && ! command -v "${existing_command}" >/dev/null 2>&1; then
    warn "MCP server 'xmlui' command '${existing_command}' is not executable; replacing with plugin-managed CLI."
    codex mcp remove xmlui >/dev/null 2>&1 || fail "Failed to remove existing MCP server 'xmlui'."
  elif printf "%s\n" "${existing_config}" | grep -Eq '^[[:space:]]*args:[[:space:]]+mcp[[:space:]]*$'; then
    log "Updating MCP server 'xmlui' to use ${REGISTRATION_PATH}"
    codex mcp remove xmlui >/dev/null 2>&1 || fail "Failed to remove existing MCP server 'xmlui'."
  else
    warn "MCP server 'xmlui' already exists with a custom command or arguments; leaving it unchanged."
    warn "To point it at the plugin-managed CLI, run:"
    warn "  codex mcp remove xmlui"
    warn "  codex mcp add xmlui -- ${REGISTRATION_PATH} mcp"
    exit 0
  fi
fi

if codex mcp add xmlui -- "${REGISTRATION_PATH}" mcp >/dev/null 2>&1; then
  log "MCP server 'xmlui' configured with '${REGISTRATION_PATH} mcp'"
else
  fail "Failed to configure MCP with 'codex mcp add'."
fi

existing_config="$(codex mcp get xmlui 2>/dev/null || true)"
if printf "%s\n" "${existing_config}" | grep -Fq "command: ${REGISTRATION_PATH}"; then
  log "Verified MCP server 'xmlui'"
else
  fail "MCP server 'xmlui' not found after add attempt"
fi
