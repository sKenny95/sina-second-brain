#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT/skills/_shared/lib.sh"

if [[ $# -lt 1 ]]; then
  echo "usage: brain-dump \"<thought>\"" >&2
  exit 2
fi

thought="$*"
inbox="$OPERATIONAL_DIR/inbox/$(today).md"

brain_pull "$OPERATIONAL_DIR"

# Create today's inbox file with header if absent
if [[ ! -f "$inbox" ]]; then
  printf '# Inbox %s\n\n' "$(today)" > "$inbox"
fi
printf -- '- [%s] %s\n' "$(now)" "$thought" >> "$inbox"

brain_log "brain-dump" "$thought"
brain_commit_push "$OPERATIONAL_DIR" "brain-dump: $(echo "$thought" | head -c 60)"

echo "dumped to $inbox"
