# Session Handoff — Operational Wiki & Federated Second Brain

**Status:** Bootstrap complete. Planning has not started yet. Read this entire file before doing anything else.

---

## How to start the next session

You are being opened in a fresh Claude Code session at `C:\Users\kenny\Code_Sandbox\sina-2nd-brain\`. The previous session (where this conversation happened) is finished. Pick up from here.

**Do these in order:**

1. Read this file end-to-end. Do not skim.
2. Read `sina-voicenotes-wiki/CLAUDE.md` for the existing wiki's schema and patterns. The operational wiki should feel like a sibling to it, not a stranger.
3. Invoke the `superpowers:brainstorming` skill. Walk Kenny through the design questions in **§7 Open questions for planning**. Do not skip this step — the previous session deliberately deferred these decisions to a brainstorming-led design pass.
4. Once brainstorming converges, invoke `superpowers:writing-plans` to produce a concrete implementation plan.
5. Only then start building. Use `superpowers:executing-plans` to drive the implementation with checkpoints.

Kenny's preferences (from auto-memory): plain language, single recommended path with a one-line *why*, surface reasoning behind tooling choices, skip option matrices.

---

## 1. Vision (what Kenny is building)

Kenny wants Claude Code to act as his task manager and operational memory, with these primitives:

- **Brain dumps throughout the day** — voice or text capture of ideas, reminders, intent, reflections.
- **Session reviews** — at the end of (or during) a Claude Code session, Claude reads the transcript and writes down what got done, what's open, and what's next.
- **Cross-session continuity** — when he returns the next day, Claude knows where things stand without him re-explaining.
- **Federated second brain** — multiple personal wikis (voicenotes, operational, future ones) that cross-reference each other and feel like one connected system, not isolated silos.

He has explicitly chosen markdown-on-GitHub as the substrate — accessible from any machine, vendor-neutral, durable.

---

## 2. Existing system (do not disturb)

### `sina-voicenotes-wiki/`

Already nested inside this umbrella at `sina-2nd-brain/sina-voicenotes-wiki/`. It is a working Karpathy LLM Wiki implementation:

- **Remote:** `https://github.com/sKenny95/sina-voicenotes-wiki.git`
- **Pattern:** raw voice notes → librarian (Claude) → topic-organized articles in `wiki/`
- **Schema:** see `sina-voicenotes-wiki/CLAUDE.md` (read this before designing operational's schema)
- **Folders:** `raw/voicenotes/` (immutable input), `wiki/` (compiled output), `outputs/` (query results), `scripts/`, `tests/`, `docs/`
- **Auto-ingest:** GitHub Actions cron syncs raw notes hourly
- **Local sync state:** Has uncommitted changes (`M .claude/settings.json`) — local is **not** fully in sync with GitHub remote. Flag this to Kenny early and let him decide how to reconcile before any moves.

### What stays the same

Kenny said explicitly: *"I don't want to change what's being inputted into my existing voice notes wiki."* This means:

- Voicenotes raw input flow is untouched.
- Voicenotes librarian rules in `sina-voicenotes-wiki/CLAUDE.md` are untouched.
- The new operational wiki is built **next to** voicenotes, not on top of it.

### What may change

The voicenotes wiki may *receive* cross-reference backlinks from the operational wiki (managed by the librarian, never hand-edited). This is a design decision for the brainstorming phase — see §5.

---

## 3. Design decisions already made (don't re-litigate unless evidence appears)

These were settled in the previous session after research. Bring them forward unless brainstorming surfaces something genuinely new:

| Decision | Rationale |
|---|---|
| **Don't use Google Tasks** as the task store | API is too impoverished (no tags, no priority, no custom fields, 1-level nesting). Markdown wins on every dimension that matters here. |
| **Use Karpathy's LLM Wiki pattern** for the operational wiki | Same pattern as voicenotes — consistency reduces cognitive load and lets Kenny's existing intuitions transfer. |
| **Federate via side-by-side repos under an umbrella** (this folder) | Simpler than git submodules (which research consistently flags as a footgun for non-tight-coupling cases). Each sub-wiki is its own repo with its own remote. |
| **Three-repo setup** | (1) `sina-voicenotes-wiki` already exists. (2) `sina-operational-wiki` to be created. (3) This umbrella as a thin third repo holding only federation rules. |
| **Skill scopes are split** | Operational-only skills (`/review`, `/consolidate`, `/sweep`, `/process-inbox` for operational) live in `operational/.claude/skills/`. Umbrella skills (`/cross-link`, `/ask`) live in `.claude/skills/` at this level. |
| **Two-stage write for parallel sessions** | Each `/review` writes to `sessions/YYYY-MM-DD-<machine>-<slug>.md` (no collisions). A separate `/consolidate` merges session logs into `projects/*` and `areas/*`. Avoids races across concurrent Claude Code sessions. |
| **Cross-links bidirectional, cross-content one-direction** | Markdown links go both ways for discoverability. Content embedding/copying only goes operational ← voicenotes (state never pollutes reference). The librarian materializes backlinks; `/sweep` removes dead ones. |
| **Defer claude-mem** | Claude Code's session memory + this wiki's session logs cover Kenny's needs. Add claude-mem only if continuity feels broken in practice. |
| **Defer vector DB / Supabase / pgvector** | Markdown is enough until search degrades. Layer on later if/when the wiki crosses ~2-3K notes and retrieval suffers. |

---

## 4. The four input types the operational wiki must accommodate

(Cross-content with voicenotes intentionally omitted — those go to voicenotes, not here.)

| Input | Lands in | Triggered by |
|---|---|---|
| **Brain dumps about work/state** ("ship the auth feature", "I'm blocked on X") | `inbox/YYYY-MM-DD.md` (untriaged) | Kenny types/dictates |
| **Daily intent** ("today I want to push on Y") | `daily/YYYY-MM-DD.md` under `## Intent` | Kenny types/dictates, or auto-prompted at session start |
| **Session reviews** (what shipped + open loops from a Claude Code transcript) | `sessions/YYYY-MM-DD-<machine>-<slug>.md` | `/review` slash command |
| **Daily consolidate** (session logs → project/area state updates) | `projects/<slug>.md`, `areas/<slug>.md` | `/consolidate` slash command, run once per day |

Reflections, ideas, and pure knowledge captures continue to go to **voicenotes**, not here. The router (Kenny himself, or `/cross-link` later) decides which wiki the input belongs to.

---

## 5. Skill scope reference

| Skill | Lives in | What it does |
|---|---|---|
| `/process-inbox` (operational) | `operational/.claude/skills/` | Triage `inbox/` entries into projects/areas/daily |
| `/review` | `operational/.claude/skills/` | Read Claude Code transcript → write a session log |
| `/consolidate` | `operational/.claude/skills/` | Merge today's session logs into `projects/*.md` and `areas/*.md` |
| `/sweep` | `operational/.claude/skills/` | Staleness check: flag/retire untouched items, prune dead cross-links |
| `/cross-link` | `.claude/skills/` (umbrella) | Scan an entry, find connections in sibling wikis, insert bidirectional links |
| `/ask` | `.claude/skills/` (umbrella) | Query across all wikis, synthesize an answer |

The voicenotes wiki keeps its existing `/process-inbox` (or whatever its equivalent is — see its `CLAUDE.md`). Don't touch it.

---

## 6. Target federation structure

```
C:\Users\kenny\Code_Sandbox\sina-2nd-brain\          ← thin umbrella (this folder)
├── CLAUDE.md                                         ← federation schema (TO BE WRITTEN)
├── README.md                                         ← orientation (TO BE WRITTEN)
├── HANDOFF.md                                        ← this file
├── .gitignore                                        ← ignores voicenotes/ and operational/
├── .claude/
│   └── skills/
│       ├── cross-link/
│       └── ask/
├── sina-voicenotes-wiki/                             ← existing repo (untouched, gitignored from umbrella)
└── sina-operational-wiki/                            ← new repo (TO BE CREATED, gitignored from umbrella)
    ├── CLAUDE.md                                     ← operational schema (TO BE DESIGNED)
    ├── README.md
    ├── .claude/skills/{review,consolidate,sweep,process-inbox,...}
    ├── inbox/
    ├── daily/
    ├── sessions/
    ├── projects/
    └── areas/
```

The umbrella becomes its own GitHub repo (suggested name: `sina-second-brain` or similar — Kenny picks). Sub-wikis are gitignored from the umbrella so the parent stays a clean federation-rules-only repo.

---

## 7. Open questions for the planning phase

Brainstorm these with Kenny. Do not skip — the previous session intentionally deferred them.

### A. Operational schema specifics
- Exact frontmatter for `projects/*.md` and `areas/*.md` entries (status enum, last_touched, owner, due, related links?).
- What's the status enum? Suggested starting set: `active | waiting | done | dropped | someday`. Confirm or refine.
- Should `daily/YYYY-MM-DD.md` include a structured `## Intent`, `## Done`, `## Reflections` template, or stay loose?
- Filename conventions for `sessions/`: machine ID how (`hostname`? Kenny's choice of slug?). Slug source — auto from transcript topic, or asked at `/review` time?

### B. Cross-link mechanics
- Where in an article does the `## Cross-references` section live? Bottom always? Frontmatter `related:` list as well?
- Format of links between repos. Relative paths (`../sina-voicenotes-wiki/wiki/...`) work locally. GitHub URLs work universally but break offline. Pick one.
- How does `/cross-link` decide what to link? Pure semantic similarity (Claude reads both and judges)? Manual confirm before write? Fully autonomous with a sweep to undo bad calls?

### C. Parallel-session safety
- Auto-pull at session start: which skill owns the hook? `/review`? A wrapper at session-start time?
- If Kenny works on three machines simultaneously, what's the conflict-resolution play if `git pull --rebase` errors?
- Should umbrella repo be auto-pull/push the same way, or does it stay manual?

### D. Capture surface
- Mobile capture path. Email-to-inbox? GitHub web? Working Copy? Defer entirely?
- Voice dump: does Kenny use the same voice → text pipeline as voicenotes, or a different one for operational? (His voicenotes uses an hourly GitHub Actions cron — see voicenotes `CLAUDE.md`.)
- Should operational have its own GitHub Actions cron to auto-pull raw inputs from somewhere?

### E. The sync caveat (handle first)
- Kenny said the local voicenotes copy is "not fully up to date with what's on GitHub." Confirmed: there's an uncommitted `.claude/settings.json` change. Before any structural moves, walk Kenny through reconciling local vs. remote. Don't surprise him with a `git push` he didn't expect.

### F. Repo naming
- Umbrella repo name on GitHub. Default suggestion: `sina-second-brain`. Confirm.
- Operational repo name. Default suggestion: `sina-operational-wiki`. Confirm.

### G. Voicenotes folder name inside the umbrella
- Currently nested as `sina-2nd-brain/sina-voicenotes-wiki/`. The full repo name is verbose. Should it stay (matches GitHub repo name) or rename locally to `voice-notes/` (cleaner, but breaks the visual link to the GitHub repo)? Trivial, but worth a 30-second decision.

### H. Skill rollout order
- Which skill earns its keep first? Recommendation from previous session: `/review` — if review feels alive, the rest are obvious; if it doesn't, the whole approach is wrong and you've wasted an hour, not a day.
- `/cross-link` is sexy but useless until both wikis have content. Build last.

---

## 8. Research already done (don't redo)

The previous session researched these. Skim only if the planning phase contradicts a finding.

- **Google Tasks API** — limits ([Google Tasks limits](https://developers.google.com/workspace/tasks/limits)) make it unsuitable as the canonical store.
- **Karpathy's LLM Wiki pattern** — [original gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f), [explainer Apr 2026](https://medium.com/data-science-in-your-pocket/andrej-karpathys-llm-knowledge-bases-explained-2d9fd3435707).
- **Multi-wiki federation is canonical** — Karpathy's pattern explicitly supports cross-wiki references and cross-wiki health checks.
- **Git submodules avoided** — community consensus is that they're a footgun for personal knowledge management. Side-by-side repos with `.gitignore` from the parent is the simpler, working pattern.
- **claude-mem** — [docs](https://docs.claude-mem.ai/introduction). Stores in private SQLite + auto-generated `CLAUDE.md`. Different layer (helps Claude remember Kenny; doesn't replace user-facing wiki). Optional, deferred.
- **PARA method** — Kenny's existing voicenotes is **Resources**. The new operational wiki is **Projects + Areas**. This split is the canonical PKM pattern; we're applying it.

---

## 9. Personality / collaboration notes (from auto-memory)

- **Plain language, single path:** give one recommended path with a one-line *why*. Skip option matrices and jargon dumps.
- **Explain the why:** surface reasoning behind tooling choices, not silent execution.
- Kenny is on Windows 11, GitHub username `sKenny95`, uses Claude Code + Gemini in parallel, learning-oriented.
- Auto mode is active — execute autonomously on low-risk work, prefer action over planning, but planning skills are *expected* for this task per Kenny's explicit ask.

---

## 10. What was created in this bootstrap (reference)

This bootstrap session only created two files inside the umbrella:

- `HANDOFF.md` (this file)
- `README.md` (thin orientation pointer)

Nothing else was touched. No `git init` on the umbrella yet. No `.gitignore`. No operational/ folder. No CLAUDE.md. Those are deliberately for the planning phase to design from scratch.

---

## 11. End-state success criteria

You'll know the planning + build phase succeeded when:

1. Kenny can run `/review` after a coding session and see a session log written to disk.
2. Kenny can run `/consolidate` at end-of-day and see project state updated.
3. Kenny can run `/ask "what's open?"` from the umbrella and get a synthesized answer that draws from operational state.
4. Kenny can capture a brain dump via voice/text, drop it in `inbox/`, and `/process-inbox` triages it correctly.
5. Cross-links between operational and voicenotes work in both directions and `/sweep` keeps them clean.
6. All three repos are pushed to GitHub and Kenny can clone them onto a second machine and continue working.

Don't claim success on any of these without verifying — `superpowers:verification-before-completion` exists for a reason.

---

*End of handoff. Begin with `superpowers:brainstorming`.*

---

## 12. Build complete — 2026-04-26

All seven `/brain-*` skills are built, tested with TDD per skill, and installed at `~/.claude/skills/`. Three repos live on GitHub:

- Umbrella: https://github.com/sKenny95/sina-second-brain
- Operational: https://github.com/sKenny95/sina-operational-wiki
- Voicenotes: https://github.com/sKenny95/sina-voicenotes-wiki (untouched)

Implementation followed: [docs/superpowers/specs/2026-04-26-second-brain-design.md](docs/superpowers/specs/2026-04-26-second-brain-design.md) → [docs/superpowers/plans/2026-04-26-second-brain-build.md](docs/superpowers/plans/2026-04-26-second-brain-build.md). For ongoing usage see [README.md](README.md).
