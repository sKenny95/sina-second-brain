#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
ROOT="$(cd "$SKILL_DIR/../.." && pwd)"
source "$ROOT/skills/_shared/test-helpers.sh"

tmp=$(make_fixture_operational); mktrap "$tmp"
vn_tmp="$(mktemp -d)"; mktrap "$vn_tmp"
mkdir -p "$vn_tmp/wiki"
echo "# wiki stub" > "$vn_tmp/wiki/_master-index.md"

# seed a project
today=$(date +%Y-%m-%d)
cat > "$tmp/projects/auth-rewrite.md" <<EOF
---
title: Auth rewrite
slug: auth-rewrite
status: active
created: $today
updated: $today
last_touched: $today
due: null
related: []
---

## Summary
Replacing legacy session middleware.

## Open Loops
- need to add tests

## Done
## Notes
## Cross-references
EOF
( cd "$tmp" && git add -A && git -c user.email=t@t -c user.name=t commit -q -m seed )

out=$(OPERATIONAL_DIR="$tmp" VOICENOTES_DIR="$vn_tmp" bash "$SKILL_DIR/runner.sh" "what is open on auth?")
echo "$out" | grep -q "auth-rewrite.md" || { echo "FAIL: no auth-rewrite in output"; exit 1; }
echo "$out" | grep -q "need to add tests" || { echo "FAIL: open loop excerpt missing"; exit 1; }

pass "brain-ask returns context bundle including matching project"
