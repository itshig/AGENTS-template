# Debugger

> Load this when you've been stuck on a non-obvious failure for ~10 minutes. The goal is to **stop flailing** and work the problem methodically.

## The first rule

**Do not change anything until you can explain what's wrong.**

Random changes that "might fix it" produce confused state, lost time, and false fixes. If you find yourself making a change because "let's just try it," stop. Reset. Read this file.

## The loop

1. **State the bug precisely.** Not "it's broken." Write down: what you did, what you expected, what actually happened, and what's different about it.
2. **Form a hypothesis.** "I think X is causing Y because Z." If you can't, you don't have enough information yet — gather more.
3. **Design the cheapest experiment** that would *disprove* the hypothesis.
4. **Run it. Observe.**
5. If disproved, hypothesis was wrong — form a new one. If supported, narrow further or ship the fix.

If you've been at it for an hour and the loop hasn't moved, your model of the system is wrong somewhere. Step back and question an assumption.

## Reproduce first

A bug you can't reproduce is a bug you can't fix. Before anything else:

- [ ] Can you make it happen on demand?
- [ ] What's the smallest sequence of steps that triggers it?
- [ ] Does it happen on a fresh checkout? In CI? In production only?

If it only happens "sometimes," that's a clue, not a wall: timing, ordering, state, environment.

## Bisect

If a thing used to work and now doesn't, **find the change that broke it**:

- `git bisect` between a known-good and known-bad commit.
- For data bugs: which records work, which don't, what's different about them?
- For environment bugs: which machines work, which don't, what's different?

Narrow until the difference is one variable.

## Read the actual error

- Read the **whole** stack trace, not just the top line.
- The frame where the exception was *raised* is rarely the frame where the *bug* lives.
- Error messages are usually accurate. If one seems wrong, double-check that you're reading what you think you're reading (right log file, right environment, right deploy).

## Common patterns

When you're stuck, walk this list:

- **Stale state.** Old cache, old build artifact, old session, old database row, old browser tab. When in doubt, restart and try again from a known-clean state.
- **Wrong file.** You're editing one file and running another. Check your imports, your build config, your `PATH`.
- **Wrong environment.** Dev DB vs prod DB. Local config vs deployed config. The variable is set in your shell but not in the service.
- **Off-by-one.** Indices, ranges, dates, time zones, inclusive/exclusive boundaries.
- **Concurrency.** Race conditions hide until they don't. If a bug is intermittent and timing-related, suspect this.
- **Hidden mutation.** Something is modifying a value you thought was immutable. Print the value before and after the suspect call.
- **Encoding / type coercion.** Strings vs numbers, UTF-8 vs Latin-1, dates as strings vs Date objects, booleans that are actually strings.
- **Implicit defaults.** A library is doing something you didn't tell it to. Read the docs of the function you're calling, not the function you wish you were calling.

## Print, then inspect

`printf` debugging is not beneath you. It's often the fastest way to find truth.

- Print **before and after** the line you suspect.
- Print the **values you assume**, not just the values you compute.
- Print **types** when behavior is weird (`typeof`, `type()`, `repr()`).
- Print with **labels** so you can find the line in the noise.

A debugger is better when you have one and the loop is slow. A `print` is better when the loop is fast and the system is opaque.

## Rubber duck

Out loud, to a human or a duck or a chat window: explain what you're doing, what you expect, and what you're seeing. The act of articulating it surfaces the wrong assumption ~30% of the time. It's not magic — you're forced to be precise where you'd been hand-waving.

## When to ask for help

Ask for a fresh pair of eyes when:

- You've been stuck for more than ~30 minutes with no new information.
- You've formed three hypotheses in a row that all turned out wrong.
- You're about to make a change you can't fully justify.
- The bug is in a part of the system you don't know well.

When you ask, lead with: **what you tried, what you saw, what you concluded.** Not "it's broken, help."

## After the fix

- [ ] Write the regression test. The test should fail without your fix. If it doesn't, you're fixing the wrong thing.
- [ ] Understand the root cause well enough to explain it in one sentence. If you can't, you've patched a symptom.
- [ ] Look for the same pattern elsewhere in the codebase. Bugs come in families.
- [ ] If the bug was hard to find, that's a signal. Add a log, a metric, or a comment that would have made the next one easier.
