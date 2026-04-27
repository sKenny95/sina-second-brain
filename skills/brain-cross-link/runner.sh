#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT/skills/_shared/lib.sh"

[[ $# -ge 1 ]] || { echo "usage: brain-cross-link <instruction.json>" >&2; exit 2; }
instruction="$1"
command -v jq >/dev/null || { echo "jq required" >&2; exit 3; }

brain_pull "$OPERATIONAL_DIR"
[[ -d "$VOICENOTES_DIR/.git" ]] && brain_pull "$VOICENOTES_DIR"

n=$(jq '.links | length' "$instruction")
for i in $(seq 0 $((n - 1))); do
  op_rel=$(jq -r ".links[$i].operational" "$instruction")
  vn_rel=$(jq -r ".links[$i].voicenotes" "$instruction")
  why=$(jq -r ".links[$i].why" "$instruction")
  op_file="$OPERATIONAL_DIR/$op_rel"
  vn_file="$VOICENOTES_DIR/$vn_rel"
  [[ -f "$op_file" ]] || { echo "missing $op_file" >&2; exit 4; }
  [[ -f "$vn_file" ]] || { echo "missing $vn_file" >&2; exit 4; }

  op_title=$(grep -m1 '^title:' "$op_file" | sed 's/^title: //; s/^# //')
  vn_title=$(basename "$vn_rel" .md)

  # Link from op → vn (relative). Op file is 2 dirs deep (sina-operational-wiki/<projects|areas>/file.md),
  # so reach umbrella with ../.., then sibling repo.
  link_to_vn="../../sina-voicenotes-wiki/$vn_rel"
  if ! grep -qF "$link_to_vn" "$op_file"; then
    python3 - "$op_file" "$vn_title" "$link_to_vn" "$why" "Cross-references" <<'PY'
import sys, re, pathlib
p, title, link, why, section = (pathlib.Path(sys.argv[1]),) + tuple(sys.argv[2:6])
text = p.read_text()
addition = f'- [{title}]({link}) — {why}'
header = f'## {section}'
if header in text:
    pattern = re.compile(rf'({re.escape(header)}\s*\n)(.*?)(\n## |\Z)', re.S)
    def repl(m):
        body = m.group(2).rstrip()
        new = (body + '\n' if body else '') + addition + '\n'
        return m.group(1) + new + m.group(3)
    text = pattern.sub(repl, text, count=1)
else:
    text = text.rstrip() + f'\n\n{header}\n{addition}\n'
p.write_text(text)
PY
  fi

  # Link from vn → op (relative — voicenotes file is at wiki/<topic>/<file>.md, operational at projects/<file>.md, so go ../../sina-operational-wiki/<op_rel>)
  depth=$(echo "$vn_rel" | awk -F/ '{print NF-1}')
  prefix=$(printf '../%.0s' $(seq 1 $depth))
  link_to_op="${prefix}../sina-operational-wiki/$op_rel"
  if ! grep -qF "$link_to_op" "$vn_file"; then
    python3 - "$vn_file" "$op_title" "$link_to_op" "$why" <<'PY'
import sys, re, pathlib
p, title, link, why = pathlib.Path(sys.argv[1]), sys.argv[2], sys.argv[3], sys.argv[4]
text = p.read_text()
addition = f'- [{title}]({link}) — {why}'
# Voicenotes uses ## Related; fall back to ## Cross-references if present; else create ## Related
target_header = '## Related' if '## Related' in text else ('## Cross-references' if '## Cross-references' in text else None)
if target_header:
    pattern = re.compile(rf'({re.escape(target_header)}\s*\n)(.*?)(\n## |\Z)', re.S)
    def repl(m):
        body = m.group(2).rstrip()
        new = (body + '\n' if body else '') + addition + '\n'
        return m.group(1) + new + m.group(3)
    text = pattern.sub(repl, text, count=1)
else:
    text = text.rstrip() + f'\n\n## Related\n{addition}\n'
p.write_text(text)
PY
  fi
done

brain_log "brain-cross-link" "$n pairs linked"
brain_commit_push "$OPERATIONAL_DIR" "brain-cross-link: $n pairs"
[[ -d "$VOICENOTES_DIR/.git" ]] && brain_commit_push "$VOICENOTES_DIR" "cross-link from operational: $n pairs"
echo "linked $n pairs"
