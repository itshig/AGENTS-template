# AGENTS.md

> **What this is:** the entry point for any AI coding agent (Claude Code, Codex, Cursor, Aider, Continue, etc.) working in this repository. Read this file first, every session.

---

## 1. How to use this file

1. **Read this file fully** before touching code.
2. **Load context on demand** from `.agents/`. Each file is focused for a specific kind of work — don't load all of them at once, load the one(s) relevant to the task.
3. **Hand off explicitly.** When a task crosses a boundary (e.g., feature work → security review), say so and load the relevant file.
4. **Stop and ask** when the task is ambiguous, when you'd be making an architectural decision, or when you'd be touching anything in `.agents/rules/dangerous-paths.md`.

### Multi-agent convention

This project uses **AGENTS.md as the source of truth**. Other agent config files (`CLAUDE.md`, `.cursorrules`, `.github/copilot-instructions.md`, etc.) should be **thin pointers** to this file:

```markdown
# CLAUDE.md

See AGENTS.md.
```

Do not duplicate rules across agent files. One source, many pointers.

---

## 2. Repository orientation

> **TODO when adopting:** fill these in for your project.

- **What it is:** [one sentence — what does this project do?]
- **Stack:** [language, framework, runtime, package manager]
- **Entry points:** [where does execution start? `src/main.ts`? `app/page.tsx`?]
- **How to run:** [the one command that gets a dev server up]
- **How to test:** [the one command that runs the test suite]
- **Build:** [the one command that produces a deployable artifact]

If any of these aren't accurate, fix them before continuing.

---

## 3. The `.agents/` directory

The `.agents/` directory contains three kinds of files. Load only what's relevant to the current task.

```
.agents/
├── rules/        ← checklists and constraints for specific kinds of work
├── personas/     ← role and voice presets to adopt
└── workflows/    ← multi-step procedures for recurring tasks

.claude/agents/   ← sub-agent definitions (dispatched, not loaded)
```

### 3a. Rules (`.agents/rules/`)

Constraint files. Load when the trigger applies, then apply the checklist.

| File                 | Load when…                                                                                                    |
| -------------------- | ------------------------------------------------------------------------------------------------------------- |
| `stack.md`           | **Always read at session start.** Canonical commands, package manager, verification sequence. Never guess a command. |
| `dangerous-paths.md` | **Always read at session start.** Lists files/operations that require explicit human approval.               |
| `dod.md`             | Before marking _anything_ "done" or opening a PR. **Non-negotiable gate.**                                    |
| `security.md`        | Touching auth, sessions, payments, PII, file uploads, env vars, secrets, RBAC, or anything user-input-shaped. |
| `validation.md`      | Forms, API handlers, server actions, data ingestion — anything parsing input it didn't create.                |
| `encryption.md`      | Encrypting data at rest, or handling key material.                                                            |
| `design.md`          | Anything that renders to a screen: components, layout, color, type, spacing, states.                          |
| `architect.md`       | Proposing a new module, changing data shapes, introducing a dependency, or making a cross-cutting change.     |
| `reviewer.md`        | After a feature is functionally complete, before commit.                                                      |
| `test-writer.md`     | Adding tests, fixing flaky tests, or when coverage on a change is missing.                                    |
| `debugger.md`        | When stuck on a non-obvious failure for more than ~10 minutes.                                                |
| `migrations.md`      | Any change to database schema, persisted state, or breaking API contracts.                                    |
| `logging.md`         | Finishing a unit of work — changelog entry and version bump.                                                  |
| `docs.md`            | When public APIs, env vars, CLI flags, or user-facing surfaces change.                                        |

### 3b. Personas (`.agents/personas/`)

Role presets. Adopt when explicitly asked ("act as the lead engineer") or when the task obviously fits the role. A persona shapes _how_ you work; rules constrain _what_ you do. **Personas never override rules.**

| File                 | Adopt when…                                                                             |
| -------------------- | --------------------------------------------------------------------------------------- |
| `lead-engineer.md`   | Architecture, design reviews, large refactors, technical disagreements, mentoring tone. |
| `pair-programmer.md` | Live collaborative work where the human wants to drive and have you narrate.            |

### 3c. Workflows (`.agents/workflows/`)

Multi-step procedures. Load at the **start** of the procedure and follow it through.

| File                   | Use when…                                                 |
| ---------------------- | --------------------------------------------------------- |
| `new-feature.md`       | Starting a feature from a requirements brief, end-to-end. |
| `incident-response.md` | Production is broken or behaving wrong.                   |

### 3d. Sub-agents (`.claude/agents/`)

