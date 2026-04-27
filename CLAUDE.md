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
