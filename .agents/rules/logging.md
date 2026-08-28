---
description: Changelog and version-bump protocol. Load when code is modified, a task completes, or the manifest version changes.
globs: ["CHANGELOG.md", "package.json", "pyproject.toml", "Cargo.toml"]
---

# Changelog & Versioning

> Load when finishing a unit of work. You are responsible for keeping `CHANGELOG.md` accurate and human-readable.

> **TODO when adopting:** confirm the manifest file that carries the version (`package.json`, `pyproject.toml`, `Cargo.toml`) and delete the others from the examples below.

## 1. Batch on commit — the rule people get wrong

**Do not create a new version entry for every task.** Accumulate changes into a **single uncommitted entry** until the work is actually committed.

- If the top entry in `CHANGELOG.md` is **newer than the last git commit**, it is uncommitted — **append to it**. Do not bump.
- Only create a new entry, with a bumped number, when the top entry has already been committed.
- When unsure, check `git log` against the top entry's date. If still unsure, ask.

The failure mode this prevents: fifteen version bumps for one afternoon's work, none of which correspond to a release.

## 2. Bump level

Standard SemVer:

- **Major** — breaking changes, architectural shifts, removed features.
- **Minor** — new features, significant additions.
- **Patch** — bug fixes, refactors, dependency updates, copy changes.

Pre-1.0, a breaking change is a minor bump. Say so in the entry either way.

## 3. Format

```markdown
## [X.Y.Z] — YYYY-MM-DD

### Features
- Concise description of what was added.

### Fixes
- What was broken, and what resolved it.

### Technical
- Internal changes with no user-facing effect.
```

- Use only the sections that have content. An empty "Fixes" heading is noise.
- One line per change. If a change needs a paragraph, it needs a linked PR or issue instead.
- **Reference the file or component** when it helps a reader locate the change.

## 4. Voice

Technical, objective, past tense, no first person.

- ✅ "Added rate limiting to the password reset endpoint."
- ✅ "Fixed a race condition that duplicated queued jobs under concurrent workers."
- ❌ "I added rate limiting."
- ❌ "Fixed some bugs." — which bugs? A changelog entry nobody can act on is a wasted line.

## 5. Keep the manifest in sync

- [ ] If the version in `CHANGELOG.md` changed, the `version` field in the manifest changed to match.
- [ ] They are **never** allowed to disagree. A mismatch is a release bug waiting to happen.

## 6. Gate before finalizing

1. Is there already an uncommitted entry I should have appended to instead of bumping?
2. Does the bump level match the actual change?
3. Is the date today's date?
4. Does every line describe a change a reader could act on?
5. Does the manifest version match?
