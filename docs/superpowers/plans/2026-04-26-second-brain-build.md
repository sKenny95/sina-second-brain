# Second Brain — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Stand up the full operational second-brain (umbrella repo + operational wiki + 7 user-level slash commands) end-to-end in one build session, with TDD per skill and verification before completion.

**Architecture:** Three side-by-side git repos under `C:\Users\kenny\Code_Sandbox\sina-2nd-brain\`. Umbrella holds federation rules + versioned skill source + install script. Operational holds work-state markdown. Voicenotes is untouched. Skills are installed to `~/.claude/skills/` so they fire from any Claude Code session. Each skill has a `SKILL.md` (Claude-facing prose) plus a `runner.sh` (bash-executable logic) so the mechanical parts are unit-testable.

**Tech Stack:** Git, GitHub CLI (`gh`), Bash (Git Bash on Windows), Markdown, YAML frontmatter, Claude Code skills.

**Spec:** [docs/superpowers/specs/2026-04-26-second-brain-design.md](../specs/2026-04-26-second-brain-design.md)

---

## Phase conventions

- **Working directory** is always `C:\Users\kenny\Code_Sandbox\sina-2nd-brain\` unless noted.
- **All commits use HEREDOC** with `Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>` per repo convention.
- **Push after every commit** in the repo just modified.
- **Verify each test passes** before moving to the next task.
- **Stop and report** if any step fails unexpectedly. Do not auto-resolve git conflicts.

---

## Phase 0: Pre-flight

### Task 0.1: Resolve voicenotes sync caveat

**Files:**
- Modify (or discard): `sina-voicenotes-wiki/.claude/settings.json`

- [ ] **Step 1: Show Sina the dirty file diff**

Run:
```bash
cd sina-voicenotes-wiki && git diff .claude/settings.json
```
Expected: shows the uncommitted change. Report the diff to Sina and ask:
> "Voicenotes has one uncommitted change in `.claude/settings.json`. Keep (commit) or discard?"

- [ ] **Step 2: Apply Sina's choice**

If keep:
```bash
cd sina-voicenotes-wiki && git add .claude/settings.json && git commit -m "$(cat <<'EOF'
chore: update local Claude settings

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)" && git push
```

If discard:
```bash
cd sina-voicenotes-wiki && git checkout -- .claude/settings.json
```

- [ ] **Step 3: Verify clean**

Run: `cd sina-voicenotes-wiki && git status --short`
Expected: empty output.

---

## Phase 1: Umbrella repo bootstrap

### Task 1.1: Initialize umbrella repo and .gitignore

**Files:**
- Create: `.gitignore`
- Create: `.git/` (via `git init`)

- [ ] **Step 1: Initialize git in umbrella**

Run:
```bash
git init -b main
```
Expected: `Initialized empty Git repository in C:/Users/kenny/Code_Sandbox/sina-2nd-brain/.git/`

- [ ] **Step 2: Create .gitignore**

Create `.gitignore`:
```
# Sub-wikis are independent repos cloned side by side
sina-voicenotes-wiki/
sina-operational-wiki/

# OS / editor noise
.DS_Store
Thumbs.db
*.swp
.idea/
.vscode/

# Local-only Claude state (settings.local.json, etc.)
.claude/settings.local.json
```

- [ ] **Step 3: Verify gitignore works**

Run: `git status --short`
Expected: shows `HANDOFF.md`, `README.md`, `docs/`, `.gitignore` as untracked. Does NOT show `sina-voicenotes-wiki/`.

- [ ] **Step 4: Commit gitignore + bootstrap docs (HANDOFF, spec, plan)**

Run:
```bash
git add .gitignore HANDOFF.md docs/ && git commit -m "$(cat <<'EOF'
chore: bootstrap umbrella repo with gitignore, HANDOFF, spec, and plan

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```
Expected: one commit; `git status --short` shows only `README.md` untracked (will be rewritten next task).

### Task 1.2: Write umbrella README.md (human manual)

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Replace the bootstrap README with the human manual**

Overwrite `README.md`:

```markdown
# Sina's Second Brain

A personal operational memory built on markdown in GitHub. Claude Code is the librarian. You dump thoughts, run a slash command, Claude does the filing.

## What's here

Three repos, side by side:

1. **`sina-voicenotes-wiki/`** — your existing reference wiki: ideas, reflections, knowledge.
2. **`sina-operational-wiki/`** — your work state: projects, sessions, daily, inbox.
3. **This umbrella** (`sina-second-brain`) — federation rules, cross-wiki skills, the install script.

## The slash commands

All seven `/brain-*` commands work from any Claude Code session, anywhere on your machine.

| Command | What it does | When to run |
|---|---|---|
| `/brain-dump "<thought>"` | Append a bullet to today's inbox | Anytime a thought lands |
| `/brain-review` | Read this Claude session's transcript and write a session log | End of (or during) a coding session |
| `/brain-consolidate` | Merge today's session logs into projects/areas, fill daily | Once a day |
| `/brain-process` | Triage inbox bullets into projects/areas/daily/someday | Daily, or when inbox piles up |
| `/brain-ask "<question>"` | Query across both wikis and synthesize an answer | Anytime ("what's open?") |
| `/brain-sweep` | Stale-check, retire dropped items, prune dead links | Weekly or on demand |
| `/brain-cross-link` | Link operational ↔ voicenotes bidirectionally | After consolidate, on demand |

## Folder map

```
sina-2nd-brain/
├── README.md                ← this file
├── CLAUDE.md                ← rules Claude reads at session start
├── HANDOFF.md               ← original bootstrap notes
├── skills/                  ← versioned source for the seven /brain-* skills
├── scripts/install-skills.sh ← run after cloning on a new machine
├── docs/superpowers/        ← specs and plans
├── sina-voicenotes-wiki/    ← reference wiki (separate repo)
└── sina-operational-wiki/   ← operational wiki (separate repo)
```

## Setup on a new machine

```bash
git clone https://github.com/sKenny95/sina-second-brain.git
cd sina-second-brain
git clone https://github.com/sKenny95/sina-voicenotes-wiki.git
git clone https://github.com/sKenny95/sina-operational-wiki.git
bash scripts/install-skills.sh
```

After that, every `/brain-*` command works from any Claude Code session on the machine.

## Recovery

- **Skill gives a "git pull conflict" error.** Open the file it names. Resolve manually. Rerun the skill.
- **Skill writes to the wrong file.** Open the file. Edit it. Commit. The next consolidate will reconcile.
- **You want to reinstall skills.** Re-run `bash scripts/install-skills.sh`. Idempotent.
- **You want to read the rules Claude follows.** Open `CLAUDE.md` (umbrella) or the `CLAUDE.md` inside each sub-wiki.

## Discipline

Every change to a `/brain-*` command updates this README in the same commit. If a command does something this README doesn't describe, the README is wrong — fix it.
```

- [ ] **Step 2: Verify the README renders cleanly**

Open `README.md` in the IDE preview. Expected: no broken markdown, table renders, code blocks render.

- [ ] **Step 3: Commit**

Run:
```bash
git add README.md && git commit -m "$(cat <<'EOF'
docs: write human-facing umbrella README with command reference and folder map

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

### Task 1.3: Write umbrella CLAUDE.md (federation rules)

**Files:**
- Create: `CLAUDE.md`

- [ ] **Step 1: Create CLAUDE.md**

Create `CLAUDE.md`:

```markdown
# Sina's Second Brain — Federation Rules

You are the federation librarian. Read this file at the start of every session before doing anything else.

## What this is

A federation of three side-by-side repos cloned at `C:\Users\kenny\Code_Sandbox\sina-2nd-brain\`:

- `sina-voicenotes-wiki/` — reference material (ideas, reflections, knowledge). See its own `CLAUDE.md` for librarian rules. Do not modify its raw inputs or its librarian rules.
- `sina-operational-wiki/` — work state (projects, areas, daily, sessions, inbox). See its `CLAUDE.md` for schema.
- This umbrella — federation rules, cross-wiki skills, install script.

## Cross-wiki linking

- Markdown links go both ways (operational ↔ voicenotes) for discoverability.
- Content embedding/copying is one-way only: operational ← voicenotes. Never the reverse. Reference material must not be polluted by operational state.
- Link format is relative paths between sibling repos: `../sina-voicenotes-wiki/wiki/<topic>/<article>.md`.
- Cross-references live in two places per article: a `## Cross-references` section at the bottom (prose with one-line *why* per link) and a `related: []` array in frontmatter (machine-readable).

