#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT/skills/_shared/lib.sh"

[[ $# -ge 1 ]] || { echo "usage: brain-process <instruction.json>" >&2; exit 2; }
instruction="$1"
command -v jq >/dev/null || { echo "jq required" >&2; exit 3; }

brain_pull "$OPERATIONAL_DIR"

date_str="$(jq -r .date "$instruction")"
[[ "$date_str" == "$(today)" ]] || { echo "instruction date != today" >&2; exit 4; }

routings=$(jq '.routings | length' "$instruction")

mk_target() {
  local slug="$1" title="$2" status="$3"
  local kind="projects"
  local f="$OPERATIONAL_DIR/$kind/$slug.md"
  if [[ ! -f "$f" ]]; then
    cat > "$f" <<EOF
---
title: $title
slug: $slug
status: $status
created: $(today)
updated: $(today)
last_touched: $(today)
due: null
related: []
---

## Summary
*(to be filled in)*

## Open Loops

## Done

## Notes

## Cross-references
EOF
  fi
  echo "$f"
}

for i in $(seq 0 $((routings - 1))); do
  bullet=$(jq -r ".routings[$i].bullet" "$instruction")
  dest=$(jq -r ".routings[$i].destination" "$instruction")
  slug=$(jq -r ".routings[$i].slug" "$instruction")
  title=$(jq -r ".routings[$i].title" "$instruction")
  section=$(jq -r ".routings[$i].section" "$instruction")
  case "$dest" in
    project) status="active" ;;
    someday) status="someday" ;;
    area)    status="active" ;;
    daily)
      daily="$OPERATIONAL_DIR/daily/$(today).md"
      [[ -f "$daily" ]] || printf '# %s\n\n## Intent\n\n## Done\n\n## Notes\n' "$(today)" > "$daily"
      python3 - "$daily" "$bullet" "$section" <<'PY'
import sys, pathlib
p = pathlib.Path(sys.argv[1]); line = sys.argv[2]; section = sys.argv[3]
text = p.read_text()
text = text.replace(f'## {section}\n', f'## {section}\n- {line}\n', 1)
p.write_text(text)
PY
      continue ;;
    *) echo "unknown destination: $dest" >&2; exit 5 ;;
  esac

  target=$(mk_target "$slug" "$title" "$status")
  python3 - "$target" "$bullet" "$section" <<'PY'
import sys, pathlib
p = pathlib.Path(sys.argv[1]); line = sys.argv[2]; section = sys.argv[3]
text = p.read_text()
text = text.replace(f'## {section}\n', f'## {section}\n- {line}\n', 1)
p.write_text(text)
PY
done

# Clear inbox if requested
if [[ "$(jq -r '.clear_inbox' "$instruction")" == "true" ]]; then
  inbox="$OPERATIONAL_DIR/inbox/$(today).md"
  if [[ -f "$inbox" ]]; then
    printf '# Inbox %s\n\n*(triaged at %s)*\n' "$(today)" "$(now)" > "$inbox"
  fi
fi

brain_log "brain-process" "$routings bullets routed"
brain_commit_push "$OPERATIONAL_DIR" "brain-process: $(today)"
echo "processed $routings bullets"
