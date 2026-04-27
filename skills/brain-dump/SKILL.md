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
