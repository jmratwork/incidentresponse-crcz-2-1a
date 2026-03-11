#!/usr/bin/env bash
set -euo pipefail

require_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "[run_playbook] Required command '$cmd' not found" >&2
    exit 1
  fi
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PLAYBOOK="$SCRIPT_DIR/playbook.yml"
COLLECTIONS_FILE="$SCRIPT_DIR/collections.yml"
COLLECTIONS_PREFLIGHT="$SCRIPT_DIR/scripts/check_required_collections.sh"

require_cmd ansible-galaxy
require_cmd ansible-playbook
require_cmd wget
require_cmd virtualbmc

echo "[run_playbook] Installing required collections and running provisioning/playbook.yml." >&2
echo "[run_playbook] Use this wrapper instead of calling ansible-playbook directly on KYPO/CRCZ to avoid missing modules." >&2

if [[ $# -gt 0 ]]; then
  INVENTORY="$1"
  shift
else
  INVENTORY="$REPO_ROOT/inventory.ini"
fi

if [[ ! -f "$COLLECTIONS_FILE" ]]; then
  echo "[run_playbook] Collections file '$COLLECTIONS_FILE' not found" >&2
  exit 1
fi

if [[ ! -f "$PLAYBOOK" ]]; then
  echo "[run_playbook] Playbook '$PLAYBOOK' not found" >&2
  exit 1
fi

if [[ ! -f "$INVENTORY" ]]; then
  echo "[run_playbook] Inventory file '$INVENTORY' not found" >&2
  exit 1
fi

if [[ ! -x "$COLLECTIONS_PREFLIGHT" ]]; then
  echo "[run_playbook] Preflight script '$COLLECTIONS_PREFLIGHT' not found or not executable" >&2
  exit 1
fi

ansible-galaxy collection install -r "$COLLECTIONS_FILE"

ansible_windows_check="$(ansible-galaxy collection list ansible.windows --format json 2>/dev/null || true)"
if [[ -z "$ansible_windows_check" ]] || ! printf '%s\n' "$ansible_windows_check" | grep -Fq '"ansible.windows"'; then
  echo "[run_playbook] Required collection 'ansible.windows' is still missing after installation." >&2
  echo "[run_playbook] Verify access to Ansible Galaxy and rerun provisioning/run_playbook.sh." >&2
  exit 1
fi

"$COLLECTIONS_PREFLIGHT"

ansible-playbook -i "$INVENTORY" "$PLAYBOOK" "$@"
