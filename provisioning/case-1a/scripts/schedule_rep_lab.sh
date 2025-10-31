#!/usr/bin/env bash
set -euo pipefail

trap 'echo "[schedule_rep_lab] Error on line ${LINENO}" >&2' ERR

SCRIPT_NAME="schedule_rep_lab"

usage() {
  echo "Usage: $0 path/to/lab-schedule.json" >&2
}

require_commands() {
  local missing=()
  for cmd in "$@"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      missing+=("$cmd")
    fi
  done
  if ((${#missing[@]} > 0)); then
    echo "[$SCRIPT_NAME] Required command(s) missing: ${missing[*]}" >&2
    exit 1
  fi
}

require_env() {
  local name="$1"
  if [[ -z "${!name:-}" ]]; then
    echo "[$SCRIPT_NAME] Environment variable '$name' must be set" >&2
    exit 1
  fi
}

join_url() {
  local base="$1"
  local path="$2"
  if [[ "$base" == */ ]]; then
    base="${base%/}"
  fi
  if [[ "$path" == /* ]]; then
    path="${path#/}"
  fi
  echo "$base/$path"
}

main() {
  if [[ $# -ne 1 ]]; then
    usage
    exit 1
  fi

  require_commands curl
  require_env REP_SCHEDULER_API_BASE
  require_env REP_API_TOKEN

  local payload_path="$1"
  if [[ ! -f "$payload_path" ]]; then
    echo "[$SCRIPT_NAME] Lab payload '$payload_path' not found" >&2
    exit 1
  fi

  local schedule_path="${REP_SCHEDULER_SCHEDULE_PATH:-labs/schedule}"
  local endpoint
  endpoint=$(join_url "$REP_SCHEDULER_API_BASE" "$schedule_path")

  curl -sS -f -X POST \
    -H "Authorization: Bearer $REP_API_TOKEN" \
    -H "Content-Type: application/json" \
    --data-binary "@$payload_path" \
    "$endpoint" >/dev/null

  echo "[$SCRIPT_NAME] Lab scheduling request submitted to $endpoint"
}

main "$@"
