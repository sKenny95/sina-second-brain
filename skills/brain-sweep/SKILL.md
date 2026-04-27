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
