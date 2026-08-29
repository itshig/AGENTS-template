# Sub-agent memory

Each sub-agent in `.claude/agents/` has `memory: project`, which gives it a directory here — `.claude/agent-memory/<agent-name>/` — that survives across conversations. Agents read their `MEMORY.md` before working and update it after, so the next run starts from what the last one learned.

**This directory is committed on purpose.** Agent memory is project knowledge: recurring defects, decisions and their reasoning, flaky tests, design exceptions. Committing it means the knowledge is shared across your machines and across the team, and — more importantly — that it shows up in diffs. Agent-written notes get reviewed like any other file instead of accumulating unseen.

## What lives here

```
.claude/agent-memory/
├── README.md          ← this file (template-owned)
├── reviewer/MEMORY.md
├── debugger/MEMORY.md
├── architect/MEMORY.md
├── design-reviewer/MEMORY.md
└── verifier/MEMORY.md
```

Agents create their own directories on first write. Nothing here needs to exist ahead of time.

## The size budget

Claude Code injects only the **first 200 lines or 25KB of `MEMORY.md`, whichever comes first**, and cuts the rest silently. Each agent is instructed to curate: move detail into sibling files in its own directory and leave a pointer in `MEMORY.md`.

`adopt.sh` reports any `MEMORY.md` past that window. It is a warning, not a failure — curating is the agent's job, not a broken adoption.

## Gitignore

If your repo ignores `.claude/`, this directory disappears along with `.claude/agents/`. A bare `.claude/` ignore cannot have children re-included, so exclude the contents instead:

```gitignore
.claude/*
!.claude/agents/
!.claude/agent-memory/
```

Add back anything else you share (`launch.json`, for instance). Local state — `settings.local.json`, `worktrees/` — stays ignored.

## Things worth knowing

- **Memory grants Write and Edit.** Enabling `memory` on a sub-agent automatically turns on Read, Write, and Edit so it can maintain these files, regardless of the `tools:` list in its frontmatter. Every agent here is told, in its own prompt, that this directory is the only thing it may write to. That instruction is now the guardrail — the tool list no longer is.
- **It silently does nothing if auto memory is off.** The `memory` field depends on auto memory. With `autoMemoryEnabled` disabled or `CLAUDE_CODE_DISABLE_AUTO_MEMORY` set, agents launch with no memory instructions and no memory tools, and nothing warns you.
- **Claude Code only.** Codex, Cursor, and Antigravity do not read `.claude/agents/`, so none of this reaches them.
- **No secrets.** This directory is committed. Agents are instructed not to write credentials here; review the diffs anyway.

## Resetting an agent's memory

Delete its directory. It will start fresh on the next run:

```sh
rm -rf .claude/agent-memory/reviewer/
```

Prefer editing `MEMORY.md` to prune stale notes — a wholesale reset throws away the accurate notes with the wrong ones.
