#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
ROOT="$(cd "$SKILL_DIR/../.." && pwd)"
source "$ROOT/skills/_shared/test-helpers.sh"

tmp=$(make_fixture_operational); mktrap "$tmp"
vn="$(mktemp -d)"; mktrap "$vn"

# voicenotes fixture
mkdir -p "$vn/wiki/security"
cat > "$vn/wiki/security/auth-thoughts.md" <<EOF
---
topic: security
updated: $(today)
source_count: 3
---

# Auth thoughts

Some content.

## Related
EOF
( cd "$vn" && git init -q -b main && \
  git config user.email "test@local" && git config user.name "brain-test" && \
  git add -A && git commit -q -m seed )
git init -q --bare "$vn.git"
( cd "$vn" && git remote add origin "$vn.git" && git push -q -u origin main )

# operational project
cat > "$tmp/projects/auth-rewrite.md" <<EOF
---
title: Auth rewrite
slug: auth-rewrite
status: active
created: $(today)
updated: $(today)
last_touched: $(today)
due: null
related: []
---

## Summary
Replacing legacy session middleware.
## Open Loops
## Done
## Notes
## Cross-references
EOF
( cd "$tmp" && git add -A && git -c user.email=t@t -c user.name=t commit -q -m seed )

OPERATIONAL_DIR="$tmp" VOICENOTES_DIR="$vn" bash "$SKILL_DIR/runner.sh" "$SCRIPT_DIR/sample-instruction.json"

# Op file is at sina-operational-wiki/projects/auth-rewrite.md (2 dirs deep), so link to vn needs ../..
assert_file_contains "$tmp/projects/auth-rewrite.md" "../../sina-voicenotes-wiki/wiki/security/auth-thoughts.md"
# Vn file is at sina-voicenotes-wiki/wiki/security/auth-thoughts.md (3 dirs deep), so link to op needs ../../..
assert_file_contains "$vn/wiki/security/auth-thoughts.md" "../../../sina-operational-wiki/projects/auth-rewrite.md"
assert_log_has "$tmp" "brain-cross-link"
pass "brain-cross-link adds bidirectional links and logs"