## Skill responsibilities

The `/brain-*` skills under `~/.claude/skills/` (versioned in `skills/`) are the only authorized writers to operational. Hand-edits are allowed but discouraged because skills will reconcile on the next run.

Every skill follows this contract:
1. `cd` to the umbrella folder.
2. `git pull --rebase` in every repo it's about to write to.
3. Do its work.
4. Commit with a conventional message (`brain-<verb>: <slug>`).
5. Push every touched repo.
6. Append one line to `sina-operational-wiki/log.md` in the format `## [YYYY-MM-DD HH:MM] <skill> | <description>`.
7. On rebase conflict: stop, name the file, exit cleanly. Never auto-resolve.

## Safety rules

- Never modify `sina-voicenotes-wiki/raw/`. Raw is truth.
- Never edit a `status:` field by hand in operational. Skills manage status.
- Never push to `main`/`master` with `--force`.
- When in doubt, surface the question to Sina before making the change.

## Documentation discipline

When a skill is added or its behavior changes, the umbrella `README.md` is updated in the same commit. If `README.md` and the skill's behavior disagree, the README is wrong and you fix it.
```

- [ ] **Step 2: Commit**

Run:
```bash
git add CLAUDE.md && git commit -m "$(cat <<'EOF'
docs: add federation CLAUDE.md with cross-wiki linking and skill contract

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

### Task 1.4: Create skills install script

**Files:**
- Create: `scripts/install-skills.sh`

- [ ] **Step 1: Create the script**

Create `scripts/install-skills.sh`:

```bash
#!/usr/bin/env bash
# Install all /brain-* skills to ~/.claude/skills/.
# Idempotent — safe to re-run after edits.

set -euo pipefail

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
```

- [ ] **Step 2: Make it executable and verify**

Run:
```bash
chmod +x scripts/install-skills.sh && bash scripts/install-skills.sh
```
Expected: `0 skill(s) installed to /c/Users/kenny/.claude/skills` (no skills exist yet — this proves the script works without crashing).

- [ ] **Step 3: Commit**

Run:
```bash
git add scripts/install-skills.sh && git commit -m "$(cat <<'EOF'
feat: add idempotent skills install script

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

### Task 1.5: Create umbrella GitHub remote and push

**Files:** none (remote-only)

- [ ] **Step 1: Create the GitHub repo**

Run:
```bash
gh repo create sKenny95/sina-second-brain --public --source=. --remote=origin --description "Federation umbrella for Sina's second brain (operational + voicenotes wikis)" --push
```
Expected: `https://github.com/sKenny95/sina-second-brain` URL printed; push reports objects sent.

- [ ] **Step 2: Verify remote**

Run: `git remote -v && git log --oneline -5`
Expected: `origin` points to GitHub URL; recent commits visible.

---

## Phase 2: Operational repo bootstrap

### Task 2.1: Create operational folder skeleton

**Files:**
- Create: `sina-operational-wiki/` (folder)
- Create: `sina-operational-wiki/inbox/.gitkeep`
- Create: `sina-operational-wiki/daily/.gitkeep`
- Create: `sina-operational-wiki/sessions/.gitkeep`
- Create: `sina-operational-wiki/projects/.gitkeep`
- Create: `sina-operational-wiki/areas/.gitkeep`

- [ ] **Step 1: Make the folder and skeleton**

Run:
```bash
mkdir -p sina-operational-wiki/{inbox,daily,sessions,projects,areas,outputs} && \
touch sina-operational-wiki/inbox/.gitkeep \
      sina-operational-wiki/daily/.gitkeep \
      sina-operational-wiki/sessions/.gitkeep \
      sina-operational-wiki/projects/.gitkeep \
      sina-operational-wiki/areas/.gitkeep \
      sina-operational-wiki/outputs/.gitkeep
```
Expected: directories exist, each contains `.gitkeep`. (`outputs/` is the home for `/brain-ask` filed answers.)

- [ ] **Step 2: Initialize git in operational**

Run:
```bash
cd sina-operational-wiki && git init -b main && cd ..
```
Expected: `Initialized empty Git repository in .../sina-operational-wiki/.git/`.

### Task 2.2: Write operational CLAUDE.md (schema rules)

**Files:**
- Create: `sina-operational-wiki/CLAUDE.md`

- [ ] **Step 1: Write the librarian rulebook**

Create `sina-operational-wiki/CLAUDE.md`:

```markdown
# Operational Wiki — Librarian Rules

You are the librarian for Sina's operational wiki. Read this at session start.

## What this is

Sina's work state: active projects, ongoing areas, daily intent/done, session logs, and a triage inbox. Reference material (ideas, knowledge, reflections) belongs in the voicenotes wiki, not here.

## Folder structure

- `_index.md` — root catalog. Lists every project + area with a one-line summary. **Auto-generated by `/brain-consolidate` and `/brain-process`. Never hand-edit.**
- `inbox/YYYY-MM-DD.md` — raw captures, append-only bullets. Triaged by `/brain-process`.
- `daily/YYYY-MM-DD.md` — `## Intent`, `## Done`, `## Notes` template. Sina fills Intent + Notes; `/brain-consolidate` fills Done.
- `sessions/YYYY-MM-DD-<machine>-<slug>.md` — per-Claude-Code-session logs from `/brain-review`. Append-only after creation.
- `projects/<slug>.md` — active project state. One file per project.
- `areas/<slug>.md` — ongoing responsibilities (no end state).
- `log.md` — append-only timeline. Format: `## [YYYY-MM-DD HH:MM] <skill> | <description>`.

## Frontmatter (projects and areas)

```yaml
---
title: <human-readable title>
slug: <kebab-slug-matching-filename>
status: active           # active | waiting | done | dropped | someday
created: YYYY-MM-DD
updated: YYYY-MM-DD
last_touched: YYYY-MM-DD
due: null                # ISO date or null
related: []              # array of relative paths
---
```

## Article structure (projects and areas)

```markdown
## Summary
One paragraph in Sina's voice.

## Open Loops
- Outstanding bullets.

## Done
- Most recent first.

## Notes
- Free-form context, decisions, links.

## Cross-references
- [Title](../sina-voicenotes-wiki/wiki/topic/article.md) — one-line why
```

## Status management

You manage status. Sina never edits it.

- `active` — default on creation.
- `waiting` — flip when a session log says "blocked on X" or "waiting for Y".
- `done` — flip when a session log says shipped/finished.
- `dropped` — only `/brain-sweep` proposes; Sina confirms.
- `someday` — captured at triage but not committed to.

`last_touched` is bumped by `/brain-consolidate` whenever a session log mentions the project.

## Discipline

- Every skill run appends one line to `log.md`.
- Every skill run is followed by `git push`.
- On rebase conflict: stop, name the file, exit. No auto-merge.
- Cross-references go both ways across wikis. Content copying is one-way (operational ← voicenotes only).
- Don't create a project from a single-bullet inbox capture unless it's clearly a project. Prefer `someday` or appending to an existing project.
```

- [ ] **Step 2: Verify renders cleanly**

Open in IDE preview. Expected: no broken markdown.

### Task 2.3: Write operational README.md

**Files:**
- Create: `sina-operational-wiki/README.md`

- [ ] **Step 1: Create README**

Create `sina-operational-wiki/README.md`:

```markdown
# Sina's Operational Wiki

Work state: projects, areas, daily logs, session logs, triage inbox. Managed by the `/brain-*` skills (see umbrella `README.md`).

## Folders

