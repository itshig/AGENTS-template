# Test Writer

> Load this when adding tests, fixing flaky tests, or noticing a change that ships without coverage.

## What to test

Test **behavior**, not implementation. A good test still passes after a refactor that doesn't change behavior, and fails when behavior changes.

For each change, ask: "If this code silently broke, what test would catch it first?" Write that one.

### Always test

- The happy path. The thing the user actually does.
- The boundaries: empty, one, many, max.
- The error paths you handle (and prove they're handled the way you claim).
- Bug fixes: write a test that fails before the fix and passes after. No regression test, no fix.

### Don't bother testing

- Generated code (unless the generator is yours).
- Trivial getters/setters with no logic.
- Third-party library internals (test the integration, not the library).
- Implementation details that exist only to make the code work — those should change freely.

## How to write a test

A good test answers three questions in this order:

1. **Arrange** — what's the world like?
2. **Act** — what happens?
3. **Assert** — what should be true now?

Keep these visually separated. Reading a test should be faster than reading the code under test.

```python
def test_user_cannot_withdraw_more_than_balance():
    # Arrange
    account = Account(balance=100)

    # Act
    result = account.withdraw(150)

    # Assert
    assert result.ok is False
    assert account.balance == 100
```

## Naming

Test names describe the behavior in plain English:

- `test_user_cannot_withdraw_more_than_balance` ✅
- `test_withdraw_2` ❌
- `test_negative_case` ❌

If you can't name it, you don't yet know what you're testing.

## One reason to fail

Each test should fail for **one reason**. If a test breaks, you should know exactly what broke without reading the test body.

- One assertion per concept (not necessarily one `assert`, but one *idea*).
- No "while we're here, let's also check…"
- Setup that's reused goes in fixtures or factories, not copy-pasted.

## Determinism

A flaky test is worse than no test — it teaches the team to ignore failures.

- No real network calls. Mock the boundary.
- No real time. Inject a clock or freeze time.
- No real randomness. Seed it or inject the value.
- No real filesystem unless that's what's being tested (and then use a temp dir).
- No dependence on test order. Each test sets up its own world.

## Fixing a flaky test

Don't retry. Don't skip. Find the actual cause:

1. Run it 100 times locally. Get it to fail.
2. Read what the test depends on that isn't in its setup. That's almost always the cause.
3. Inject the dependency or stabilize it.
4. Verify by running 100 times again.

If you genuinely can't reproduce: file the flake with a dump of the failure, mark it as a known flake, and time-box when it must be fixed by. Do not silently let CI pass.

## Coverage

Coverage is a **smoke detector**, not a goal.

- Low coverage on critical paths is a real problem. Fix it.
- High coverage with shallow tests is theater. Don't chase the number.
- A line is "covered" if it executes; that doesn't mean its behavior is verified.

## Test types — when to reach for which

- **Unit:** pure logic, no I/O. Should be fast (ms) and abundant.
- **Integration:** your code + a real boundary (DB, queue, HTTP). Slower, fewer, focused on the boundary.
- **End-to-end:** the system as a user sees it. Few of these. They catch what nothing else can but they're slow and brittle.

If you're writing an E2E test for something a unit test could catch, write the unit test instead.

## Test data

- Build factories or builders, not piles of literals.
- The data in a test should highlight what matters and hide what doesn't. If the test doesn't care about the user's email, the email shouldn't be in the test.
- Never use real production data in tests. Even anonymized. Generate it.
