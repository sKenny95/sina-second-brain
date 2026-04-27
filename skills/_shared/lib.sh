#!/usr/bin/env bash
# Shared helpers for /brain-* skills. Source from a skill's runner.sh.

set -euo pipefail

BRAIN_ROOT="${BRAIN_ROOT:-$HOME/Code_Sandbox/sina-2nd-brain}"
OPERATIONAL_DIR="${OPERATIONAL_DIR:-$BRAIN_ROOT/sina-operational-wiki}"
VOICENOTES_DIR="${VOICENOTES_DIR:-$BRAIN_ROOT/sina-voicenotes-wiki}"

today() { date +%Y-%m-%d; }
now()   { date +"%Y-%m-%d %H:%M"; }
host()  { hostname | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]//g'; }

# Pull --rebase a repo. Exits 1 on conflict.
brain_pull() {
  local repo="$1"
  ( cd "$repo" && git pull --rebase ) || {
    echo "ERROR: rebase conflict in $repo. Resolve manually then rerun." >&2
    exit 1
  }
}

# Append a log line to operational log.md.
brain_log() {
  local skill="$1"; shift
  local desc="$*"
  printf '## [%s] %s | %s\n' "$(now)" "$skill" "$desc" >> "$OPERATIONAL_DIR/log.md"
}

# Commit + push in a repo. Args: repo, message.
brain_commit_push() {
  local repo="$1" msg="$2"
  ( cd "$repo" && git add -A && git diff --cached --quiet || git commit -m "$msg" && git push )
}
