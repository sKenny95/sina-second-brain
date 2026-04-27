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