- `_index.md` — catalog of everything (auto-generated)
- `projects/` — active project files
- `areas/` — ongoing responsibilities
- `daily/` — daily intent + done
- `sessions/` — per-Claude-Code-session logs
- `inbox/` — raw triage queue
- `log.md` — append-only timeline

## How to read this wiki without Claude

Open `_index.md` first — it lists every project and area with a one-line summary. Click into whatever's relevant. `daily/<today>.md` shows what you said you'd do today. `log.md` shows the activity timeline.

## Don't hand-edit

- `_index.md` (regenerated by skills)
- Frontmatter `status:`, `last_touched:`, `updated:` fields (managed by skills)

Everything else is fair game to hand-edit; skills reconcile on next run.
```

### Task 2.4: Create initial _index.md and log.md

**Files:**
- Create: `sina-operational-wiki/_index.md`
- Create: `sina-operational-wiki/log.md`

- [ ] **Step 1: Seed _index.md**

Create `sina-operational-wiki/_index.md`:

```markdown
# Operational Wiki — Index

*Auto-generated by `/brain-consolidate` and `/brain-process`. Do not hand-edit.*

## Projects

*(no projects yet)*

## Areas

*(no areas yet)*
```

- [ ] **Step 2: Seed log.md**

Create `sina-operational-wiki/log.md`:

```markdown
# Operational Log

Append-only timeline of every skill run. Format: `## [YYYY-MM-DD HH:MM] <skill> | <description>`.

```

### Task 2.5: First operational commit

- [ ] **Step 1: Commit the skeleton**

Run:
```bash
cd sina-operational-wiki && git add -A && git commit -m "$(cat <<'EOF'
chore: bootstrap operational wiki skeleton with schema, README, index, log

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)" && cd ..
```
Expected: one commit on `main`.

### Task 2.6: Create operational GitHub remote and push

- [ ] **Step 1: Create the GitHub repo**

Run:
```bash
cd sina-operational-wiki && gh repo create sKenny95/sina-operational-wiki --public --source=. --remote=origin --description "Sina's operational second-brain wiki: projects, areas, daily, sessions, inbox" --push && cd ..
```
Expected: GitHub URL printed; push successful.

- [ ] **Step 2: Verify**

Run: `cd sina-operational-wiki && git remote -v && cd ..`
Expected: origin points to `https://github.com/sKenny95/sina-operational-wiki.git`.

---

## Phase 3: Skill scaffolding pattern

### Task 3.1: Create skills/ folder and shared helper

**Files:**
- Create: `skills/_shared/lib.sh`

The shared helper centralizes git pull/commit/push, log-line formatting, and date/hostname utilities. Every skill's `runner.sh` sources it.

- [ ] **Step 1: Create the shared library**

Create `skills/_shared/lib.sh`:

```bash
#!/usr/bin/env bash
# Shared helpers for /brain-* skills. Source from a skill's runner.sh.

set -euo pipefail

BRAIN_ROOT="${BRAIN_ROOT:-$HOME/Code_Sandbox/sina-2nd-brain}"
OPERATIONAL_DIR="${OPERATIONAL_DIR:-$BRAIN_ROOT/sina-operational-wiki}"
VOICENOTES_DIR="${VOICENOTES_DIR:-$BRAIN_ROOT/sina-voicenotes-wiki}"

today() { date +%Y-%m-%d; }
now()   { date +"%Y-%m-%d %H:%M"; }
host()  { hostname | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]//g'; }

# Pull --rebase a repo. Exits 1 on conflict.
brain_pull() {
  local repo="$1"
  ( cd "$repo" && git pull --rebase ) || {
    echo "ERROR: rebase conflict in $repo. Resolve manually then rerun." >&2
    exit 1
  }
}

# Append a log line to operational log.md.
brain_log() {
  local skill="$1"; shift
  local desc="$*"
  printf '## [%s] %s | %s\n' "$(now)" "$skill" "$desc" >> "$OPERATIONAL_DIR/log.md"
}

# Commit + push in a repo. Args: repo, message.
brain_commit_push() {
  local repo="$1" msg="$2"
  ( cd "$repo" && git add -A && git diff --cached --quiet || git commit -m "$msg" && git push )
}
```

- [ ] **Step 2: Smoke-test the helper**

Run:
```bash
bash -c 'source skills/_shared/lib.sh && echo "today=$(today)" && echo "now=$(now)" && echo "host=$(host)"'
```
Expected: prints today, now, hostname (lowercased, sanitized).

- [ ] **Step 3: Commit**

Run:
```bash
git add skills/_shared/lib.sh && git commit -m "$(cat <<'EOF'
feat(skills): add shared lib.sh with pull/log/commit-push helpers

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

### Task 3.2: Create test runner pattern

**Files:**
- Create: `skills/_shared/test-helpers.sh`

- [ ] **Step 1: Create test helpers**

Create `skills/_shared/test-helpers.sh`:

```bash
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
```

- [ ] **Step 2: Smoke-test**

Run:
```bash
bash -c 'source skills/_shared/test-helpers.sh && tmp=$(make_fixture_operational) && ls "$tmp" && rm -rf "$tmp" "$tmp.git"'
```
Expected: lists `_index.md`, `areas`, `daily`, `inbox`, `log.md`, `projects`, `sessions`.

- [ ] **Step 3: Commit**

Run:
```bash
git add skills/_shared/test-helpers.sh && git commit -m "$(cat <<'EOF'
feat(skills): add test-helpers.sh with fixture builder and assertions

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Phase 4: Skill 1 — `/brain-dump` (TDD)

`/brain-dump "thought"` appends a bullet to `inbox/<today>.md`, commits, pushes, logs.

### Task 4.1: Write the failing test

**Files:**
- Create: `skills/brain-dump/tests/test.sh`

- [ ] **Step 1: Create the test**

Create `skills/brain-dump/tests/test.sh`:

```bash
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
```

