#!/usr/bin/env bash
# Test helpers for skill TDD. Source from a skill's tests/test.sh.

set -euo pipefail

# Make a throwaway operational repo with the same layout as the real one.
# Echoes the temp dir path. Caller is responsible for cleanup via mktrap.
make_fixture_operational() {
  local tmp
  tmp="$(mktemp -d)"
  mkdir -p "$tmp"/{inbox,daily,sessions,projects,areas}
  touch "$tmp"/inbox/.gitkeep "$tmp"/daily/.gitkeep "$tmp"/sessions/.gitkeep "$tmp"/projects/.gitkeep "$tmp"/areas/.gitkeep
  printf '# Operational Log\n\n' > "$tmp/log.md"
  printf '# Index\n\n## Projects\n*(none)*\n\n## Areas\n*(none)*\n' > "$tmp/_index.md"
  ( cd "$tmp" && git init -q -b main && \
    git config user.email "test@local" && \
    git config user.name "brain-test" && \
    git add -A && git commit -q -m init )
  # bare repo we can push to
  git init -q --bare "$tmp.git"
  ( cd "$tmp" && git remote add origin "$tmp.git" && git push -q -u origin main )
  echo "$tmp"
}

declare -a _MKTRAP_PATHS=()
_mktrap_cleanup() {
  local p
  for p in "${_MKTRAP_PATHS[@]}"; do
    [[ -e "$p" ]] && rm -rf "$p"
  done
}
mktrap() {
  _MKTRAP_PATHS+=("$1" "$1.git")
  trap _mktrap_cleanup EXIT
}

assert_file_contains() {
  local file="$1" needle="$2"
  if ! grep -qF "$needle" "$file"; then
    echo "FAIL: expected '$needle' in $file" >&2
    echo "--- file contents ---" >&2
    cat "$file" >&2
    exit 1
  fi
}

assert_file_exists() {
  local file="$1"
  [[ -f "$file" ]] || { echo "FAIL: missing $file" >&2; exit 1; }
}

assert_log_has() {
  local op_dir="$1" needle="$2"
  assert_file_contains "$op_dir/log.md" "$needle"
}

pass() { echo "PASS: $*"; }
