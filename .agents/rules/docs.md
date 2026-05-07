# Docs

> Load this when public APIs, env vars, CLI flags, or any user-facing surface changes. Docs that disagree with code are worse than no docs.

## What "user-facing" means

Anyone who uses something without reading its source. That includes:

- External users of an HTTP/SDK API.
- Other teams calling your service or library.
- Operators reading the README to deploy the thing.
- Future you, six months from now.

## What needs to be in sync

If a change touches any of the following, the corresponding docs change in the **same commit / PR**, not later:

- [ ] **README.md** — the front door. If onboarding changed, this changed.
- [ ] **CHANGELOG.md** (or release notes) — every user-visible change. Date and version.
- [ ] **API reference** — endpoints, parameters, response shapes, error codes.
- [ ] **`.env.example`** (or equivalent) — every env var the app reads, with a comment.
- [ ] **CLI `--help` text** — every flag, every command.
- [ ] **Migration guides** — for any breaking change.
- [ ] **In-code doc comments** — for any public function or type whose signature or behavior changed.

## How to write docs

### Lead with the answer

The first sentence answers the most likely question. Background and caveats follow. Most readers leave after the first paragraph — give them what they need first.

### Show, then tell

A working example is worth ten paragraphs of prose. For any non-trivial concept, include a runnable snippet with realistic values.

```bash
# Good
curl -X POST https://api.example.com/v1/widgets \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"name": "blue widget", "size": 42}'
```

```bash
# Less good
# Send a POST request with a JSON body containing the widget's properties.
```

### Concrete over abstract

- "Returns a list of users" → "Returns a list of `User` objects, ordered by `created_at` descending, capped at 100."
- "Configurable timeout" → "Timeout in milliseconds. Default `5000`. Min `100`, max `60000`."

### Honest about limits

Document what *doesn't* work, what's slow, what's deprecated, what's experimental. Surprises in production are expensive; surprises in docs are free.

## README structure

A README that works:

1. **One sentence** explaining what this is. (Not "this project is…" — name and verb.)
2. **One paragraph** explaining who it's for and why they'd use it.
3. **Quick start** — the shortest path from clone to running.
4. **Configuration** — env vars, config files, defaults.
5. **Common tasks** — the 3–5 things people will actually do.
6. **Troubleshooting** — top failures and how to recover.
7. **Contributing / development** — how to run tests, conventions, where to file issues.

If your README has 12 sections and 8 of them are aspirational, cut the 8.

## Doc comments

For public functions, types, endpoints:

- What it does (one line).
- What each parameter means and its constraints.
- What it returns.
- What errors / exceptions it can produce, and when.
- An example, if usage is non-obvious.

```python
def transfer(from_id: str, to_id: str, amount: int) -> Transfer:
    """Move `amount` cents from one account to another.

    Args:
        from_id: Source account UUID. Must be active and have sufficient balance.
        to_id: Destination account UUID. Must be active.
        amount: Amount to transfer, in cents. Must be > 0.

    Returns:
        The completed Transfer record.

    Raises:
        InsufficientFunds: from_id balance < amount.
        AccountInactive: either account is suspended or closed.
        SameAccount: from_id == to_id.
    """
```

## Changelogs

Each entry tells a user:

- **What changed** (in user terms, not implementation terms).
- **Whether it's breaking.**
- **What they need to do**, if anything.

Group by `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`. Most recent on top. Date every release.

## What to avoid

- **Marketing voice.** "Robust, scalable, enterprise-grade" tells the reader nothing.
- **Aspirational features.** Don't document things that don't work yet.
- **Stale screenshots.** They lie loudly. If the UI changes weekly, use small screenshots and replace them often, or use ASCII / descriptions.
- **Cleverness.** Plain language wins. Save the wordplay for a blog post.
- **Wall-of-text without examples.** If a section is more than 3 paragraphs and has no code, something's missing.
