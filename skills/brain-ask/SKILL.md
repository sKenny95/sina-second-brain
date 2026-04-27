---
name: brain-ask
description: Answer Sina's question by gathering relevant context from the operational and voicenotes wikis, then synthesizing a citation-rich answer. Use for "what's open?", "what did I ship last week?", "what do I know about X?".
---

# /brain-ask

Run the runner to get a context bundle, then answer Sina's question grounded in those excerpts.

## Procedure

1. Run:

```bash
bash C:/Users/kenny/.claude/skills/brain-ask/runner.sh "$ARGUMENTS"
```

2. The runner prints `=== <path> ===` blocks with up to 2KB of each matching file. Use these as your *only* source for facts. If the bundle is empty or doesn't cover the question, say so plainly — don't make up answers.

3. Synthesize an answer with citations using markdown links to the actual files (relative paths). Example:

   "The auth rewrite is active with one open loop: needs tests ([projects/auth-rewrite.md](sina-operational-wiki/projects/auth-rewrite.md))."

4. If the answer has lasting value, offer to file it under `sina-operational-wiki/outputs/<date>-<slug>.md` (create if needed). Don't file by default; ask first.

## Constraints

- Read-only by default. The only file the runner appends to is `log.md`.
- If runner returns no matches, say "I don't have anything on that yet — want to dump it to inbox?".
