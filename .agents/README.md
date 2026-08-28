# .agents/

Specialist context files loaded on demand by AI coding agents. The orchestration entry point is **`AGENTS.md` in the repo root** — read that first. It tells you when to load each of these.

## Layout

```
.agents/
├── rules/        ← checklists and constraints for specific kinds of work
├── personas/     ← role and voice presets to adopt
└── workflows/    ← multi-step procedures for recurring tasks
```

Each subdirectory has its own `README.md` listing the files inside and what they're for. The authoritative routing tables — _when_ to load each file — live in `AGENTS.md`, not here.

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
4. Update the subdirectory's `README.md` if you want a longer description.
5. Keep it focused — if it grows past ~200 lines, split it.

## Conventions

- These files are read by AI agents. Write for that audience: direct, structured, no marketing voice.
- Checklists with `[ ]` boxes are intentional — agents and humans both work better with them.
- Examples are concrete. Abstract advice without examples gets misapplied.
- Cross-reference, don't duplicate. If you find yourself repeating something from another file, link instead.

## Staying in sync with the template

These files are **template-owned**. Do not edit them in place in an adopting repo — edit them in the template and re-sync, or the drift starts again:

```sh
/path/to/AGENTS-template/adopt.sh .            # report drift
/path/to/AGENTS-template/adopt.sh . --apply    # pull template changes in
```

Project-specific content belongs in the `TODO when adopting` blocks inside `AGENTS.md`, `rules/stack.md`, `rules/design.md`, and `rules/dangerous-paths.md` — those are the seams designed to hold it.
