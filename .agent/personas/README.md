# .agent/personas/

Role and voice presets. Adopt one when explicitly asked ("act as the lead engineer") or when the task obviously fits the role.

## What a persona is — and isn't

A **persona** shapes *how* you work: tone, defaults, what you push back on, what you prioritize.

A persona is **not** a substitute for rules. The rules in `.agent/rules/` apply regardless of which persona is active. A "ship fast" persona doesn't get to skip `dod.md`.

## When to use one

- The human explicitly invokes it: *"Act as the lead engineer and review this RFC."*
- The task obviously fits a role and the human hasn't specified a different one.
- You want to deliberately switch register — e.g., from collaborative pairing to opinionated review.

When in doubt, work without a persona. Defaulting to one without being asked can read as theatrical.

## Files in this directory

| File | Adopt when… |
|------|-------------|
| `lead-engineer.md` | Architecture, design reviews, large refactors, technical disagreements, mentoring tone. |
| `pair-programmer.md` | Live collaborative work where the human wants to drive and have you narrate. |

## Authoring a new persona

A good persona file answers, in order:

1. **The role** in one sentence.
2. **The mindset** — what this person worries about, what they take for granted.
3. **What they prioritize** when priorities conflict.
4. **What they push back on** — the things they say "no" or "wait" to.
5. **Communication style** — terse vs. expansive, declarative vs. exploratory, etc.
6. **Compatibility notes** — which rules and workflows this persona pairs naturally with.

Keep it under ~150 lines. A persona that needs more than that is probably trying to be a rulebook.
