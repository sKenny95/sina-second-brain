#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT/skills/_shared/lib.sh"

[[ $# -ge 1 ]] || { echo "usage: brain-ask \"<question>\"" >&2; exit 2; }
question="$*"

# Pull each wiki if its origin is reachable; never fail if offline.
for repo in "$OPERATIONAL_DIR" "$VOICENOTES_DIR"; do
  if [[ -d "$repo/.git" ]]; then
    ( cd "$repo" && git pull --rebase --quiet 2>/dev/null ) || true
  fi
done

q_lower=$(echo "$question" | tr '[:upper:]' '[:lower:]')

emit_match() {
  local file="$1"
  echo "=== $file ==="
  head -c 2000 "$file"
  echo
  echo
}

scan() {
  local root="$1"
  [[ -d "$root" ]] || return 0
  while IFS= read -r f; do
    if tr '[:upper:]' '[:lower:]' < "$f" | grep -qF "$q_lower" 2>/dev/null; then
      emit_match "$f"
    fi
  done < <(find "$root" -name '*.md' -type f 2>/dev/null)
}

# Always include _index.md if present
[[ -f "$OPERATIONAL_DIR/_index.md" ]] && emit_match "$OPERATIONAL_DIR/_index.md"

# Token-based scan: also match individual question words against project titles
for word in $q_lower; do
  [[ ${#word} -ge 4 ]] || continue
  while IFS= read -r f; do
    tr '[:upper:]' '[:lower:]' < "$f" | grep -qF "$word" 2>/dev/null && echo "$f" || true
  done < <(find "$OPERATIONAL_DIR/projects" "$OPERATIONAL_DIR/areas" -name '*.md' -type f 2>/dev/null) | sort -u | while read -r match; do
    emit_match "$match"
  done
done | awk '!seen[$0]++'

brain_log "brain-ask" "$question"
# brain-ask is read-only — no commit unless log changed
( cd "$OPERATIONAL_DIR" && git add log.md && git -c user.email=brain@local -c user.name=brain commit -q -m "brain-ask: log query" 2>/dev/null && git push -q 2>/dev/null ) || true
