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
