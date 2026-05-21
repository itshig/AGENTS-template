# Reviewer

> Load this **after** a feature is functionally complete, **before** committing. Review your own work the way you'd review someone else's.

## The rule

You are not allowed to commit code you haven't read end-to-end **after** writing it. The version in your head is not the version on disk.

## Pass 1 — Diff review

Look at the actual diff (`git diff`, not the editor). For each hunk:

- [ ] **Do I understand why every line changed?** If not, investigate or revert it.
- [ ] **Are there changes I didn't intend?** Stray formatting, accidental file moves, unrelated edits.
- [ ] **Are there debug artifacts?** `console.log`, `print`, breakpoints, commented-out blocks, `XXX` / `FIXME` notes I forgot.
- [ ] **Is anything secret in the diff?** Keys, tokens, real user data, internal URLs.

## Pass 2 — Read it like a stranger

Open the changed files. Read top to bottom, not just the diff. Ask:

- [ ] **Could a teammate who didn't write this understand it in one read?**
- [ ] **Are names accurate?** A function called `getUser` that also creates them is a bug waiting to happen.
- [ ] **Is the level of abstraction consistent within each function?** Mixing high-level and low-level steps in one function is a smell.
- [ ] **Are errors handled at the right layer?** Caught too early hides bugs; caught too late crashes the wrong thing.
- [ ] **Are there comments that disagree with the code?** Outdated comments are worse than no comments.

## Pass 3 — Failure modes

For each new code path, imagine it failing:

- [ ] What happens with **empty input?** `[]`, `""`, `null`, `undefined`, `0`, `{}`.
- [ ] What happens with **maximum input?** A 10MB string, a million-element array, a deeply nested object.
- [ ] What happens **concurrently?** Two requests hitting the same record. Two workers picking up the same job.
- [ ] What happens when **the network fails** mid-call? Mid-write?
- [ ] What happens when **a downstream service is slow?** Is there a timeout?
- [ ] What happens when **the user is malicious?** They will be eventually.

## Pass 4 — Tests

- [ ] Tests describe behavior, not implementation. Renaming an internal function shouldn't break tests.
- [ ] Each test fails for one reason. If it can fail for five reasons, you'll spend five times as long debugging it.
- [ ] No test depends on another test's side effects or ordering.
- [ ] No test depends on the wall clock, the network, or the file system unless that's specifically what's being tested (and then it's mocked or contained).
- [ ] Test names tell you what's being tested without reading the body.

## Pass 5 — The "why" file

If the change is non-trivial, the *why* should be findable from the code in 30 seconds:

- [ ] Commit message says **why**, not just what.
- [ ] PR description has a one-paragraph summary, a test plan, and any deferred follow-ups.
- [ ] In-code comments explain decisions a future reader would otherwise re-litigate.

## Smells worth pausing on

- A function longer than ~50 lines.
- A file longer than ~500 lines.
- A function with more than ~4 parameters.
- More than 2 levels of nesting.
- A boolean parameter (`doThing(x, true)` — what does `true` mean at the call site?).
- Copy-pasted code (3+ near-identical blocks).
- A `try/catch` that swallows the error.
- An `if/else` chain on a type or status field — usually wants a polymorphism, a map, or a switch.
- A new utility file called `helpers.ts`, `utils.py`, `misc.go`. These accrete junk. Name by purpose.

None of these are automatically wrong. All of them are worth pausing on.

## When the review surfaces a problem

- **Small problem:** fix it now.
- **Out-of-scope problem:** file it, don't bury it. A `TODO` with a ticket reference is fine. A `TODO` with no owner is not.
- **Reveals the design is wrong:** stop. Go back to `.agents/rules/architect.md`. Don't ship a workaround for an architectural mistake — workarounds become permanent.
