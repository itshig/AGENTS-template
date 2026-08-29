# AGENTS.md

> **What this is:** the entry point for any AI coding agent (Claude Code, Codex, Cursor, Aider, Continue, etc.) working in this repository. Read this file first, every session.

---

## 1. How to use this file

1. **Read this file fully** before touching code.
2. **Load context on demand** from `.agents/`. Each file is focused for a specific kind of work — don't load all of them at once, load the one(s) relevant to the task.
3. **Hand off explicitly.** When a task crosses a boundary (e.g., feature work → security review), say so and load the relevant file.
4. **Stop and ask** when the task is ambiguous, when you'd be making an architectural decision, or when you'd be touching anything in `.agents/rules/dangerous-paths.md`.

### Multi-agent convention

`AGENTS.md` is the source of truth. Tool-specific files (`CLAUDE.md`, `GEMINI.md`) are thin pointers to it — never duplicate rules into them. Codex and Cursor read `AGENTS.md` directly and need no pointer at all.

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

`rules/` are constraints, `personas/` are role presets, `workflows/` are multi-step procedures, and `.claude/agents/` holds sub-agents that are dispatched rather than loaded. See `.agents/README.md` for how to add one.

### 3a. Rules (`.agents/rules/`)

Constraint files. Load when the trigger applies, then apply the checklist.

| File                 | Load when…                                                                                                    |
| -------------------- | ------------------------------------------------------------------------------------------------------------- |
| `stack.md`           | **Session start.** Commands, package manager, verification sequence. Never guess a command. |
| `dangerous-paths.md` | **Session start.** Files and operations needing explicit human approval. |
| `dod.md`             | Before marking anything done. **Non-negotiable gate.** |
| `security.md`        | Auth, sessions, payments, PII, uploads, secrets, RBAC, or anything user-input-shaped. |
| `validation.md`      | Forms, server actions, API handlers — anything parsing input it didn't create. |
| `encryption.md`      | Encrypting data at rest, signing tokens, or handling key material. |
| `design.md`          | Anything that renders to a screen. |
| `architect.md`       | New module, new dependency, changed data shape, cross-cutting change. |
| `reviewer.md`        | Feature complete, before commit. |
| `test-writer.md`     | Adding tests, fixing flaky ones, or when a change ships uncovered. |
| `debugger.md`        | Stuck on a non-obvious failure for ~10 minutes. |
| `migrations.md`      | Schema, persisted state, or breaking contract changes. |
| `logging.md`         | Finishing a unit of work — changelog and version bump. |
| `docs.md`            | Public APIs, env vars, CLI flags, or user-facing surfaces change. |

### 3b. Personas (`.agents/personas/`)

Role presets. Adopt when asked, or when the task obviously fits. A persona shapes _how_ you work; rules constrain _what_ you do. **Personas never override rules.**

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

**Dispatched**, not loaded — each runs in a fresh context and reports back. Use them when a task benefits from a clean context or an independent perspective, especially review and debugging, where the agent that wrote the code is the worst one to judge it.

| Agent             | Dispatch when…                                                                 |
| ----------------- | ------------------------------------------------------------------------------ |
| `verifier`        | Before claiming any change is done. Runs the `stack.md` gauntlet, reports pass/fail. |
| `reviewer`        | Feature is functionally complete, before commit. Adversarial diff review.      |
| `debugger`        | Stuck on a non-obvious failure, or a first fix attempt already failed.         |
| `architect`       | A structural decision needs evaluating before implementation.                  |
| `design-reviewer` | UI changed and needs auditing against the design system.                       |

Each is a thin wrapper over a rule file — `verifier` loads `stack.md`, `design-reviewer` loads `design.md`, and the rest load the rule of the same name. The rule remains the single source of truth. **None of them edit code.** They report; the main session acts.

**Adding a file?** Create it in the right subdirectory and add a row to the matching table above, or nothing will load it.

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

## 6. Style, conventions, and communication

**Match the surrounding code.** Tabs if it uses tabs, early returns if it uses early returns. Consistency beats personal preference. Read a few nearby files before adding another.

The rest lives in the rule files rather than being duplicated here — this file loads every session:

- Naming, comments, error handling, dead code, and the smells worth pausing on → `.agents/rules/reviewer.md`
- Visual and styling conventions → `.agents/rules/design.md`
- Formatter and lint config live in the tools themselves (`.prettierrc`, `eslint.config.*`, `pyproject.toml`). Trust them.

When reporting back: lead with the answer, show what you ran, and surface what you skipped or assumed — especially any `.agents/rules/dod.md` item you could not satisfy. "I'm not sure" is a useful signal. Ask one question at a time when blocked.

## 7. When something feels off

Stop and say so. Better signals to escalate than to power through:

- The task description doesn't match the code you're seeing.
- Tests pass but the behavior is wrong, or vice versa.
- A change "shouldn't" affect something but it does.
- You're about to do something irreversible (drop, delete, force, overwrite, deploy).
- A file in `.agents/` contradicts this one. **This file wins** — flag it so it gets fixed.

---

_Keep this file short. **Antigravity caps each file in `.agents/rules/` at 12,000 characters** and truncates past it silently. `adopt.sh` checks this file against the same limit, since it loads every session. It ships near 9KB with section 2 unfilled, so a filled-in section 2 lands around 10KB — comfortable, but not roomy. Add project-specific rules to `.agents/rules/`, not to this file._