These are **dispatched**, not loaded. Each runs in its own fresh context, does one job, and reports back. Use them when a task benefits from a clean context or an independent perspective — especially review and debugging, where the agent that wrote the code is the worst one to judge it.

| Agent             | Dispatch when…                                                                 |
| ----------------- | ------------------------------------------------------------------------------ |
| `verifier`        | Before claiming any change is done. Runs the `stack.md` gauntlet, reports pass/fail. |
| `reviewer`        | Feature is functionally complete, before commit. Adversarial diff review.      |
| `debugger`        | Stuck on a non-obvious failure, or a first fix attempt already failed.         |
| `architect`       | A structural decision needs evaluating before implementation.                  |
| `design-reviewer` | UI changed and needs auditing against the design system.                       |

Each is a thin wrapper over a rule file — `verifier` loads `stack.md`, `design-reviewer` loads `design.md`, and the rest load the rule of the same name. The rule remains the single source of truth. **None of them edit code.** They report; the main session acts.

**Add new files** by creating them under the appropriate subdirectory and adding a row to the matching table above. Each file should be focused — if it grows past ~200 lines, split it.

---

## 4. Workflow

The default loop, regardless of which agent is driving:

1. **Restate the task** in your own words. If you can't, you don't understand it yet — ask.
2. **Identify what to load.** Which rules apply? Is there a workflow for this? Is a persona requested?
3. **Plan before coding.** A short plan beats a long apology. For non-trivial work, write the plan in chat or a scratch file first.
4. **Implement in small, reviewable slices.** A 50-line change you understand beats a 500-line change you don't.
5. **Run the relevant checks** using the commands in `.agents/rules/stack.md` — or dispatch the `verifier` sub-agent. Do not guess a command.
6. **Apply `.agents/rules/dod.md`** as the final gate.
7. **Summarize what changed and why** in the commit message and PR description.

---

## 5. Hard rules

These are not suggestions.

- **Never** commit secrets, API keys, tokens, or credentials. If you see one already in the repo, stop and flag it.
- **Never** modify files listed in `.agents/rules/dangerous-paths.md` without explicit human approval in the same session.
- **Never** disable, skip, or weaken a test to make CI pass. Fix the root cause or surface the failure.
- **Never** introduce a new runtime dependency without checking it against `.agents/rules/architect.md` (license, maintenance, size, alternatives already in the project).
- **Never** push directly to the protected branch (typically `main` or `master`).
- **Never** rewrite shared git history (`push --force` on shared branches, interactive rebase of pushed commits).
- **Never** assume — verify. Read the file, run the command, check the type. Confidence without verification is the most expensive thing in this repo.

---

## 6. Style and conventions

- **Match the surrounding code.** If the file uses tabs, use tabs. If it uses early returns, use early returns. Consistency over personal preference.
- **Names describe purpose, not type.** `users`, not `userArray`. `isReady`, not `readyBool`.
- **Comments explain _why_, not _what_.** The code shows what. If the why isn't obvious, write it down.
- **Errors are values, not surprises.** Handle them where they occur or propagate them deliberately. No silent catches.
- **No dead code.** If it's commented out, delete it. Git remembers.
- **Small functions, small files.** If you're scrolling, it's too big.

Project-specific conventions (formatter config, lint rules, naming patterns) live in the tool configs themselves (`.prettierrc`, `eslint.config.*`, `pyproject.toml`, etc.). Trust the tools.

---

## 7. Communication

When reporting back to the human:

- **Lead with the answer.** Then context, then caveats.
- **Show what you ran.** Commands, files touched, tests that passed.
- **Surface what you skipped or assumed.** Especially if `.agents/rules/dod.md` items aren't satisfied yet.
- **Ask one question at a time** when blocked. Multi-question dumps slow everyone down.
- **No false confidence.** "I think" and "I'm not sure" are useful signals.

---

## 8. When something feels off

Stop and say so. Better signals to escalate than to power through:

- The task description doesn't match the code you're seeing.
- Tests pass but the behavior is wrong, or vice versa.
- A change "shouldn't" affect something but it does.
- You're about to do something irreversible (drop, delete, force, overwrite).
- A file in `.agents/` contradicts this file or another `.agents/` file. **This file wins**, but flag the contradiction so it gets fixed.

---

_Keep this file short. **Antigravity caps each file in `.agents/rules/` at 12,000 characters** and truncates past it. `adopt.sh` checks this file against the same limit as a precaution, since it is loaded every session. If it approaches the cap, move content into a `.agents/` subdirectory._
