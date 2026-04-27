#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT/skills/_shared/lib.sh"

apply_drops="${1:-}"  # pass --apply-drops to write status: dropped

brain_pull "$OPERATIONAL_DIR"

today_epoch=$(date +%s)
stale_days=30

stale=()
for f in "$OPERATIONAL_DIR/projects/"*.md "$OPERATIONAL_DIR/areas/"*.md; do
  [[ -f "$f" ]] || continue
  status=$(grep -m1 '^status:' "$f" | awk '{print $2}')
  [[ "$status" == "active" ]] || continue
  lt=$(grep -m1 '^last_touched:' "$f" | awk '{print $2}')
  [[ -n "$lt" ]] || continue
  lt_epoch=$(date -d "$lt" +%s 2>/dev/null || date -j -f '%Y-%m-%d' "$lt" +%s 2>/dev/null || echo "$today_epoch")
  age_days=$(( (today_epoch - lt_epoch) / 86400 ))
  if (( age_days > stale_days )); then
    stale+=("$f:$age_days")
  fi
done

# Prune dead cross-reference links (relative paths that don't resolve)
pruned=0
for f in "$OPERATIONAL_DIR/projects/"*.md "$OPERATIONAL_DIR/areas/"*.md; do
  [[ -f "$f" ]] || continue
  python3 - "$f" "$OPERATIONAL_DIR" <<'PY'
import sys, re, pathlib
p = pathlib.Path(sys.argv[1]); op = pathlib.Path(sys.argv[2])
text = p.read_text()
def is_dead(m):
    target = m.group(2)
    if target.startswith(('http://', 'https://', '#')): return False
    resolved = (p.parent / target).resolve()
    return not resolved.exists()
new_text, n = re.subn(r'^- \[(.*?)\]\((.+?)\)(.*)$', lambda m: '' if is_dead(m) else m.group(0), text, flags=re.M)
new_text = re.sub(r'\n{3,}', '\n\n', new_text)
if n:
    p.write_text(new_text)
    print(f'PRUNED in {p.name}: {n}')
PY
done

echo "=== STALE active items (> $stale_days days) ==="
if [[ ${#stale[@]} -eq 0 ]]; then
  echo "(none)"
else
  for s in "${stale[@]}"; do
    f="${s%%:*}"; age="${s##*:}"
    echo "- $(basename "$f") — last_touched $age days ago"
  done
fi

if [[ "$apply_drops" == "--apply-drops" && ${#stale[@]} -gt 0 ]]; then
  for s in "${stale[@]}"; do
    f="${s%%:*}"
    sed -i.bak 's/^status: active$/status: dropped/' "$f" && rm -f "$f.bak"
  done
  echo "Applied: ${#stale[@]} dropped."
fi

brain_log "brain-sweep" "${#stale[@]} stale, links pruned"
brain_commit_push "$OPERATIONAL_DIR" "brain-sweep: $(today) (${#stale[@]} stale)"
