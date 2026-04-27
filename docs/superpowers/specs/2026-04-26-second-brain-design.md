# Second Brain — Design Spec

**Date:** 2026-04-26
**Status:** Approved by Sina, ready for implementation planning
**Predecessor:** `HANDOFF.md` (bootstrap session)

---

## 1. What this is

A personal operational memory built on markdown files in GitHub. Claude Code acts as the librarian. Sina dumps thoughts, runs a slash command or two, and Claude does the filing, status tracking, cross-linking, and cleanup.

**Three repos, side by side:**

1. `sina-voicenotes-wiki` — *existing.* Reference material: ideas, reflections, knowledge. Untouched by this work.
2. `sina-operational-wiki` — *new.* Work state: projects, areas, sessions, daily, inbox.
3. `sina-second-brain` — *new umbrella.* Thin glue layer holding federation rules and cross-wiki skills. The three repos are clones living side by side on disk.

**Substrate:** markdown on GitHub. Vendor-neutral, durable, readable on any machine, editable without Claude.

---

## 2. Folder layout

```
C:\Users\kenny\Code_Sandbox\sina-2nd-brain\        ← umbrella repo (sina-second-brain)
├── README.md                                       ← human manual
├── CLAUDE.md                                       ← federation rules for Claude
├── HANDOFF.md                                      ← original bootstrap notes (kept for history)
├── .gitignore                                      ← ignores sub-wiki folders
├── docs/superpowers/specs/                         ← design specs (this file)
├── sina-voicenotes-wiki/                           ← existing repo (gitignored from umbrella)
└── sina-operational-wiki/                          ← new repo (gitignored from umbrella)
    ├── README.md
    ├── CLAUDE.md
    ├── _index.md                                   ← catalog: every project + area with one-line summary
    ├── inbox/                                      ← raw captures, one file per day
    ├── daily/                                      ← daily intent + done + notes
    ├── sessions/                                   ← per-session logs from /brain-review
    ├── projects/                                   ← active project state files
    ├── areas/                                      ← ongoing responsibilities
    └── log.md                                      ← append-only timeline of every skill run
```

The umbrella also versions all skill source under `skills/` and ships an install script (`scripts/install-skills.sh`) that copies them to `~/.claude/skills/`. New machine setup is `git clone` + `bash scripts/install-skills.sh`.

Skills live at the user level (`~/.claude/skills/`) so they work from any project Sina opens, not just from inside the second-brain folder. Each skill has the absolute path `C:\Users\kenny\Code_Sandbox\sina-2nd-brain\` baked into its instructions.

---

## 3. Schema

### `projects/<slug>.md` and `areas/<slug>.md`

```yaml
---
title: <human-readable title>
slug: <kebab-slug>
status: active           # active | waiting | done | dropped | someday
created: YYYY-MM-DD
updated: YYYY-MM-DD
last_touched: YYYY-MM-DD
due: null                # ISO date or null
related: []              # array of relative paths to related files
---

## Summary
One-paragraph synthesis in Sina's voice.

## Open Loops
- Bullet list of what's outstanding.

## Done
- Bullet list of what's shipped (most recent first).

## Notes
- Free-form context, decisions, links.

## Cross-references
- [Title](../sina-voicenotes-wiki/wiki/topic/article.md) — one-line why
```

**Status enum and who manages it:** Claude manages status entirely. Sina never edits it.
- `active` — default on creation.
- `waiting` — Claude flips when a session log says "blocked on X" / "waiting for Y."
- `done` — Claude flips when a session log says shipped/finished.
- `dropped` — only `/brain-sweep` proposes this; Sina confirms with a single yes/no.
- `someday` — Claude assigns at triage when an inbox item is captured but not committed to.

`last_touched` is bumped by `/brain-consolidate` whenever a session log mentions the project. `/brain-sweep` uses `last_touched` + `status` to decide what to nag about.

### `daily/YYYY-MM-DD.md`

Light template, free-fill:

```markdown
# 2026-04-26

## Intent
- What I want to push on today.

## Done
- Filled by /brain-consolidate at end of day.

## Notes
- Anything else.
```

### `sessions/YYYY-MM-DD-<machine>-<slug>.md`

Filename: date + auto-detected hostname + Claude-picked slug from the transcript. Hostname prevents collisions when Sina runs Claude on two machines simultaneously.

```markdown
---
date: 2026-04-26
machine: <hostname>
slug: <topic-slug>
project: <project-slug or null>
---

## What got done
- Bullets.

## Open loops
- Bullets — anything left mid-flight.

## Status changes
- project-x: active → waiting (blocked on vendor reply)
```

### `inbox/YYYY-MM-DD.md`

Append-only bullet list, one file per day. `/brain-process` triages bullets into projects, areas, daily, or someday.

### `_index.md`

Root-level catalog of every project and area, with a one-line summary each. Regenerated automatically by `/brain-consolidate` and `/brain-process`. Sina never edits it. This is the file `/brain-ask` reads first when answering "what's open?" — it's the wiki's table of contents. (Modeled on Karpathy's `index.md` pattern.)

```markdown
# Operational Wiki — Index

