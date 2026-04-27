#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
ROOT="$(cd "$SKILL_DIR/../.." && pwd)"
source "$ROOT/skills/_shared/test-helpers.sh"

tmp=$(make_fixture_operational); mktrap "$tmp"

body='## What got done
- wired auth middleware

## Open loops
- need to add tests'

OPERATIONAL_DIR="$tmp" bash "$SKILL_DIR/runner.sh" "auth-rewrite-jwt-spike" <<< "$body"

today=$(date +%Y-%m-%d)
host=$(hostname | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]//g')
session_file="$tmp/sessions/$today-$host-auth-rewrite-jwt-spike.md"
assert_file_exists "$session_file"
assert_file_contains "$session_file" "wired auth middleware"
assert_file_contains "$session_file" "machine: $host"
assert_log_has "$tmp" "brain-review"
( cd "$tmp" && git log --oneline | grep -q "brain-review" ) || { echo "FAIL: no commit"; exit 1; }
pass "brain-review writes session log with correct filename"
