#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
ROOT="$(cd "$SKILL_DIR/../.." && pwd)"
source "$ROOT/skills/_shared/test-helpers.sh"

tmp=$(make_fixture_operational); mktrap "$tmp"

# stale project (60 days old)
old_date=$(date -d '60 days ago' +%Y-%m-%d 2>/dev/null || date -v-60d +%Y-%m-%d)
cat > "$tmp/projects/old-thing.md" <<EOF
---
title: Old thing
slug: old-thing
status: active
created: $old_date
updated: $old_date
last_touched: $old_date
due: null
related: []
---

## Summary
old.
## Open Loops
## Done
## Notes
## Cross-references
- [dead](../sina-voicenotes-wiki/wiki/nonexistent.md) — never linked anywhere real
EOF

# fresh project
cat > "$tmp/projects/fresh.md" <<EOF
---
title: Fresh
slug: fresh
status: active
created: $(today)
updated: $(today)
last_touched: $(today)
due: null
related: []
---

## Summary
fresh.
## Open Loops
## Done
## Notes
## Cross-references
EOF

( cd "$tmp" && git add -A && git -c user.email=t@t -c user.name=t commit -q -m seed )

out=$(OPERATIONAL_DIR="$tmp" bash "$SKILL_DIR/runner.sh")
echo "$out" | grep -q "old-thing" || { echo "FAIL: stale project not flagged"; exit 1; }
echo "$out" | grep -q "fresh" && { echo "FAIL: fresh project incorrectly flagged"; exit 1; } || true

# Dead link should have been pruned
grep -q "dead" "$tmp/projects/old-thing.md" && { echo "FAIL: dead link not pruned"; exit 1; } || true

assert_log_has "$tmp" "brain-sweep"
pass "brain-sweep flags stale, prunes dead links, leaves fresh alone"
