#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() {
  printf "[xmlui-codex] %s\n" "$*"
}

warn() {
  printf "[xmlui-codex] WARN: %s\n" "$*" >&2
}

fail() {
  printf "[xmlui-codex] ERROR: %s\n" "$*" >&2
  exit 1
}

require_cmd() {
  local cmd="$1"
  command -v "${cmd}" >/dev/null 2>&1 || fail "Missing required command: ${cmd}"
}

detect_platform() {
  local os arch
  os="$(uname -s)"
  arch="$(uname -m)"

  case "${os}" in
    Darwin) PLATFORM_OS="darwin" ;;
    Linux) PLATFORM_OS="linux" ;;
    MINGW*|MSYS*|CYGWIN*) PLATFORM_OS="win" ;;
    *) fail "Unsupported OS: ${os}. Supported: macOS, Linux, Windows (Git Bash)." ;;
  esac

  case "${arch}" in
    x86_64|amd64) PLATFORM_ARCH="x64" ;;
    arm64|aarch64) PLATFORM_ARCH="arm64" ;;
    *) fail "Unsupported architecture: ${arch}. Supported: x64, arm64." ;;
  esac
}

get_xmlui_install_dir() {
  if [[ -n "${XMLUI_CLI_INSTALL_DIR:-}" ]]; then
    printf "%s\n" "${XMLUI_CLI_INSTALL_DIR}"
    return 0
  fi

  detect_platform
  if [[ "${PLATFORM_OS}" == "win" ]] && [[ -n "${USERPROFILE:-}" ]] && command -v cygpath >/dev/null 2>&1; then
    printf "%s\n" "$(cygpath -u "${USERPROFILE}")/.codex/plugins/data/xmlui-codex/bin"
    return 0
  fi

  printf "%s\n" "${HOME}/.codex/plugins/data/xmlui-codex/bin"
}

get_xmlui_cli_path() {
  local install_dir binary_name

  detect_platform
  install_dir="$(get_xmlui_install_dir)"
  if [[ "${PLATFORM_OS}" == "win" ]]; then
    binary_name="xmlui.exe"
  else
    binary_name="xmlui"
  fi

  printf "%s/%s\n" "${install_dir}" "${binary_name}"
}

get_xmlui_command() {
  local cli_path

  cli_path="$(get_xmlui_cli_path)"
  if [[ -x "${cli_path}" ]]; then
    printf "%s\n" "${cli_path}"
    return 0
  fi

  return 1
}

get_xmlui_registration_path() {
  local cli_path

  cli_path="$(get_xmlui_cli_path)"
  detect_platform
  if [[ "${PLATFORM_OS}" == "win" ]] && command -v cygpath >/dev/null 2>&1; then
    cygpath -w "${cli_path}"
    return 0
  fi

  printf "%s\n" "${cli_path}"
}

get_xmlui_dev_host() {
  printf "%s\n" "${XMLUI_DEV_HOST:-127.0.0.1}"
}

get_xmlui_dev_port() {
  printf "%s\n" "${XMLUI_DEV_PORT:-8080}"
}

get_xmlui_dev_url() {
  printf "http://%s:%s/\n" "$(get_xmlui_dev_host)" "$(get_xmlui_dev_port)"
}

probe_http_url() {
  local url="$1"
  curl --silent --output /dev/null --max-time 2 "${url}"
}

wait_for_http_url() {
  local url="$1"
  local timeout_seconds="${2:-15}"
  local attempt

  for ((attempt = 0; attempt < timeout_seconds; attempt += 1)); do
    if probe_http_url "${url}"; then
      return 0
    fi
    sleep 1
  done

  return 1
}