## Projects
- [auth-rewrite](projects/auth-rewrite.md) — active — replacing legacy session middleware for compliance
- [billing-v2](projects/billing-v2.md) — waiting — blocked on stripe webhook contract from vendor

## Areas
- [hiring](areas/hiring.md) — ongoing recruiting pipeline
- [infra](areas/infra.md) — production stability + cost
```

### `log.md`

Append-only timeline. Format: `## [YYYY-MM-DD HH:MM] <skill> | <description>`. Grep-parseable (`grep "^## \["`). One entry per skill run.

```
## [2026-04-26 14:32] brain-dump | "ship auth feature this week"
## [2026-04-26 18:05] brain-review | session: auth-rewrite/exploring-jwt-libs
## [2026-04-26 22:10] brain-consolidate | 3 sessions → 2 projects updated, daily filled
```

---

## 4. Slash commands (skills)

All live in `~/.claude/skills/` so they fire from any Claude Code session on the machine.

| Command | Purpose | When to run |
|---|---|---|
| `/brain-dump` | Append a bullet (text or dictated) to `inbox/<today>.md` | Anytime a thought lands |
| `/brain-review` | Read current Claude Code transcript → write a session log | End of (or during) a coding session |
| `/brain-consolidate` | Merge today's session logs into `projects/*` and `areas/*`, fill `daily/<today>.md ## Done` | Once a day, end of day |
| `/brain-process` | Triage `inbox/<today>.md` bullets into projects/areas/daily/someday | Daily, or when inbox piles up |
| `/brain-ask` | Query across both wikis, synthesize an answer with citations | Anytime ("what's open?", "what did I ship last week?") |
| `/brain-sweep` | Stale-check: flag/retire untouched items, prune dead cross-links, propose drops | Weekly, or on-demand |
| `/brain-cross-link` | Scan an entry, find connections in sibling wikis, insert bidirectional links | After consolidate, or on-demand |

**Common skill behavior (all `/brain-*`):**
1. `cd` to the umbrella folder.
2. `git pull --rebase` in every repo the skill is about to write to (operational, voicenotes, and/or umbrella). `/brain-cross-link` is the only skill that routinely touches all three; most touch one.
3. Do the work.
4. Commit with a conventional message (`brain-review: <slug>`, `brain-consolidate: 2026-04-26`, etc.).
5. Push each touched repo.
6. Append one line to the operational `log.md` describing what happened.
7. On `git pull --rebase` conflict: stop, tell Sina which file conflicted, exit cleanly. No auto-resolution.

**Build order:** `/brain-dump` → `/brain-review` → `/brain-consolidate` → `/brain-process` → `/brain-ask` → `/brain-sweep` → `/brain-cross-link`. Each must earn its keep before the next is built. `/brain-cross-link` is last because it's only useful once both wikis have content.

---

## 5. Cross-wiki links

**Direction policy:**
- **Markdown links** are bidirectional (operational ↔ voicenotes) for discoverability.
- **Content embedding/copying** only goes operational ← voicenotes (state never pollutes reference material).

**Placement in articles:**
- `## Cross-references` section at the bottom (prose with one-line *why* per link).
- `related: []` array in frontmatter (machine-readable, used by `/brain-ask` and `/brain-sweep`).

**Link format:** relative paths between sibling repos. Depth depends on the source file's position:

- From `sina-operational-wiki/projects/<slug>.md` (2 dirs deep) to voicenotes: `../../sina-voicenotes-wiki/wiki/<topic>/<article>.md`
- From `sina-voicenotes-wiki/wiki/<topic>/<article>.md` (3 dirs deep) to operational: `../../../sina-operational-wiki/projects/<slug>.md`

Works locally because the repos sit side by side. GitHub renders them too. Universal URLs were rejected because they break offline.

**`/brain-cross-link` policy:** semantic. Claude reads source and target candidates and judges relevance. Auto-applies the links it picks. A bad link is just a line of text Sina can ignore, and `/brain-sweep` removes dead ones. Cost of a wrong call is low; friction of asking permission is high.

---

## 6. Multi-machine and parallel-session safety

- **Auto-pull on every skill run.** `git pull --rebase` before any write, in every repo the skill is about to touch (operational, voicenotes, or umbrella).
- **Hostname in session filenames.** Detected via system hostname (`hostname` command on any platform). Two machines running `/brain-review` at the same moment write to different filenames and cannot collide.
- **Write-mostly-immutable.** `sessions/` and `inbox/` files are append-only or write-once-per-day, which removes the most common race surface. `projects/*` and `areas/*` are the only shared mutable state; concurrent writes there are surfaced by `git pull --rebase` rather than auto-merged.
- **Conflict policy.** On rebase conflict, skill exits with a clear message naming the file. No auto-merge. Sina resolves manually, reruns.
- **Recommendation, not enforcement.** Run `/brain-consolidate` from one machine per day. The system tolerates running it from two, but the rebase-conflict path is the cost.