- [ ] **Step 2: Run it (FAIL — runner doesn't exist)**

Run:
```bash
chmod +x skills/brain-dump/tests/test.sh && bash skills/brain-dump/tests/test.sh
```
Expected: FAIL with "No such file or directory" pointing at `runner.sh`.

### Task 4.2: Implement runner.sh

**Files:**
- Create: `skills/brain-dump/runner.sh`

- [ ] **Step 1: Write the runner**

Create `skills/brain-dump/runner.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT/skills/_shared/lib.sh"

if [[ $# -lt 1 ]]; then
  echo "usage: brain-dump \"<thought>\"" >&2
  exit 2
fi

thought="$*"
inbox="$OPERATIONAL_DIR/inbox/$(today).md"

brain_pull "$OPERATIONAL_DIR"

# Create today's inbox file with header if absent
if [[ ! -f "$inbox" ]]; then
  printf '# Inbox %s\n\n' "$(today)" > "$inbox"
fi
printf -- '- [%s] %s\n' "$(now)" "$thought" >> "$inbox"

brain_log "brain-dump" "$thought"
brain_commit_push "$OPERATIONAL_DIR" "brain-dump: $(echo "$thought" | head -c 60)"

echo "dumped to $inbox"
```

- [ ] **Step 2: Make executable, run test (PASS)**

Run:
```bash
chmod +x skills/brain-dump/runner.sh && bash skills/brain-dump/tests/test.sh
```
Expected: `PASS: brain-dump appends, logs, commits`.

### Task 4.3: Write SKILL.md

**Files:**
- Create: `skills/brain-dump/SKILL.md`

- [ ] **Step 1: Create SKILL.md**

Create `skills/brain-dump/SKILL.md`:

```markdown
---
name: brain-dump
description: Append a quick thought to today's operational inbox so it can be triaged later. Use whenever Sina dumps a one-line idea, reminder, or work-state note that doesn't belong in the voicenotes wiki.
---

# /brain-dump

Capture a thought to `sina-operational-wiki/inbox/<today>.md`. Use this for work-state items (todos, blockers, intent). Use the voicenotes pipeline for ideas/reflections/knowledge.

## Behavior

Run the skill's runner script with Sina's input as a single argument:

```bash
bash C:/Users/kenny/.claude/skills/brain-dump/runner.sh "$ARGUMENTS"
```

The runner pulls operational, appends a timestamped bullet to today's inbox, logs the action, commits, and pushes. On rebase conflict it exits with a clear error — surface that to Sina and stop.

## Examples

- `/brain-dump "ship auth feature this week"` → bullet appended.
- `/brain-dump "blocked on stripe webhook contract"` → bullet appended; `/brain-process` will later route it to a project.

## What this skill does NOT do

- It does not create a project file. That's `/brain-process`'s job.
- It does not change any project status. Status changes come from session logs via `/brain-consolidate`.
- It does not write to voicenotes. If Sina's input sounds like a reflection or idea rather than a work item, suggest dumping it through the voicenotes pipeline instead.
```

- [ ] **Step 2: Re-run test to verify SKILL.md doesn't break anything**

Run: `bash skills/brain-dump/tests/test.sh`
Expected: still PASSES.

### Task 4.4: Install and commit

- [ ] **Step 1: Install**

Run: `bash scripts/install-skills.sh`
Expected: `installed: brain-dump -> /c/Users/kenny/.claude/skills/brain-dump`.

- [ ] **Step 2: Verify install**

Run: `ls ~/.claude/skills/brain-dump/`
Expected: `SKILL.md  runner.sh  tests/`.

- [ ] **Step 3: Commit**

Run:
```bash
git add skills/brain-dump && git commit -m "$(cat <<'EOF'
feat(brain-dump): capture thoughts to operational inbox with TDD coverage

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)" && git push
```

- [ ] **Step 4: Update README to reflect /brain-dump is live**

Edit `README.md` and confirm the `/brain-dump` row is present (it already is from Task 1.2). No change needed; verify only.

---

## Phase 5: Skill 2 — `/brain-review` (TDD)

`/brain-review` reads the *current* Claude Code session's transcript-summary and writes a session log. Because the runner can't actually read Claude's transcript (that's Claude's job during invocation), the runner takes the session-log content as stdin and the slug as an argument; SKILL.md instructs Claude to compose the content and pipe it through.

### Task 5.1: Failing test

**Files:**
- Create: `skills/brain-review/tests/test.sh`

- [ ] **Step 1: Create test**

Create `skills/brain-review/tests/test.sh`:

```bash
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
```

- [ ] **Step 2: Run (FAIL)**

Run: `chmod +x skills/brain-review/tests/test.sh && bash skills/brain-review/tests/test.sh`
Expected: FAIL — runner missing.

### Task 5.2: runner.sh

**Files:**
- Create: `skills/brain-review/runner.sh`

- [ ] **Step 1: Implement**

Create `skills/brain-review/runner.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT/skills/_shared/lib.sh"

if [[ $# -lt 1 ]]; then
  echo "usage: brain-review <slug> < <session-body-on-stdin>" >&2
  exit 2
fi

slug="$1"
body="$(cat)"
filename="$(today)-$(host)-$slug.md"
target="$OPERATIONAL_DIR/sessions/$filename"

brain_pull "$OPERATIONAL_DIR"

cat > "$target" <<EOF
---
date: $(today)
machine: $(host)
slug: $slug
project: null
---

$body
EOF

brain_log "brain-review" "session: $slug"
brain_commit_push "$OPERATIONAL_DIR" "brain-review: $slug"
echo "wrote $target"
```

- [ ] **Step 2: Run test (PASS)**

Run: `chmod +x skills/brain-review/runner.sh && bash skills/brain-review/tests/test.sh`
Expected: `PASS: brain-review writes session log with correct filename`.

### Task 5.3: SKILL.md

**Files:**
- Create: `skills/brain-review/SKILL.md`

- [ ] **Step 1: Create**

Create `skills/brain-review/SKILL.md`:

```markdown
---
name: brain-review
description: Read the current Claude Code session's transcript and write a structured session log to the operational wiki. Use at end of (or during) any work session where Sina wants the state captured.
---

# /brain-review

Compose a session log from the current conversation and persist it.

## Procedure

1. Identify a short kebab-slug for this session (e.g., `auth-rewrite-jwt-spike`). If `$ARGUMENTS` provided one, use it; otherwise propose one and confirm with Sina.
2. Compose the session log body with these sections:
   - `## What got done` — bullets of finished work in this session
   - `## Open loops` — what's mid-flight or unresolved
   - `## Status changes` — any project moving active → waiting/done/etc., one bullet each (omit section if none)
3. Pipe the body to the runner with the slug as the argument:

```bash
echo "$BODY" | bash C:/Users/kenny/.claude/skills/brain-review/runner.sh "<slug>"
```

The runner adds frontmatter, writes to `sessions/<date>-<machine>-<slug>.md`, commits, pushes, and logs.

## What this skill does NOT do

- Does not modify project files. That's `/brain-consolidate`'s job, which reads session logs and updates `projects/*.md`.
- Does not infer status changes silently — it records what Sina (via Claude in this session) asserts in the body.
```

- [ ] **Step 2: Re-run test to confirm**

Run: `bash skills/brain-review/tests/test.sh`
Expected: still PASSES.

### Task 5.4: Install + commit

- [ ] **Step 1: Install**

Run: `bash scripts/install-skills.sh`
Expected: includes `installed: brain-review`.

- [ ] **Step 2: Commit**

Run:
```bash
git add skills/brain-review && git commit -m "$(cat <<'EOF'
feat(brain-review): write per-session logs with hostname-scoped filenames

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)" && git push
```

---

## Phase 6: Skill 3 — `/brain-consolidate` (TDD)

`/brain-consolidate` reads today's session logs, updates `projects/*.md` (`Done`, `Open Loops`, `last_touched`, `status` if signaled), fills `daily/<today>.md ## Done`, and regenerates `_index.md`.

The judgment work (which session bullets go to which project) is Claude's. The runner accepts a JSON instruction file describing the merges to perform.

### Task 6.1: Failing test

**Files:**
- Create: `skills/brain-consolidate/tests/test.sh`
- Create: `skills/brain-consolidate/tests/sample-instruction.json`

- [ ] **Step 1: Sample instruction file**

Create `skills/brain-consolidate/tests/sample-instruction.json`:

```json
{
  "date": "FIXTURE_TODAY",
  "project_updates": [
    {
      "slug": "auth-rewrite",
      "create_if_missing": true,
      "title": "Auth rewrite",
      "append_done": ["wired auth middleware"],
      "append_open_loops": ["need to add tests"],
      "status": "active"
    }
  ],
  "area_updates": [],
  "daily_done": ["wired auth middleware"]
}
```

- [ ] **Step 2: Create test.sh**

Create `skills/brain-consolidate/tests/test.sh`:

```bash
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
```

- [ ] **Step 3: Run (FAIL)**

Run: `chmod +x skills/brain-consolidate/tests/test.sh && bash skills/brain-consolidate/tests/test.sh`
Expected: FAIL — runner missing.

### Task 6.2: runner.sh

**Files:**
- Create: `skills/brain-consolidate/runner.sh`

- [ ] **Step 1: Implement**

Create `skills/brain-consolidate/runner.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT/skills/_shared/lib.sh"

if [[ $# -lt 1 ]]; then
  echo "usage: brain-consolidate <instruction.json>" >&2
  exit 2
fi

instruction="$1"
[[ -f "$instruction" ]] || { echo "missing $instruction" >&2; exit 2; }

# Need jq; if absent, fail loudly
command -v jq >/dev/null || { echo "jq required" >&2; exit 3; }

brain_pull "$OPERATIONAL_DIR"

date_str="$(jq -r .date "$instruction")"
[[ "$date_str" == "$(today)" ]] || { echo "instruction date $date_str != today $(today)" >&2; exit 4; }

# Process project updates
proj_count=$(jq '.project_updates | length' "$instruction")
for i in $(seq 0 $((proj_count - 1))); do
  slug=$(jq -r ".project_updates[$i].slug" "$instruction")
  title=$(jq -r ".project_updates[$i].title" "$instruction")
  status=$(jq -r ".project_updates[$i].status" "$instruction")
  create=$(jq -r ".project_updates[$i].create_if_missing" "$instruction")
  proj_file="$OPERATIONAL_DIR/projects/$slug.md"

  if [[ ! -f "$proj_file" && "$create" == "true" ]]; then
    cat > "$proj_file" <<EOF
---
title: $title
slug: $slug
status: $status
created: $(today)
updated: $(today)
last_touched: $(today)
due: null
related: []
---

## Summary
*(to be filled in)*

## Open Loops

## Done

## Notes

## Cross-references
EOF
  fi

  # Update frontmatter status, updated, last_touched
  python3 - "$proj_file" "$status" "$(today)" <<'PY'
import sys, re, pathlib
p = pathlib.Path(sys.argv[1])
status, today = sys.argv[2], sys.argv[3]
text = p.read_text()
text = re.sub(r'^status:.*$', f'status: {status}', text, count=1, flags=re.M)
text = re.sub(r'^updated:.*$', f'updated: {today}', text, count=1, flags=re.M)
text = re.sub(r'^last_touched:.*$', f'last_touched: {today}', text, count=1, flags=re.M)
p.write_text(text)
PY

  # Append Open Loops
  ol_count=$(jq ".project_updates[$i].append_open_loops | length" "$instruction")
  for j in $(seq 0 $((ol_count - 1))); do
    line=$(jq -r ".project_updates[$i].append_open_loops[$j]" "$instruction")
    python3 - "$proj_file" "$line" <<'PY'
import sys, pathlib
p = pathlib.Path(sys.argv[1])
line = sys.argv[2]
text = p.read_text()
text = text.replace('## Open Loops\n', f'## Open Loops\n- {line}\n', 1)
p.write_text(text)
PY
  done

  # Append Done
  d_count=$(jq ".project_updates[$i].append_done | length" "$instruction")
  for j in $(seq 0 $((d_count - 1))); do
    line=$(jq -r ".project_updates[$i].append_done[$j]" "$instruction")
    python3 - "$proj_file" "$line" <<'PY'
import sys, pathlib
p = pathlib.Path(sys.argv[1])
line = sys.argv[2]
text = p.read_text()
text = text.replace('## Done\n', f'## Done\n- {line}\n', 1)
p.write_text(text)
PY
  done
done

# Daily done
daily_file="$OPERATIONAL_DIR/daily/$(today).md"
if [[ ! -f "$daily_file" ]]; then
  cat > "$daily_file" <<EOF
# $(today)

## Intent

## Done

## Notes
EOF
fi
dd_count=$(jq '.daily_done | length' "$instruction")
for j in $(seq 0 $((dd_count - 1))); do
  line=$(jq -r ".daily_done[$j]" "$instruction")
  python3 - "$daily_file" "$line" <<'PY'
import sys, pathlib
p = pathlib.Path(sys.argv[1])
line = sys.argv[2]
text = p.read_text()
text = text.replace('## Done\n', f'## Done\n- {line}\n', 1)
p.write_text(text)
PY
done

# Regenerate _index.md
python3 - "$OPERATIONAL_DIR" <<'PY'
import sys, pathlib, re
op = pathlib.Path(sys.argv[1])
def parse(p):
    text = p.read_text()
    fm = re.search(r'^---\n(.*?)\n---', text, re.S | re.M)
    if not fm: return None
    fields = {}
    for line in fm.group(1).splitlines():
        if ':' in line:
            k, v = line.split(':', 1)
            fields[k.strip()] = v.strip()
    return fields

projects = sorted(op.glob('projects/*.md'))
areas = sorted(op.glob('areas/*.md'))

lines = ['# Operational Wiki — Index', '', '*Auto-generated by `/brain-consolidate` and `/brain-process`. Do not hand-edit.*', '', '## Projects', '']
if not projects:
    lines.append('*(no projects yet)*')
for p in projects:
    f = parse(p) or {}
    title = f.get('title', p.stem)
    status = f.get('status', '?')
    summary_match = re.search(r'## Summary\n(.+?)(\n##|\Z)', p.read_text(), re.S)
    summary = (summary_match.group(1).strip().splitlines()[0] if summary_match else '').strip().lstrip('*').strip()
    lines.append(f'- [{title}](projects/{p.name}) — {status} — {summary}')

lines += ['', '## Areas', '']
if not areas:
    lines.append('*(no areas yet)*')
for a in areas:
    f = parse(a) or {}
    title = f.get('title', a.stem)
    status = f.get('status', '?')
    summary_match = re.search(r'## Summary\n(.+?)(\n##|\Z)', a.read_text(), re.S)
    summary = (summary_match.group(1).strip().splitlines()[0] if summary_match else '').strip().lstrip('*').strip()
    lines.append(f'- [{title}](areas/{a.name}) — {status} — {summary}')

(op / '_index.md').write_text('\n'.join(lines) + '\n')
PY

brain_log "brain-consolidate" "instruction $(basename "$instruction")"
brain_commit_push "$OPERATIONAL_DIR" "brain-consolidate: $(today)"
echo "consolidated"
```

- [ ] **Step 2: Run test (PASS)**

Run: `chmod +x skills/brain-consolidate/runner.sh && bash skills/brain-consolidate/tests/test.sh`
Expected: `PASS: brain-consolidate creates project, fills daily, regenerates index`.

### Task 6.3: SKILL.md

**Files:**
- Create: `skills/brain-consolidate/SKILL.md`

- [ ] **Step 1: Write**

Create `skills/brain-consolidate/SKILL.md`:

```markdown
---
name: brain-consolidate
description: Merge today's session logs into projects and areas, fill the daily Done section, and regenerate the operational _index.md. Run once a day, end of day.
---

# /brain-consolidate

Read today's `sessions/*.md`, decide which bullets update which projects/areas, then call the runner with a JSON instruction.

## Procedure

1. List today's session files: `ls sina-operational-wiki/sessions/$(date +%Y-%m-%d)-*.md`.
2. For each session, read it. Decide:
   - Which existing project (or new project) each `## What got done` bullet belongs to.
   - Which `## Open loops` bullet goes where.
   - Any explicit `## Status changes` (auth-rewrite: active → waiting, etc.).
3. Compose an instruction JSON like:

```json
{
  "date": "<YYYY-MM-DD>",
  "project_updates": [
    {
      "slug": "auth-rewrite",
      "create_if_missing": true,
      "title": "Auth rewrite",
      "append_done": ["..."],
      "append_open_loops": ["..."],
      "status": "active"
    }
  ],
  "area_updates": [],
  "daily_done": ["..."]
}
```

4. Save to `/tmp/brain-consolidate-<date>.json` and run:

```bash
bash C:/Users/kenny/.claude/skills/brain-consolidate/runner.sh /tmp/brain-consolidate-<date>.json
```

## Constraints

- Don't create a project from a single drive-by mention. Prefer appending to an existing project or filing as a `someday` candidate via `/brain-process`.
- Status flips: `active → waiting` if a session says "blocked on" or "waiting for"; `active → done` if "shipped" / "completed" / "merged"; otherwise leave status alone.
- After running, re-read `_index.md` and confirm projects appear with correct status. If anything looks wrong, revert with `git revert HEAD` in the operational repo.
```

- [ ] **Step 2: Re-run test**

Run: `bash skills/brain-consolidate/tests/test.sh`
Expected: still PASSES.

### Task 6.4: Install + commit

- [ ] **Step 1: Install + commit**

Run:
```bash
bash scripts/install-skills.sh && git add skills/brain-consolidate && git commit -m "$(cat <<'EOF'
feat(brain-consolidate): merge session logs into projects, regenerate index

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)" && git push
```

---

## Phase 7: Skill 4 — `/brain-process` (TDD)

`/brain-process` triages today's `inbox/` bullets into project/area/daily/someday. Like consolidate, runner takes a JSON instruction and Claude does the routing.

### Task 7.1: Failing test

**Files:**
- Create: `skills/brain-process/tests/test.sh`
- Create: `skills/brain-process/tests/sample-instruction.json`

- [ ] **Step 1: Sample instruction**

Create `skills/brain-process/tests/sample-instruction.json`:

```json
{
  "date": "FIXTURE_TODAY",
  "routings": [
    {
      "bullet": "ship the auth feature this week",
      "destination": "project",
      "slug": "auth-rewrite",
      "create_if_missing": true,
      "title": "Auth rewrite",
      "section": "Open Loops"
    },
    {
      "bullet": "look into rust",
      "destination": "someday",
      "slug": "someday-rust",
      "create_if_missing": true,
      "title": "Look into Rust",
      "section": "Notes"
    }
  ],
  "clear_inbox": true
}
```

- [ ] **Step 2: Create test.sh**

Create `skills/brain-process/tests/test.sh`:

```bash
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
```

- [ ] **Step 3: Run (FAIL)**

Run: `chmod +x skills/brain-process/tests/test.sh && bash skills/brain-process/tests/test.sh`
Expected: FAIL.

### Task 7.2: runner.sh

**Files:**
- Create: `skills/brain-process/runner.sh`

- [ ] **Step 1: Implement**

Create `skills/brain-process/runner.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT/skills/_shared/lib.sh"

[[ $# -ge 1 ]] || { echo "usage: brain-process <instruction.json>" >&2; exit 2; }
instruction="$1"
command -v jq >/dev/null || { echo "jq required" >&2; exit 3; }

brain_pull "$OPERATIONAL_DIR"

date_str="$(jq -r .date "$instruction")"
[[ "$date_str" == "$(today)" ]] || { echo "instruction date != today" >&2; exit 4; }

routings=$(jq '.routings | length' "$instruction")

mk_target() {
  local slug="$1" title="$2" status="$3"
  local kind="projects"
  local f="$OPERATIONAL_DIR/$kind/$slug.md"
  if [[ ! -f "$f" ]]; then
    cat > "$f" <<EOF
---
title: $title
slug: $slug
status: $status
created: $(today)
updated: $(today)
last_touched: $(today)
due: null
related: []
---

## Summary
*(to be filled in)*

## Open Loops

## Done

## Notes

## Cross-references
EOF
  fi
  echo "$f"
}

for i in $(seq 0 $((routings - 1))); do
  bullet=$(jq -r ".routings[$i].bullet" "$instruction")
  dest=$(jq -r ".routings[$i].destination" "$instruction")
  slug=$(jq -r ".routings[$i].slug" "$instruction")
  title=$(jq -r ".routings[$i].title" "$instruction")
  section=$(jq -r ".routings[$i].section" "$instruction")
  case "$dest" in
    project) status="active" ;;
    someday) status="someday" ;;
    area)    status="active" ;;
    daily)
      daily="$OPERATIONAL_DIR/daily/$(today).md"
      [[ -f "$daily" ]] || printf '# %s\n\n## Intent\n\n## Done\n\n## Notes\n' "$(today)" > "$daily"
      python3 - "$daily" "$bullet" "$section" <<'PY'
import sys, pathlib
p = pathlib.Path(sys.argv[1]); line = sys.argv[2]; section = sys.argv[3]
text = p.read_text()
text = text.replace(f'## {section}\n', f'## {section}\n- {line}\n', 1)
p.write_text(text)
PY
      continue ;;
    *) echo "unknown destination: $dest" >&2; exit 5 ;;
  esac

  target=$(mk_target "$slug" "$title" "$status")
  python3 - "$target" "$bullet" "$section" <<'PY'
import sys, pathlib
p = pathlib.Path(sys.argv[1]); line = sys.argv[2]; section = sys.argv[3]
text = p.read_text()
text = text.replace(f'## {section}\n', f'## {section}\n- {line}\n', 1)
p.write_text(text)
PY
done

# Clear inbox if requested
if [[ "$(jq -r '.clear_inbox' "$instruction")" == "true" ]]; then
  inbox="$OPERATIONAL_DIR/inbox/$(today).md"
  if [[ -f "$inbox" ]]; then
    printf '# Inbox %s\n\n*(triaged at %s)*\n' "$(today)" "$(now)" > "$inbox"
  fi
fi

brain_log "brain-process" "$routings bullets routed"
brain_commit_push "$OPERATIONAL_DIR" "brain-process: $(today)"
echo "processed $routings bullets"
```

- [ ] **Step 2: Run test (PASS)**

Run: `chmod +x skills/brain-process/runner.sh && bash skills/brain-process/tests/test.sh`
Expected: `PASS: brain-process triages bullets into projects with correct status`.

### Task 7.3: SKILL.md

**Files:**
- Create: `skills/brain-process/SKILL.md`

- [ ] **Step 1: Write**

Create `skills/brain-process/SKILL.md`:

```markdown
---
name: brain-process
description: Triage today's inbox bullets into projects, areas, daily, or someday. Run when the inbox has accumulated more than a few items, typically once a day.
---

# /brain-process

Route each bullet in today's inbox to the right place.

## Procedure

1. Read `sina-operational-wiki/inbox/$(date +%Y-%m-%d).md`.
2. For each bullet, decide:
   - **project** — concrete work that has (or could have) a finish line.
   - **area** — ongoing responsibility, no end state.
   - **daily** — purely a today-only note.
   - **someday** — captured but not committed to.
3. Build a JSON instruction:

```json
{
  "date": "<YYYY-MM-DD>",
  "routings": [
    {
      "bullet": "<verbatim bullet text>",
      "destination": "project|area|daily|someday",
      "slug": "<kebab>",
      "create_if_missing": true,
      "title": "<human title>",
      "section": "Open Loops|Done|Notes|Intent"
    }
  ],
  "clear_inbox": true
}
```

4. Save to `/tmp/brain-process-<date>.json` and run:

```bash
bash C:/Users/kenny/.claude/skills/brain-process/runner.sh /tmp/brain-process-<date>.json
```

## Heuristics

- One-line idea with no concrete next step → `someday`.
- Mention of an existing project slug → append to that project's `Open Loops`.
- "Today I want to ..." → `daily`, `Intent` section.
- Verb + object + roughly time-bounded → new `project`.
```

- [ ] **Step 2: Re-run test**

Run: `bash skills/brain-process/tests/test.sh`
Expected: still PASSES.

### Task 7.4: Install + commit

- [ ] **Step 1: Install + commit**

Run:
```bash
bash scripts/install-skills.sh && git add skills/brain-process && git commit -m "$(cat <<'EOF'
feat(brain-process): triage inbox into projects/areas/daily/someday

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)" && git push
```

---

## Phase 8: Skill 5 — `/brain-ask` (TDD)

`/brain-ask` is read-only: it pulls both wikis to ensure freshness, then prints relevant context for Claude to reason over. The runner outputs a structured "context bundle" (paths + excerpts) to stdout.

### Task 8.1: Failing test

**Files:**
- Create: `skills/brain-ask/tests/test.sh`

- [ ] **Step 1: Test**

Create `skills/brain-ask/tests/test.sh`:

```bash
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
```

- [ ] **Step 2: Run (FAIL)**

Run: `chmod +x skills/brain-ask/tests/test.sh && bash skills/brain-ask/tests/test.sh`
Expected: FAIL.

### Task 8.2: runner.sh

**Files:**
- Create: `skills/brain-ask/runner.sh`

- [ ] **Step 1: Implement**

Create `skills/brain-ask/runner.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT/skills/_shared/lib.sh"

[[ $# -ge 1 ]] || { echo "usage: brain-ask \"<question>\"" >&2; exit 2; }
question="$*"

# Pull each wiki if its origin is reachable; never fail if offline.
for repo in "$OPERATIONAL_DIR" "$VOICENOTES_DIR"; do
  if [[ -d "$repo/.git" ]]; then
    ( cd "$repo" && git pull --rebase --quiet 2>/dev/null ) || true
  fi
done

q_lower=$(echo "$question" | tr '[:upper:]' '[:lower:]')

emit_match() {
  local file="$1"
  echo "=== $file ==="
  head -c 2000 "$file"
  echo
  echo
}

scan() {
  local root="$1"
  [[ -d "$root" ]] || return 0
  while IFS= read -r f; do
    if grep -qiF "$question" "$f" 2>/dev/null; then
      emit_match "$f"
    fi
  done < <(find "$root" -name '*.md' -type f 2>/dev/null)
}

# Always include _index.md if present
[[ -f "$OPERATIONAL_DIR/_index.md" ]] && emit_match "$OPERATIONAL_DIR/_index.md"

# Token-based scan: also match individual question words against project titles
for word in $q_lower; do
  [[ ${#word} -ge 4 ]] || continue
  while IFS= read -r f; do
    grep -liF "$word" "$f" 2>/dev/null
  done < <(find "$OPERATIONAL_DIR/projects" "$OPERATIONAL_DIR/areas" -name '*.md' -type f 2>/dev/null) | sort -u | while read -r match; do
    emit_match "$match"
  done
done | awk '!seen[$0]++'

brain_log "brain-ask" "$question"
# brain-ask is read-only — no commit unless log changed
( cd "$OPERATIONAL_DIR" && git add log.md && git -c user.email=brain@local -c user.name=brain commit -q -m "brain-ask: log query" 2>/dev/null && git push -q 2>/dev/null ) || true
```

- [ ] **Step 2: Run test (PASS)**

Run: `chmod +x skills/brain-ask/runner.sh && bash skills/brain-ask/tests/test.sh`
Expected: `PASS: brain-ask returns context bundle including matching project`.

### Task 8.3: SKILL.md

**Files:**
- Create: `skills/brain-ask/SKILL.md`

- [ ] **Step 1: Write**

Create `skills/brain-ask/SKILL.md`:

```markdown
---
name: brain-ask
description: Answer Sina's question by gathering relevant context from the operational and voicenotes wikis, then synthesizing a citation-rich answer. Use for "what's open?", "what did I ship last week?", "what do I know about X?".
---

# /brain-ask

Run the runner to get a context bundle, then answer Sina's question grounded in those excerpts.

## Procedure

1. Run:

```bash
bash C:/Users/kenny/.claude/skills/brain-ask/runner.sh "$ARGUMENTS"
```

2. The runner prints `=== <path> ===` blocks with up to 2KB of each matching file. Use these as your *only* source for facts. If the bundle is empty or doesn't cover the question, say so plainly — don't make up answers.

3. Synthesize an answer with citations using markdown links to the actual files (relative paths). Example:

   "The auth rewrite is active with one open loop: needs tests ([projects/auth-rewrite.md](sina-operational-wiki/projects/auth-rewrite.md))."

4. If the answer has lasting value, offer to file it under `sina-operational-wiki/outputs/<date>-<slug>.md` (create if needed). Don't file by default; ask first.

## Constraints

- Read-only by default. The only file the runner appends to is `log.md`.
- If runner returns no matches, say "I don't have anything on that yet — want to dump it to inbox?".
```

- [ ] **Step 2: Re-run test**

Run: `bash skills/brain-ask/tests/test.sh`
Expected: still PASSES.

### Task 8.4: Install + commit

- [ ] **Step 1: Install + commit**

Run:
```bash
bash scripts/install-skills.sh && git add skills/brain-ask && git commit -m "$(cat <<'EOF'
feat(brain-ask): read-only context bundler across operational + voicenotes

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)" && git push
```

---

## Phase 9: Skill 6 — `/brain-sweep` (TDD)

`/brain-sweep` flags stale `active` projects (last_touched older than 30 days), proposes drops, and prunes dead cross-reference links (relative paths that don't resolve). It outputs a report and applies safe-only changes (link prunes); status flips to `dropped` are written only with Sina's `--apply-drops` confirmation.

### Task 9.1: Failing test

**Files:**
- Create: `skills/brain-sweep/tests/test.sh`

- [ ] **Step 1: Test**

Create `skills/brain-sweep/tests/test.sh`:

```bash
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
```

- [ ] **Step 2: Run (FAIL)**

Run: `chmod +x skills/brain-sweep/tests/test.sh && bash skills/brain-sweep/tests/test.sh`
Expected: FAIL.

### Task 9.2: runner.sh

**Files:**
- Create: `skills/brain-sweep/runner.sh`

- [ ] **Step 1: Implement**

Create `skills/brain-sweep/runner.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT/skills/_shared/lib.sh"

apply_drops="${1:-}"  # pass --apply-drops to write status: dropped

brain_pull "$OPERATIONAL_DIR"

today_epoch=$(date +%s)
stale_days=30

stale=()
for f in "$OPERATIONAL_DIR/projects/"*.md "$OPERATIONAL_DIR/areas/"*.md; do
  [[ -f "$f" ]] || continue
  status=$(grep -m1 '^status:' "$f" | awk '{print $2}')
  [[ "$status" == "active" ]] || continue
  lt=$(grep -m1 '^last_touched:' "$f" | awk '{print $2}')
  [[ -n "$lt" ]] || continue
  lt_epoch=$(date -d "$lt" +%s 2>/dev/null || date -j -f '%Y-%m-%d' "$lt" +%s 2>/dev/null || echo "$today_epoch")
  age_days=$(( (today_epoch - lt_epoch) / 86400 ))
  if (( age_days > stale_days )); then
    stale+=("$f:$age_days")
  fi
done

# Prune dead cross-reference links (relative paths that don't resolve)
pruned=0
for f in "$OPERATIONAL_DIR/projects/"*.md "$OPERATIONAL_DIR/areas/"*.md; do
  [[ -f "$f" ]] || continue
  python3 - "$f" "$OPERATIONAL_DIR" <<'PY'
import sys, re, pathlib
p = pathlib.Path(sys.argv[1]); op = pathlib.Path(sys.argv[2])
text = p.read_text()
def is_dead(m):
    target = m.group(2)
    if target.startswith(('http://', 'https://', '#')): return False
    resolved = (p.parent / target).resolve()
    return not resolved.exists()
new_text, n = re.subn(r'^- \[(.*?)\]\((.+?)\)(.*)$', lambda m: '' if is_dead(m) else m.group(0), text, flags=re.M)
new_text = re.sub(r'\n{3,}', '\n\n', new_text)
if n:
    p.write_text(new_text)
    print(f'PRUNED in {p.name}: {n}')
PY
done

echo "=== STALE active items (> $stale_days days) ==="
if [[ ${#stale[@]} -eq 0 ]]; then
  echo "(none)"
else
  for s in "${stale[@]}"; do
    f="${s%%:*}"; age="${s##*:}"
    echo "- $(basename "$f") — last_touched $age days ago"
  done
fi

if [[ "$apply_drops" == "--apply-drops" && ${#stale[@]} -gt 0 ]]; then
  for s in "${stale[@]}"; do
    f="${s%%:*}"
    sed -i.bak 's/^status: active$/status: dropped/' "$f" && rm -f "$f.bak"
  done
  echo "Applied: ${#stale[@]} dropped."
fi

brain_log "brain-sweep" "${#stale[@]} stale, links pruned"
brain_commit_push "$OPERATIONAL_DIR" "brain-sweep: $(today) (${#stale[@]} stale)"
```

- [ ] **Step 2: Run test (PASS)**

Run: `chmod +x skills/brain-sweep/runner.sh && bash skills/brain-sweep/tests/test.sh`
Expected: `PASS: brain-sweep flags stale, prunes dead links, leaves fresh alone`.

### Task 9.3: SKILL.md

**Files:**
- Create: `skills/brain-sweep/SKILL.md`

- [ ] **Step 1: Write**

Create `skills/brain-sweep/SKILL.md`:

```markdown
---
name: brain-sweep
description: Health-check the operational wiki — flag stale active items, propose drops, prune dead cross-reference links. Run weekly or whenever the wiki feels cluttered.
---

# /brain-sweep

Run the runner. By default it reports staleness and prunes dead links but does NOT change any status. To actually flip stale items to `dropped`, rerun with `--apply-drops` after Sina confirms the report.

## Procedure

```bash
bash C:/Users/kenny/.claude/skills/brain-sweep/runner.sh
```

Report what came back to Sina:
- Stale items (active, last_touched > 30 days).
- Pruned dead links (already applied; safe).

If Sina says "drop them all" or names specific ones:

```bash
bash C:/Users/kenny/.claude/skills/brain-sweep/runner.sh --apply-drops
```

## Constraints

- Never auto-drop without `--apply-drops`. Status changes are user-confirmed.
- Dead-link pruning is auto. A dead relative link is dead — pruning is safe.
- After applying drops, re-run `/brain-consolidate` (or hand-call the index regenerator) to refresh `_index.md`.
```

- [ ] **Step 2: Re-run test**

Run: `bash skills/brain-sweep/tests/test.sh`
Expected: still PASSES.

### Task 9.4: Install + commit

- [ ] **Step 1: Install + commit**

Run:
```bash
bash scripts/install-skills.sh && git add skills/brain-sweep && git commit -m "$(cat <<'EOF'
feat(brain-sweep): flag stale items, prune dead cross-refs, gated drop

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)" && git push
```

---

## Phase 10: Skill 7 — `/brain-cross-link` (TDD)

`/brain-cross-link` reads a single operational article (or all of them), finds candidate matches in voicenotes by token overlap, and inserts bidirectional `## Cross-references` links. The runner takes a JSON instruction with the explicit pairs to link (Claude does the matching and writes the JSON).

### Task 10.1: Failing test

**Files:**
- Create: `skills/brain-cross-link/tests/test.sh`
- Create: `skills/brain-cross-link/tests/sample-instruction.json`

- [ ] **Step 1: Sample**

Create `skills/brain-cross-link/tests/sample-instruction.json`:

```json
{
  "links": [
    {
      "operational": "projects/auth-rewrite.md",
      "voicenotes": "wiki/security/auth-thoughts.md",
      "why": "auth-thoughts grounds the rewrite's design choices"
    }
  ]
}
```

- [ ] **Step 2: Test**

Create `skills/brain-cross-link/tests/test.sh`:

```bash
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
```

- [ ] **Step 3: Run (FAIL)**

Run: `chmod +x skills/brain-cross-link/tests/test.sh && bash skills/brain-cross-link/tests/test.sh`
Expected: FAIL.

### Task 10.2: runner.sh

**Files:**
- Create: `skills/brain-cross-link/runner.sh`

- [ ] **Step 1: Implement**

Create `skills/brain-cross-link/runner.sh`:

```bash
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
```

- [ ] **Step 2: Run test (PASS)**

Run: `chmod +x skills/brain-cross-link/runner.sh && bash skills/brain-cross-link/tests/test.sh`
Expected: `PASS: brain-cross-link adds bidirectional links and logs`.

### Task 10.3: SKILL.md

**Files:**
- Create: `skills/brain-cross-link/SKILL.md`

- [ ] **Step 1: Write**

Create `skills/brain-cross-link/SKILL.md`:

```markdown
---
name: brain-cross-link
description: Find connections between operational projects/areas and voicenotes articles, then write bidirectional links. Use after consolidate or when a project has matured enough to benefit from voicenotes context.
---

# /brain-cross-link

Pair operational articles with voicenotes articles by semantic relevance, then write the links.

## Procedure

1. List operational candidates: `ls sina-operational-wiki/projects/*.md sina-operational-wiki/areas/*.md`.
2. Read each. For each, scan voicenotes (`sina-voicenotes-wiki/wiki/`) for topically related articles. Be conservative — only link when the voicenotes article materially informs the operational item.
3. Build instruction JSON:

```json
{
  "links": [
    { "operational": "projects/<slug>.md", "voicenotes": "wiki/<topic>/<article>.md", "why": "one-line why" }
  ]
}
```

4. Save to `/tmp/brain-cross-link.json` and run:

```bash
bash C:/Users/kenny/.claude/skills/brain-cross-link/runner.sh /tmp/brain-cross-link.json
```

The runner appends to each side's `## Cross-references` (operational) / `## Related` (voicenotes) sections.

## Constraints

- Don't link an operational item to itself or to another operational item via this skill.
- Don't add duplicate links — runner already idempotently checks for existing path.
- Direction: markdown links go both ways. Content is never copied across (operational stays state, voicenotes stays reference).
```

- [ ] **Step 2: Re-run test**

Run: `bash skills/brain-cross-link/tests/test.sh`
Expected: still PASSES.

### Task 10.4: Install + commit

- [ ] **Step 1: Install + commit**

Run:
```bash
bash scripts/install-skills.sh && git add skills/brain-cross-link && git commit -m "$(cat <<'EOF'
feat(brain-cross-link): bidirectional federation links between wikis

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)" && git push
```

---

## Phase 11: Integration verification

### Task 11.1: Run all skill tests

- [ ] **Step 1: Run every test in sequence**

Run:
```bash
for t in skills/*/tests/test.sh; do
  echo "=== $t ==="
  bash "$t" || { echo "FAILED: $t"; exit 1; }
