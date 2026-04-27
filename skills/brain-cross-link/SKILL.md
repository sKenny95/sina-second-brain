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
