# .agents/

Specialist context files loaded on demand by AI coding agents. The orchestration entry point is **`AGENTS.md` in the repo root** — read that first. It tells you when to load each of these.

## Layout

```
.agents/
├── rules/        ← checklists and constraints for specific kinds of work
├── personas/     ← role and voice presets to adopt
└── workflows/    ← multi-step procedures for recurring tasks
```

`RULES-INDEX.md` lists every rule file; `personas/` and `workflows/` each have their own `README.md`. The authoritative routing tables — _when_ to load each file — live in `AGENTS.md`, not here.

## What goes where

The three categories are deliberately different shapes. Putting a file in the wrong one is the most common failure mode of this system.

| Kind         | Answers…                                       | Example                                         |
| ------------ | ---------------------------------------------- | ----------------------------------------------- |
| **Rule**     | "What constraints apply to this kind of work?" | "Before merging auth code, check…"              |
| **Persona**  | "What role am I playing right now?"            | "Act as the lead engineer reviewing this RFC."  |
| **Workflow** | "What are the steps for this recurring task?"  | "Cutting a release: 1. tag, 2. changelog, 3. …" |

If a file mixes two of these, split it. A persona that contains a checklist belongs partly in `personas/` (the voice) and partly in `rules/` (the checklist), with the persona referencing the rule.

## Adding a new file

1. Decide which subdirectory (`rules/`, `personas/`, `workflows/`).
2. Create the file there.
3. Add a row to the matching table in `AGENTS.md` describing **when to load it**.
4. Update `RULES-INDEX.md` for a rule, or the subdirectory's `README.md` for a persona or workflow.
5. Keep it focused — if it grows past ~200 lines, split it.

## Conventions

- These files are read by AI agents. Write for that audience: direct, structured, no marketing voice.
- Checklists with `[ ]` boxes are intentional — agents and humans both work better with them.
- Examples are concrete. Abstract advice without examples gets misapplied.
- Cross-reference, don't duplicate. If you find yourself repeating something from another file, link instead.

## Staying in sync with the template

```sh
/path/to/AGENTS-template/adopt.sh .            # report drift, change nothing
/path/to/AGENTS-template/adopt.sh . --apply    # pull template changes in
```

Files here fall into three groups:

**Template-owned** — `README.md`, `RULES-INDEX.md`, everything in `personas/` and `workflows/`, and the generic rules (`architect`, `debugger`, `docs`, `dod`, `migrations`, `reviewer`, `security`, `test-writer`). `--apply` overwrites these. Don't edit them here; edit the template and re-sync, or the drift starts again.

**Yours** — the six rule files with `TODO when adopting` seams: `stack.md`, `design.md`, `dangerous-paths.md`, `validation.md`, `encryption.md`, `logging.md`. Once seeded, `--apply` never touches them. `--check` tells you when the template's copy has moved so you can merge by hand. Find what still needs filling in:

```sh
grep -rn 'TODO when adopting' AGENTS.md .agents/rules/
```

**Also yours** — anything you author into `rules/`, `personas/`, `workflows/`, or `.claude/agents/`. `--apply` leaves these alone and `--check` lists them as `? unshipped`, since it can't tell an adopter's file from one the template dropped in a later version. If one is a leftover, delete it by hand.
