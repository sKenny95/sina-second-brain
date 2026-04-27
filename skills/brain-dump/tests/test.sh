#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
ROOT="$(cd "$SKILL_DIR/../.." && pwd)"

source "$ROOT/skills/_shared/test-helpers.sh"

tmp=$(make_fixture_operational)
mktrap "$tmp"

OPERATIONAL_DIR="$tmp" bash "$SKILL_DIR/runner.sh" "ship the auth feature this week"

today=$(date +%Y-%m-%d)
assert_file_exists "$tmp/inbox/$today.md"
assert_file_contains "$tmp/inbox/$today.md" "ship the auth feature this week"
assert_log_has "$tmp" "brain-dump"
assert_log_has "$tmp" "ship the auth feature this week"

# Verify a commit was made
( cd "$tmp" && git log --oneline | grep -q "brain-dump" ) || { echo "FAIL: no brain-dump commit"; exit 1; }

pass "brain-dump appends, logs, commits"
