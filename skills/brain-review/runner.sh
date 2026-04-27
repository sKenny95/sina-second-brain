#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT/skills/_shared/lib.sh"

if [[ $# -lt 1 ]]; then
  echo "usage: brain-review <slug> < <session-body-on-stdin>" >&2
  exit 2
fi

slug="$1"
body="$(cat)"
filename="$(today)-$(host)-$slug.md"
target="$OPERATIONAL_DIR/sessions/$filename"

brain_pull "$OPERATIONAL_DIR"

cat > "$target" <<EOF
---
date: $(today)
machine: $(host)
slug: $slug
project: null
---

$body
EOF

brain_log "brain-review" "session: $slug"
brain_commit_push "$OPERATIONAL_DIR" "brain-review: $slug"
echo "wrote $target"
