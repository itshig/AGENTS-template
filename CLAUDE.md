# CLAUDE.md

@AGENTS.md

---

**This file is a pointer, not a place for rules.**

Claude Code does not read `AGENTS.md` natively — the `@AGENTS.md` import above is the supported bridge, and it inlines that file into context at session start. Prose like "please read AGENTS.md" is a suggestion the model may or may not act on; the import is not.

Do not add project rules here. If a rule applies to all agents, it belongs in `AGENTS.md`. If it applies to a specific kind of work, it belongs in `.agents/rules/`. Duplicating rules across agent config files is how they drift.

Sub-agents for this repo live in `.claude/agents/` and are discovered automatically.
