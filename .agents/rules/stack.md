---
description: The canonical commands and toolchain for this repo. Load at session start; never guess a command.
globs: ["package.json", "pyproject.toml", "Cargo.toml", "go.mod", "Makefile"]
---

# Stack

> **Always read this at session start.** It exists so no agent ever guesses a command. Guessing produces `npm test` in a `bun test` repo, which fails in a way that looks like a broken test suite instead of a wrong command.

## Commands

> **TODO when adopting:** fill in the real commands. Delete rows that don't apply. If a command needs a flag to be useful, include the flag.

| Purpose        | Command | Notes |
| -------------- | ------- | ----- |
| Install deps   | `…`     | Which package manager is authoritative — see below. |
| Dev server     | `…`     | Port, if not obvious. |
| Test (all)     | `…`     |       |
| Test (single)  | `…`     | How to run one file or one test. |
| Typecheck      | `…`     |       |
| Lint           | `…`     | Include the `--fix` variant if there is one. |
| Format         | `…`     |       |
| Build          | `…`     | Must pass clean before any change is "done." |
| DB migrate     | `…`     | See `.agents/rules/migrations.md` before running. |
| Deploy         | `…`     | See `.agents/rules/dangerous-paths.md` — usually needs approval. |

## Package manager

> **TODO when adopting:** name exactly one.

This repo uses **`…`**. Do not use another one, even if a lockfile for it exists from an earlier era. Mixing package managers produces lockfile churn and "works on my machine" bugs that cost more to diagnose than they ever save.

- [ ] The lockfile is committed.
- [ ] Adding a dependency goes through `.agents/rules/architect.md` first.

## Runtime and versions

> **TODO when adopting:** pin what matters.

- **Language/runtime version:** `…` (and where it's pinned — `.nvmrc`, `.python-version`, `mise.toml`, `engines` field)
- **Framework version:** `…`
- **Anything version-sensitive** a wrong assumption would break: `…`

## Verification gauntlet

The exact sequence to run before claiming any change is complete. Run it in order; fix everything before reporting.

> **TODO when adopting:** replace with this repo's real sequence.

```sh
# 1. …
# 2. …
# 3. …
```

This sequence is what `.agents/rules/dod.md` means by "the checks pass." If you did not run these commands and see them green, the change is not done.

## Project layout

> **TODO when adopting:** the four or five paths worth knowing on day one.

- **Entry point:** `…`
- **Routes / pages:** `…`
- **Shared components:** `…`
- **Business logic / services:** `…`
- **Tests:** `…`
- **Config:** `…`

## Gotchas

> **TODO when adopting:** the things that waste an hour if you don't know them. Add to this list every time one bites you.

- …
