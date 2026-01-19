#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LA_DIR="${HOME}/Library/LaunchAgents"

ALL_KEYS_STR="watch serve mcp tmux menu"
ON_LIST="watch,serve,mcp,tmux,menu"
OFF_LIST=""
DO_INSTALL=1
MODE="apply"
DRY_RUN=0

usage() {
  cat <<'USAGE'
Usage: mfm-launchagents.sh [options]

Options:
  --on list        Comma list of agents to enable (watch,serve,mcp,tmux,menu,all)
  --off list       Comma list of agents to disable (watch,serve,mcp,tmux,menu,all)
  --install        Copy plists into ~/Library/LaunchAgents (default)
  --no-install     Skip copying plists
  --status         Show launchctl status for my--father-mother agents
  --remove         Unload agents and remove plists from ~/Library/LaunchAgents
  --dry-run        Print actions without running them
  -h, --help       Show this help

Examples:
  ./scripts/mfm-launchagents.sh --on all
  ./scripts/mfm-launchagents.sh --on watch,serve,mcp --off tmux,menu
  ./scripts/mfm-launchagents.sh --off all
  ./scripts/mfm-launchagents.sh --status
USAGE
}

log() {
  echo "[mfm-launchagents] $*"
}

plist_for() {
  case "$1" in
    watch) echo "${REPO_DIR}/com.my-father-mother.watch.plist" ;;
    serve) echo "${REPO_DIR}/com.my-father-mother.serve.plist" ;;
    mcp) echo "${REPO_DIR}/com.my-father-mother.mcp.plist" ;;
    tmux) echo "${REPO_DIR}/com.my-father-mother.tmux.plist" ;;
    menu) echo "${REPO_DIR}/com.my-father-mother.menu.plist" ;;
    *) return 1 ;;
  esac
}

label_for() {
  case "$1" in
    watch) echo "com.my-father-mother.watch" ;;
    serve) echo "com.my-father-mother.serve" ;;
    mcp) echo "com.my-father-mother.mcp" ;;
    tmux) echo "com.my-father-mother.tmux" ;;
    menu) echo "com.my-father-mother.menu" ;;
    *) return 1 ;;
  esac
}

is_valid_key() {
  case "$1" in
    watch|serve|mcp|tmux|menu) return 0 ;;
    *) return 1 ;;
  esac
}

have_rg() {
  command -v rg >/dev/null 2>&1
}

show_status() {
  log "launchctl list (filtered)"
  if have_rg; then
    launchctl list | rg 'my-father-mother' || true
  else
    launchctl list | grep -i 'my-father-mother' || true
  fi
  log "installed plists in ${LA_DIR}"
  if have_rg; then
    ls -1 "${LA_DIR}" | rg 'my-father-mother' || true
  else
    ls -1 "${LA_DIR}" | grep -i 'my-father-mother' || true
  fi
}

is_loaded() {
  local label="$1"
  if have_rg; then
    launchctl list | rg -q "[[:space:]]${label}$" && return 0
  else
    launchctl list | grep -q "[[:space:]]${label}$" && return 0
  fi
  return 1
}

normalize_list() {
  local raw="$1"
  if [[ -z "${raw}" ]]; then
    echo ""
    return 0
  fi
  if echo "${raw}" | tr ',' ' ' | grep -qw "all"; then
    echo "${ALL_KEYS_STR}"
    return 0
  fi
  local out=""
  local item
  for item in $(echo "${raw}" | tr ',' ' '); do
    item="${item// /}"
    [[ -z "${item}" ]] && continue
    if ! is_valid_key "${item}"; then
      echo "Unknown agent key: ${item}" >&2
      exit 1
    fi
    out="${out}${item} "
  done
  echo "${out}"
}

bootstrap_agent() {
  local key="$1"
  local plist_src
  plist_src="$(plist_for "${key}")"
  local plist="${LA_DIR}/$(basename "${plist_src}")"
  local label
  label="$(label_for "${key}")"
  if (( DRY_RUN )); then
    log "bootstrap gui/${UID} ${plist}"
    return 0
  fi
  launchctl bootstrap "gui/${UID}" "${plist}" 2>/tmp/mfm-launchagents.err || true
  if is_loaded "${label}"; then
    log "bootstrap ok: ${label}"
    return 0
  fi
  launchctl load "${plist}" 2>>/tmp/mfm-launchagents.err || true
  if is_loaded "${label}"; then
    log "load ok: ${label}"
    return 0
  fi
  log "failed to load ${label}. See /tmp/mfm-launchagents.err"
  return 1
}

bootout_agent() {
  local key="$1"
  local plist_src
  plist_src="$(plist_for "${key}")"
  local plist="${LA_DIR}/$(basename "${plist_src}")"
  local label
  label="$(label_for "${key}")"
  if (( DRY_RUN )); then
    log "bootout gui/${UID} ${plist}"
    return 0
  fi
  launchctl bootout "gui/${UID}" "${plist}" 2>/tmp/mfm-launchagents.err || true
  if ! is_loaded "${label}"; then
    log "bootout ok: ${label}"
    return 0
  fi
  launchctl unload "${plist}" 2>>/tmp/mfm-launchagents.err || true
  if ! is_loaded "${label}"; then
    log "unload ok: ${label}"
    return 0
  fi
  log "failed to unload ${label}. See /tmp/mfm-launchagents.err"
  return 1
}

is_in_list() {
  local needle="$1"
  shift
  case " $* " in
    *" ${needle} "*) return 0 ;;
    *) return 1 ;;
  esac
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --on)
      ON_LIST="${2:-}"
      shift 2
      ;;
    --off)
      OFF_LIST="${2:-}"
      shift 2
      ;;
    --install)
      DO_INSTALL=1
      shift
      ;;
    --no-install)
      DO_INSTALL=0
      shift
      ;;
    --status)
      MODE="status"
      shift
      ;;
    --remove)
      MODE="remove"
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown arg: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ "${MODE}" == "status" ]]; then
  show_status
  exit 0
fi

mkdir -p "${LA_DIR}"
if (( DO_INSTALL )); then
  for key in ${ALL_KEYS_STR}; do
    plist_src="$(plist_for "${key}")"
    if (( DRY_RUN )); then
      log "copy ${plist_src} -> ${LA_DIR}"
    else
      cp "${plist_src}" "${LA_DIR}/"
    fi
  done
fi

ON_KEYS_STR="$(normalize_list "${ON_LIST}")"
OFF_KEYS_STR="$(normalize_list "${OFF_LIST}")"

if [[ "${MODE}" == "remove" ]]; then
  for key in ${ALL_KEYS_STR}; do
    bootout_agent "${key}" || true
    if (( DRY_RUN )); then
      log "remove ${LA_DIR}/$(basename "$(plist_for "${key}")")"
    else
      rm -f "${LA_DIR}/$(basename "$(plist_for "${key}")")"
    fi
  done
  show_status
  exit 0
fi

if [[ -n "${OFF_KEYS_STR}" ]]; then
  for key in ${OFF_KEYS_STR}; do
    bootout_agent "${key}" || true
  done
fi

if [[ -n "${ON_KEYS_STR}" ]]; then
  for key in ${ON_KEYS_STR}; do
    if [[ -n "${OFF_KEYS_STR}" ]] && is_in_list "${key}" ${OFF_KEYS_STR}; then
      log "skip ${key} (explicitly off)"
      continue
    fi
    bootstrap_agent "${key}" || true
  done
fi

show_status
