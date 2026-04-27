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
