#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
ROOT="$(cd "$SKILL_DIR/../.." && pwd)"
source "$ROOT/skills/_shared/test-helpers.sh"

tmp=$(make_fixture_operational); mktrap "$tmp"

today=$(date +%Y-%m-%d)
# seed inbox
printf '# Inbox %s\n\n- [12:00] ship the auth feature this week\n- [12:05] look into rust\n' "$today" > "$tmp/inbox/$today.md"
( cd "$tmp" && git add -A && git -c user.email=t@t -c user.name=t commit -q -m "seed inbox" )

instruction="$(mktemp)"
sed "s/FIXTURE_TODAY/$today/" "$SCRIPT_DIR/sample-instruction.json" > "$instruction"

OPERATIONAL_DIR="$tmp" bash "$SKILL_DIR/runner.sh" "$instruction"

assert_file_exists "$tmp/projects/auth-rewrite.md"
assert_file_contains "$tmp/projects/auth-rewrite.md" "ship the auth feature this week"
assert_file_contains "$tmp/projects/auth-rewrite.md" "status: active"
assert_file_exists "$tmp/projects/someday-rust.md"
assert_file_contains "$tmp/projects/someday-rust.md" "status: someday"
assert_file_contains "$tmp/projects/someday-rust.md" "look into rust"

# Inbox should be cleared (replaced with a header noting triaged)
assert_file_contains "$tmp/inbox/$today.md" "triaged"

assert_log_has "$tmp" "brain-process"
pass "brain-process triages bullets into projects with correct status"
