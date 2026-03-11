#!/usr/bin/env bash
set -euo pipefail

require_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "[collections-preflight] Required command '$cmd' not found" >&2
    exit 1
  fi
}

require_collection() {
  local collection_name="$1"
  local collection_output="$2"

  if ! printf '%s\n' "$collection_output" | grep -Fq "\"$collection_name\""; then
    echo "[collections-preflight] Required collection '$collection_name' is missing." >&2
    echo "[collections-preflight] Install dependencies with: ansible-galaxy collection install -r provisioning/collections.yml" >&2
    exit 1
  fi
}

require_cmd ansible-galaxy

collections_output="$(ansible-galaxy collection list --format json 2>/dev/null || true)"

if [[ -z "$collections_output" ]]; then
  echo "[collections-preflight] Unable to list installed Ansible collections." >&2
  exit 1
fi

require_collection "ansible.windows" "$collections_output"
require_collection "community.general" "$collections_output"
require_collection "community.windows" "$collections_output"

echo "[collections-preflight] Required Ansible collections are installed." >&2
