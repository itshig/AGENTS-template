# AGENTS-template

A portable agent-instruction scaffold for a code repository. One entry point (`AGENTS.md`), a set of on-demand context files (`.agents/`), sub-agent definitions (`.claude/agents/`), and a sync script that keeps adopting repos from drifting.

Vendor-neutral by design: `AGENTS.md` is the source of truth, and each tool-specific file (`CLAUDE.md`, `GEMINI.md`) is a thin pointer to it.

Add a pointer only for a tool you actually use. A pointer for a tool nobody runs is a file that can drift with no one watching it. Adding one later is a three-line file — `.cursorrules` for Cursor, `.github/copilot-instructions.md` for Copilot, `.windsurfrules` for Windsurf — each saying only "read AGENTS.md, then load from .agents/ as it directs."

## Layout

```
AGENTS.md                      ← entry point. Read first, every session.
.agents/
  rules/                       ← constraints for specific kinds of work
  personas/                    ← role presets
  workflows/                   ← multi-step procedures
.claude/agents/                ← sub-agent definitions (Claude Code)
CLAUDE.md, GEMINI.md           ← thin pointers, one per tool actually in use
adopt.sh                       ← sync / drift-check script
```

## Adopting a repo

From the template directory:

```sh
./adopt.sh /path/to/your-repo --init
```

That copies the rules, personas, workflows, and sub-agents, and seeds `AGENTS.md` plus the pointer files if they don't exist. It never overwrites an `AGENTS.md` you've already filled in.

Then fill in every `TODO when adopting` block:

- `AGENTS.md` §2 — what the project is, stack, entry points
- `.agents/rules/stack.md` — the real commands
- `.agents/rules/design.md` — the design source of truth
- `.agents/rules/dangerous-paths.md` — the paths that need approval here

## Keeping it in sync

```sh
./adopt.sh /path/to/your-repo              # report drift, change nothing
./adopt.sh /path/to/your-repo --apply      # pull template updates in
```

`--check` is the default and is always safe. Run it across your repos periodically; drift is silent otherwise.

## The convention

Directory is `.agents/` (plural), matching the [.agents Protocol](https://dotagentsprotocol.com/) draft and the `~/.agents/` global convention. Note that no coding agent scans this directory natively — files load because `AGENTS.md` routes to them. The name matters for consistency and future tooling, not discovery.

`CLAUDE.md` uses an `@AGENTS.md` import rather than prose, because [Claude Code does not read `AGENTS.md` natively](https://github.com/anthropics/claude-code/issues/34235) and the import is the supported bridge.

## Versioning

See [`VERSION`](./VERSION) and [`CHANGELOG.md`](./CHANGELOG.md). Bump on any change to template-owned files so adopting repos can tell what they're behind.
