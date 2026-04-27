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