done
echo "ALL TESTS PASS"
```
Expected: each test prints PASS, final line `ALL TESTS PASS`.

### Task 11.2: End-to-end smoke test

This is run interactively — Sina performs each step in a real Claude Code session and confirms.

- [ ] **Step 1: From any project, dump a thought**

In a fresh Claude Code session opened in any project (not the second-brain folder), run:
```
/brain-dump "smoke test — second brain is alive"
```
Expected: skill reports the inbox file path and confirms commit/push.

- [ ] **Step 2: Verify on GitHub**

Open `https://github.com/sKenny95/sina-operational-wiki/blob/main/inbox/<today>.md` in a browser. Expected: bullet present.

- [ ] **Step 3: Run review**

In the same session:
```
/brain-review
```
Expected: Claude proposes a slug, composes the body, runs the runner, returns success.

- [ ] **Step 4: Process inbox + consolidate**

```
/brain-process
/brain-consolidate
```
Expected: inbox cleared, projects updated, `_index.md` regenerated.

- [ ] **Step 5: Ask**

```
/brain-ask "what's open?"
```
Expected: Claude returns synthesized answer citing files.

- [ ] **Step 6: Sweep**

```
/brain-sweep
```
Expected: report (likely "no stale items" given fresh wiki).

- [ ] **Step 7: Cross-link** *(only if both wikis have matching content)*

