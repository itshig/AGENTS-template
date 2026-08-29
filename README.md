# AGENTS-template

A portable agent-instruction scaffold for a code repository. One entry point (`AGENTS.md`), a set of on-demand context files (`.agents/`), sub-agent definitions (`.claude/agents/`), and a sync script that keeps adopting repos from drifting.

Vendor-neutral by design: `AGENTS.md` is the source of truth, and each tool-specific file is a thin pointer to it.

## Tool coverage

| Tool | Reads | Provided by this template |
| ---- | ----- | ------------------------- |
| **Claude Code** | `CLAUDE.md`, `.claude/agents/`, `.claude/agent-memory/` | `CLAUDE.md` with an `@AGENTS.md` import (Claude Code does not read `AGENTS.md` natively), plus five sub-agents that keep persistent memory across sessions. |
| **Codex** | `AGENTS.md` natively | `AGENTS.md`. Nothing else needed. |
| **Antigravity** | `AGENTS.md` + `GEMINI.md` natively, and `.agents/rules/` as workspace rules | All three. `GEMINI.md` is a thin pointer so it never conflicts — Antigravity gives it precedence over `AGENTS.md` on conflicts. |
| **Cursor** | `AGENTS.md` natively; project rules as `.mdc` files in `.cursor/rules/` | `AGENTS.md`. Nothing else needed. Cursor does not scan `.agents/rules/`, and plain `.md` files in `.cursor/rules/` are ignored — so the `description`/`globs` frontmatter on our rule files is inert for Cursor. It serves Antigravity and human readers. |

**Antigravity discovers `.agents/rules/` directly**, which is why the directory is plural. It still reads a singular `.agent/rules` as a deprecated fallback, so existing repos aren't broken — but plural is the default going forward, and nothing else in this toolchain looks at the singular form.

Add a pointer only for a tool that actually needs one. Codex and Cursor read `AGENTS.md` directly, so a pointer for them is a file that drifts with nobody watching it. For a tool that does not — check its docs rather than assuming — the pointer is three lines in whatever file it does read, saying only "read AGENTS.md, then load from .agents/ as it directs."

## Layout

```
AGENTS.md                      ← entry point. Read first, every session.
.agents/
  rules/                       ← constraints for specific kinds of work
  personas/                    ← role presets
  workflows/                   ← multi-step procedures
.claude/agents/                ← sub-agent definitions (Claude Code)
.claude/agent-memory/          ← what those sub-agents have learned (committed)
CLAUDE.md, GEMINI.md           ← thin pointers (Codex and Cursor read AGENTS.md directly)
adopt.sh                       ← sync / drift-check script
```

## Adopting a repo

From the template directory:

```sh
./adopt.sh /path/to/your-repo --init
```

That copies the rules, personas, workflows, and sub-agents, and seeds `AGENTS.md` plus the pointer files if they don't exist. It never overwrites an `AGENTS.md` you've already filled in.

Then fill in every `TODO when adopting` block:

```sh
grep -rn 'TODO when adopting' AGENTS.md .agents/rules/
```

- `AGENTS.md` §2 — what the project is, stack, entry points
- `.agents/rules/stack.md` — the real commands
- `.agents/rules/design.md` — the design source of truth
- `.agents/rules/dangerous-paths.md` — the paths that need approval here
- `.agents/rules/validation.md` — the validation library and failure envelope
- `.agents/rules/encryption.md` — whether encryption is implemented, and where
- `.agents/rules/logging.md` — which manifest carries the version

These six rule files are **yours** once seeded. `--apply` never overwrites them; it reports when the template's copy has moved so you can merge by hand.

## Keeping it in sync

```sh
./adopt.sh /path/to/your-repo              # report drift, change nothing
./adopt.sh /path/to/your-repo --apply      # pull template updates in
```

`--check` is the default and is always safe. Run it across your repos periodically; drift is silent otherwise.

## The convention

Directory is `.agents/` (plural). Antigravity reads `.agents/rules/` as workspace rules directly; for Claude Code and Codex the files load because `AGENTS.md` routes to them. The plural name also lines up with the `~/.agents/` global convention and the [.agents Protocol](https://dotagentsprotocol.com/) draft — though note that draft specifies a different internal layout (`skills/`, `agents/`, `tasks/`, `memories/`), so only the directory name is shared.

`CLAUDE.md` uses an `@AGENTS.md` import rather than prose, because [Claude Code does not read `AGENTS.md` natively](https://github.com/anthropics/claude-code/issues/34235) and the import is the supported bridge.

## Versioning

See [`VERSION`](./VERSION) and [`CHANGELOG.md`](./CHANGELOG.md). Bump on any change to template-owned files so adopting repos can tell what they're behind.
