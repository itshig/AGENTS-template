# Definition of Done

> The gate every change passes before it's "done." Run this checklist explicitly. Do not paraphrase.

A change is **done** when *all* of the following are true. If any item doesn't apply, say so out loud — don't silently skip.

## Functional

- [ ] The change does what was asked. Re-read the task. Match it line by line.
- [ ] Edge cases considered: empty input, max input, null/undefined, concurrent calls, network failure, permission denied.
- [ ] No regressions in adjacent functionality you touched or imported from.

## Tests

- [ ] New behavior has tests that would fail without the change.
- [ ] Bug fixes have a regression test that reproduces the original bug.
- [ ] The full test suite passes locally. Not "should pass" — actually ran, actually green.
- [ ] No tests were skipped, deleted, or weakened to make CI happy.

## Code quality

- [ ] Types check (no `any`, no `// @ts-ignore`, no `# type: ignore` without a comment explaining why).
- [ ] Linter passes with no new warnings.
- [ ] Formatter has been run.
- [ ] No dead code, commented-out code, or stray `console.log` / `print` / debug statements.
- [ ] No TODOs without an associated ticket or comment explaining the next step.

## Security

- [ ] If the change touches anything in `.agents/rules/security.md` triggers, that file was loaded and its checklist applied.
- [ ] No secrets, keys, or credentials in source, logs, or test fixtures.
- [ ] User input is validated before use; output is escaped/encoded for its sink.

## Data and migrations

- [ ] If schema or persisted data changed, `.agents/rules/migrations.md` was loaded and its checklist applied.
- [ ] Migrations are reversible (or the irreversibility is documented and approved).

## Documentation

- [ ] Public API changes are reflected in the docs.
- [ ] New env vars are documented in `.env.example` (or equivalent) with a comment.
- [ ] New CLI flags / commands have help text.
- [ ] If user-facing behavior changed, the README / changelog / release notes are updated.

## Performance and cost

- [ ] No obvious N+1 queries, unbounded loops, or unbounded memory growth introduced.
- [ ] Long-running operations have timeouts.
- [ ] If the change calls a paid API, the cost characteristics are understood and acceptable.

## Operational

- [ ] Errors are logged with enough context to debug from logs alone.
- [ ] Logs don't contain PII, secrets, or full request/response bodies.
- [ ] The change is observable: a human watching dashboards/logs can tell if it's working.

## Hand-off

- [ ] Commit message says **what** changed and **why** (not just what).
- [ ] PR description includes: summary, test plan, screenshots/output if relevant, any follow-ups deferred.
- [ ] Anything skipped on this list is called out explicitly in the PR description.

---

**If you cannot honestly check a box, the change is not done.** Saying "done" when it isn't is the single most expensive lie in software.
