#!/usr/bin/env bash
set -euo pipefail

trap 'echo "[export_quiz_report] Error on line ${LINENO}" >&2' ERR

SCRIPT_NAME="export_quiz_report"

usage() {
  echo "Usage: $0 course_identifier output_file" >&2
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
  if [[ $# -ne 2 ]]; then
    usage
    exit 1
  fi

  require_commands curl
  require_env REP_REPORTING_API_BASE
  require_env REP_API_TOKEN

  local course_id="$1"
  local output_file="$2"

  if [[ -z "$course_id" ]]; then
    echo "[$SCRIPT_NAME] Course identifier cannot be empty" >&2
    exit 1
  fi

  local export_path="${REP_REPORTING_EXPORT_PATH:-quiz/reports}"
  local endpoint
  endpoint=$(join_url "$REP_REPORTING_API_BASE" "$export_path/$course_id")

  mkdir -p "$(dirname "$output_file")"

  curl -sS -f \
    -H "Authorization: Bearer $REP_API_TOKEN" \
    -H "Accept: application/json" \
    -o "$output_file" \
    "$endpoint"

  echo "[$SCRIPT_NAME] Quiz report saved to $output_file"
}

main "$@"
