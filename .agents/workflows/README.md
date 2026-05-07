# .agents/workflows/

Multi-step procedures for recurring tasks. Load at the **start** of the procedure and follow it through.

## What a workflow is — and isn't

A **workflow** is a sequence: do this, then this, then this. It exists because the procedure is recurring, the order matters, and forgetting a step is expensive.

A workflow is **not** a checklist (use `rules/`) and **not** a role (use `personas/`). If your "workflow" is just a list of constraints, it belongs in `rules/`. If it's a way of thinking, it belongs in `personas/`.

## When to use one

- You're starting a recurring task that has a known shape (new feature, release, incident, dependency upgrade, onboarding).
- You're at step N of one and need to remember what step N+1 is.
- You're handing off mid-procedure and want the next person to know where they are.

If the task is genuinely one-off, don't force it into a workflow. Workflows are for *patterns*.

## Files in this directory

| File | Use when… |
|------|-----------|
| `new-feature.md` | Starting a feature from a requirements brief, end-to-end. |
| `incident-response.md` | Production is broken or behaving wrong. |

## Authoring a new workflow

A good workflow file has:

1. **Trigger** — when this workflow applies. One sentence.
2. **Prerequisites** — what must be true before step 1.
3. **Steps** — numbered, in order, each with a clear *exit condition* (how do you know you're done with this step?).
4. **Decision points** — where the workflow can branch, and how to choose.
5. **Exit criteria** — when the whole workflow is done.
6. **References** — which rules and personas pair naturally with this workflow.

Steps should be small enough that completing one is satisfying. If a single step takes a day, it's actually a sub-workflow — split it.

Keep the whole file under ~200 lines. A workflow that needs more than that is usually two workflows pretending to be one.
