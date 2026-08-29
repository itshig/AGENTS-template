# Changelog

All notable changes to this template. Adopting repos can use this to tell what they're behind.

Format follows [Keep a Changelog](https://keepachangelog.com/) — the same standard `.agents/rules/logging.md` requires of adopters.

## [0.2.1] — 2026-08-28

### Changed
- `AGENTS.md` trimmed from 10,905 to ~9,600 bytes. It loads every session and is checked against Antigravity's 12,000-byte cap, which truncates silently — the previous size left an adopting repo at ~95% of the cap once section 2 was filled in. Sections 6 and 7 merged into one section of pointers at `reviewer.md` and `design.md` rather than restating them; the routing-table cells and the `.agents/` layout diagram were compressed (the diagram is verbatim in `.agents/README.md`). Every routing row and trigger is preserved.
- `adopt.sh` "approaching cap" threshold raised from 10,000 to 11,000 bytes. At 10,000 it fired on every correct adoption, which is the same noise problem as unresolvable drift — a warning that always fires is a warning nobody reads. The 12,000 hard cap is unchanged.
- `adopt.sh` size header now says "bytes" rather than "chars". The check uses `wc -c`, and multi-byte characters make the two differ; bytes is the conservative reading.

### Fixed
- `AGENTS.md` §1 told adopters to create `.cursorrules` and `.github/copilot-instructions.md` as pointer files. Both were removed in 0.2.0 — Codex and Cursor read `AGENTS.md` directly. The instruction now names only the pointers the template actually ships.
- Section numbering skipped 7 after the merge; renumbered.

## [0.2.0] — 2026-08-28

### Added
- `rules/stack.md` — canonical commands, package manager, and verification sequence. Read at session start so no agent guesses a command.
- `rules/design.md` — design-system constraints: tokens, semantic color, component states, responsive behavior, accessibility floor.
- `rules/encryption.md`, `rules/validation.md`, `rules/logging.md` — backported from downstream repos and genericized, with `TODO when adopting` seams in place of project-specific paths and libraries.
- `.claude/agents/` — five sub-agents: `verifier`, `reviewer`, `debugger`, `architect`, `design-reviewer`. Each is a thin wrapper over a rule file; none can edit code.
- `adopt.sh` — adoption and drift-check script. Reports by default; `--apply` syncs template-owned files; `--init` seeds a new repo. Detects the legacy `.agent/` directory and checks every rules file against Antigravity's 12,000-character cap.
- `.agents/RULES-INDEX.md` — index of every rule file.
- `VERSION` and this changelog.

### Changed
- **Directory convention is `.agents/` (plural).** Antigravity reads `.agents/rules/` as workspace rules directly. It still reads a singular `.agent/rules` as a deprecated fallback, so existing repos are not broken — but plural is the default going forward, and no other tool here looks at the singular form. `adopt.sh` detects and flags it.
- `rules/dod.md` — added a Design section, and wired the gate to `stack.md` (for what "the checks pass" means), `validation.md`, and `encryption.md`. Every adopting repo receives this via `--apply`.
- `CLAUDE.md` now uses an `@AGENTS.md` import instead of prose. Claude Code does not read `AGENTS.md` natively; the import is the supported bridge, and prose is not reliably acted on.
- `GEMINI.md` reworded to match, and confirmed necessary — Antigravity reads it.
- `AGENTS.md` §3a routing table extended with the five new rules, ordered so session-start files come first; new §3d documents the sub-agent roster; §4 step 5 now points at `stack.md`.
- `workflows/new-feature.md` step 4 now points at `stack.md` rather than naming commands.
- Moved the `.agents/` layout documentation from the repo root `README.md` into `.agents/README.md`. The root `README.md` is now an actual repo README covering adoption, sync, and tool coverage.
- `.gitignore` simplified to cover `.DS_Store` recursively.

### Removed
- `.cursorrules` — Cursor reads `AGENTS.md` natively, so a pointer file adds nothing. Cursor's own rules format is `.mdc` files in `.cursor/rules/`, which this template does not ship.

---

This release supersedes the abandoned `chore/standardize-agent-paths` branch, which renamed in the opposite direction and was the source of the singular/plural split between this template and its downstream repos. Everything unique to it was merged here before deletion:

- AES-256-GCM parameters (32-byte key, 12-byte IV, 16-byte tag) → `rules/encryption.md`
- Semantic-commit type table and Keep a Changelog section names → `rules/logging.md`
- `.strict()` and coercion guidance, separate body/header/query validation, webhook signature verification, and the typed failure envelope → `rules/validation.md`

That branch is preserved as the annotated tag **`archive/standardize-agent-paths`** (commit `9b1b3fd`). The tag is what makes it recoverable — the commit is otherwise unreachable and would be garbage-collected.

Rule files carry `description`/`globs` frontmatter. This is live for Antigravity and useful to human readers; it is inert for Cursor, which only reads `.mdc` files under `.cursor/rules/`.

## [0.1.0] — 2026-05-07

### Added
- Initial framework: `AGENTS.md` entry point, `.agents/rules/` (9 files), `.agents/personas/` (2), `.agents/workflows/` (2), and `CLAUDE.md` / `GEMINI.md` pointers.
