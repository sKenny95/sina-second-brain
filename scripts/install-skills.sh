#!/usr/bin/env bash
# Install all /brain-* skills to ~/.claude/skills/.
# Idempotent — safe to re-run after edits.

set -euo pipefail
shopt -s nullglob

UMBRELLA_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_SRC="$UMBRELLA_DIR/skills"
SKILLS_DEST="$HOME/.claude/skills"

if [[ ! -d "$SKILLS_SRC" ]]; then
  echo "ERROR: $SKILLS_SRC does not exist." >&2
  exit 1
fi

mkdir -p "$SKILLS_DEST"

count=0
for skill_dir in "$SKILLS_SRC"/*/; do
  skill_name="$(basename "$skill_dir")"
  dest="$SKILLS_DEST/$skill_name"
  rm -rf "$dest"
  cp -R "$skill_dir" "$dest"
  echo "installed: $skill_name -> $dest"
  count=$((count + 1))
done

echo
echo "$count skill(s) installed to $SKILLS_DEST"