```
/brain-cross-link
```
Expected: skill proposes pairs, writes them on confirmation.

### Task 11.3: Final umbrella push

- [ ] **Step 1: Confirm umbrella is clean and pushed**

Run:
```bash
git status --short && git log --oneline -10 && git push
```
Expected: status empty, commits visible, push reports `Everything up-to-date` or new push success.

### Task 11.4: Update HANDOFF.md to reference completion

- [ ] **Step 1: Add a footer note to HANDOFF.md**

Append to `HANDOFF.md`:

```markdown

---

## 12. Build complete

The build phase ran on 2026-04-26. All seven `/brain-*` skills are installed and verified end-to-end. See [docs/superpowers/plans/2026-04-26-second-brain-build.md](docs/superpowers/plans/2026-04-26-second-brain-build.md) for the implementation plan that drove the build, and [README.md](README.md) for ongoing usage.
```

- [ ] **Step 2: Final commit**

Run:
```bash
git add HANDOFF.md && git commit -m "$(cat <<'EOF'
docs: mark HANDOFF complete; build phase finished

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)" && git push
```

---

## Notes for the executor

- **Stop on first failure.** If any test fails, do not continue. Report the failure to Sina and diagnose.
- **No skipping verification.** Every skill must have its test PASS before its install/commit.
- **No silent skips.** If a step's expected output doesn't match, surface it. Don't move on.
- **Spec drift.** If during build you find the spec needs revising, edit the spec, commit it, and continue. Don't silently diverge.
- **Windows paths.** Skills use absolute paths with forward slashes (`C:/Users/kenny/.claude/skills/...`). Git Bash handles both.
- **Required tooling on the build machine:** `git`, `gh` (authenticated as sKenny95), `bash`, `jq`, `python3`. Verify presence before Phase 1:
  ```bash
  for t in git gh bash jq python3; do command -v $t >/dev/null || { echo "missing $t"; exit 1; }; done && echo "tools ok"
  ```
