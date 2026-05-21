# Workflow: New Feature

> Use when starting a feature from a brief, end-to-end. The goal is to get from "we want X" to "X is in production" without skipping the parts that quietly matter.

## Trigger

A new feature has been requested. You have a description, a ticket, or a paragraph of intent. You do *not* yet have code.

## Prerequisites

- [ ] The repo is cloned, dependencies installed, and the dev server / test suite runs locally.
- [ ] You've read `AGENTS.md` and `.agent/rules/dangerous-paths.md`.
- [ ] You can name what "done" looks like in one sentence. If you can't, go back to the requester before writing code.

---

## Step 1 — Understand

**Exit when:** you can restate the feature in your own words *and* name two ways it could fail.

- Read the brief. Read it again.
- Identify the user-visible outcome. ("After this, a user can do X.")
- Identify what's *out* of scope. Equally important.
- Spot the questions only the requester can answer. Ask them now, not after building the wrong thing.

If the brief assumes data, structure, or behavior that doesn't exist yet, surface that. Don't invent.

## Step 2 — Plan

**Exit when:** you have a plan you'd be willing to defend in a review.

- Identify the files and modules the change will touch.
- Decide whether this triggers `.agent/rules/architect.md`. If yes, load it and answer its questions before continuing.
- Decide whether this triggers `.agent/rules/security.md`. If yes, load it; you'll apply the checklist later.
- Decide whether this triggers `.agent/rules/migrations.md`. If yes, design the migration sequence *before* writing code.
- Sketch the slice plan: what's the smallest thing you can build, test, and verify? What's the next slice after that?

Write the plan down somewhere reviewable (PR draft description, scratch file, or chat). A plan in your head is not a plan.

## Step 3 — Slice

**Exit when:** the work is broken into 2–6 chunks, each one independently buildable and testable.

A good slice:

- Makes one small, observable change.
- Has its own test(s).
- Could ship on its own, even if it's behind a feature flag.

If your first slice is "implement the whole feature," go back and slice harder.

## Step 4 — Build (one slice at a time)

**Exit per slice when:** the slice is implemented, its tests pass, and the rest of the suite still passes.

For each slice:

1. Write the failing test first, *or* write a smoke check that proves the current state. ("Before this slice, X returns 404.")
2. Implement the slice.
3. Run the new test. Run the full suite. Run the type checker. Run the linter.
4. Commit. Small commits are cheap. Big commits are expensive to review and bisect.

If a slice grows past what you planned, stop and re-slice. Don't push through.

## Step 5 — Self-review

**Exit when:** you've completed every pass in `.agent/rules/reviewer.md`.

Load `.agent/rules/reviewer.md` and run it against the diff. Read the actual code, not the version in your head.

## Step 6 — Apply rule checklists

**Exit when:** every applicable rule's checklist has been worked through.

Based on what the change touched:

- [ ] `.agent/rules/security.md` if any security trigger was hit.
- [ ] `.agent/rules/migrations.md` if any persisted state changed.
- [ ] `.agent/rules/docs.md` if any user-facing surface changed.
- [ ] `.agent/rules/test-writer.md` if test coverage on the change is incomplete.

## Step 7 — DoD gate

**Exit when:** every box in `.agent/rules/dod.md` is checked, or explicitly called out as deferred.

This is the gate. Do not skip. Do not paraphrase.

## Step 8 — Open the PR

**Exit when:** the PR has summary, test plan, screenshots/output if relevant, and any deferred follow-ups listed.

- Title says what changed in user terms.
- Description says *why* and links the originating ticket / brief.
- Test plan tells the reviewer how to verify it themselves.
- Anything skipped from DoD is explicit. Surprises in review burn trust.

---

## Decision points

- **Brief is ambiguous** → stop, ask, do not guess.
- **Architect.md questions surface a one-way door** → escalate to a human before building.
- **Slice grows mid-build** → re-slice, don't push through.
- **DoD has unchecked boxes you can't honestly tick** → the change is not done. Fix it or call it out and merge with explicit acknowledgment.

## Exit criteria

- Feature works end-to-end against the original brief.
- Tests prove it.
- Docs reflect it.
- DoD signed off.
- PR open with reviewer-friendly description.

## Pairs naturally with

- `.agent/personas/lead-engineer.md` during Step 2 (planning) and Step 5 (review).
- `.agent/personas/pair-programmer.md` during Step 4 (build).
