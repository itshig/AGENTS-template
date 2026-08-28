# Rules index

> This lives at `.agents/RULES-INDEX.md`, not inside `.agents/rules/` — Antigravity loads every file in `rules/` as an active rule, and an index table is not a rule.

Constraint files. Each one is a checklist for a specific kind of work. Load when the trigger applies; apply the checklist before calling the work done.

The authoritative "when to load each" table lives in [`AGENTS.md`](../AGENTS.md) §3a — this file is just an index.

| File | Covers |
| ---- | ------ |
| `stack.md` | Canonical commands, package manager, verification sequence. **Read at session start.** |
| `dangerous-paths.md` | Paths and operations requiring human approval. **Read at session start.** |
| `dod.md` | Definition of done. The final gate before anything ships. |
| `architect.md` | Structural decisions, new dependencies, data shapes. |
| `security.md` | Auth, PII, payments, input handling, secrets. |
| `validation.md` | Schema validation at trust boundaries. |
| `encryption.md` | Data at rest, key material. |
| `design.md` | Anything that renders to a screen. |
| `reviewer.md` | Self-review before commit. |
| `test-writer.md` | Writing and fixing tests. |
| `debugger.md` | Systematic debugging when stuck. |
| `migrations.md` | Schema and persisted-state changes. |
| `logging.md` | Changelog and version bumps. |
| `docs.md` | Public API, env var, and user-facing surface changes. |

## Frontmatter

Newer rule files carry `description` and `globs` frontmatter so Cursor can auto-attach them by path. It is inert for tools that don't use it. When editing an older file that lacks it, adding it is welcome.