---

## 7. Capture surface (v1)

- **Type or dictate inside Claude Code from any project:** `/brain-dump "..."` → appends to `inbox/<today>.md`.
- **Mobile capture:** deferred. Use the existing voicenotes pipeline as overflow. If something captured to voicenotes is actually operational, `/brain-process` moves it during triage.
- **External cron:** none new. Voicenotes' hourly cron stays. Operational content is primarily Claude-generated (session logs) so doesn't need a fetch cron.

If mobile becomes the bottleneck later, the natural addition is an email-to-inbox path: a Gmail filter forwards tagged emails to a script that appends to `inbox/`. Out of scope for v1.

---

## 8. Documentation discipline

Two layers, both maintained as part of every change that touches commands or behavior:

- **Umbrella `README.md`** — human-facing manual. Plain English. Lists slash commands, explains where things live, explains how to use it from a new machine, explains how to recover when something breaks. Sina reads this; Claude doesn't.
- **`CLAUDE.md`** — one per repo. Librarian rules. Claude reads at session start; Sina doesn't need to.

**Rule baked into every skill:** when a skill is added or its behavior changes, the umbrella `README.md` is updated as part of the same commit. Non-negotiable.

---

## 9. Repo and remote setup

- Umbrella repo: `sina-second-brain` on GitHub (sKenny95). New repo created during build. Sub-wiki folders are gitignored from it so the umbrella stays a clean federation-rules-only repo.
- Operational repo: `sina-operational-wiki` on GitHub (sKenny95). New repo created during build.
- Voicenotes repo: existing, untouched. Folder name stays `sina-voicenotes-wiki/` to match the GitHub repo name.

**Pre-flight for build phase:** voicenotes has one uncommitted file (`.claude/settings.json`) on `master`. Sina decides keep-or-discard before the umbrella `git init` runs. No other sync issues — branches were cleaned up.

---

## 10. Decisions deferred (out of scope for v1)

These were considered and explicitly deferred. Not "we forgot" — "we ruled them out for now."

- **Vector DB / Supabase / pgvector.** Markdown-native search via Claude is enough until the wiki crosses ~2-3K notes and retrieval suffers. Layer on later if needed.
- **claude-mem.** Claude Code's session memory + this wiki's session logs cover continuity. Add only if continuity feels broken in practice.
- **Mobile/email capture.** See §7.
- **Operational raw-input cron.** See §7.
- **Google Tasks integration.** Rejected during bootstrap research — API limits make it unsuitable as the canonical store.
- **Git submodules.** Rejected — community consensus is footgun for personal-knowledge-management use.

---

## 11. End-state success criteria

The build is done when Sina can:

1. Run `/brain-review` after a coding session and see a session log written and pushed.
2. Run `/brain-consolidate` end of day and see `projects/*` and `areas/*` updated, `daily/<today>.md ## Done` filled.
3. Run `/brain-ask "what's open?"` from any project and get a synthesized answer drawing from operational state.
4. Run `/brain-dump "..."` from any project and see it appear in `inbox/<today>.md`.
5. Run `/brain-process` and see inbox items triaged into projects/areas/daily/someday.
6. Run `/brain-sweep` and see staleness flags, dropped-candidate proposals, and dead cross-link prunes.
7. Run `/brain-cross-link` and see bidirectional links between operational and voicenotes.
8. Clone all three repos onto a second machine and pick up where he left off.

Verification before claiming any of these is non-optional (`superpowers:verification-before-completion`).

---

## 12. Implementation discipline

The build phase follows these rules without exception:

- **Test-driven.** Each skill ships with a real-input test — a small fixture (sample inbox file, sample transcript, sample project file) and an executable check that runs the skill against the fixture and verifies the expected output. Use `superpowers:test-driven-development` and write the test before the skill.
- **One skill at a time, in build-order.** `/brain-dump` ships and is verified end-to-end (capture → file lands in inbox → committed → pushed → visible on GitHub) before `/brain-review` starts. Same gate between every subsequent skill.
- **Verification before claiming done.** No skill is marked complete until Sina has run it from a real Claude Code session in a non-second-brain project and confirmed the result. `superpowers:verification-before-completion` is mandatory.
- **Organization.** Every skill lives in its own folder under `~/.claude/skills/<skill-name>/` with a `SKILL.md`, fixture files, and tests. No skill is permitted to share files with another skill. Documentation (README, CLAUDE.md) updates ship in the same commit as the skill change.
- **Commits stay small.** One skill's worth of work per commit. No mixing skills, schema changes, and doc updates into a single commit unless they're a tight unit.
