#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
ROOT="$(cd "$SKILL_DIR/../.." && pwd)"
source "$ROOT/skills/_shared/test-helpers.sh"

tmp=$(make_fixture_operational); mktrap "$tmp"

today=$(date +%Y-%m-%d)
instruction="$(mktemp)"
sed "s/FIXTURE_TODAY/$today/" "$SCRIPT_DIR/sample-instruction.json" > "$instruction"

OPERATIONAL_DIR="$tmp" bash "$SKILL_DIR/runner.sh" "$instruction"

assert_file_exists "$tmp/projects/auth-rewrite.md"
assert_file_contains "$tmp/projects/auth-rewrite.md" "wired auth middleware"
assert_file_contains "$tmp/projects/auth-rewrite.md" "need to add tests"
assert_file_contains "$tmp/projects/auth-rewrite.md" "status: active"
assert_file_contains "$tmp/projects/auth-rewrite.md" "last_touched: $today"

assert_file_exists "$tmp/daily/$today.md"
assert_file_contains "$tmp/daily/$today.md" "wired auth middleware"

assert_file_contains "$tmp/_index.md" "auth-rewrite"
assert_log_has "$tmp" "brain-consolidate"

pass "brain-consolidate creates project, fills daily, regenerates index"
