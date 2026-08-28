# Changelog

All notable changes to this template. Adopting repos can use this to tell what they're behind.

## [0.2.0] — 2026-08-28

### Features
- Added `rules/stack.md` — canonical commands, package manager, and verification sequence. Read at session start so no agent guesses a command.
- Added `rules/design.md` — design-system constraints: tokens, semantic color, component states, responsive behavior, accessibility floor.
- Added `rules/encryption.md`, `rules/validation.md`, `rules/logging.md` — backported from downstream repos and genericized (project-specific paths and libraries replaced with `TODO when adopting` seams).
- Added `.claude/agents/` with five sub-agent definitions: `verifier`, `reviewer`, `debugger`, `architect`, `design-reviewer`. Each is a thin wrapper over the matching rule file; none edit code.
- Added `adopt.sh` — adoption and drift-check script. Reports by default, `--apply` syncs template-owned files, `--init` seeds a new repo. Warns on the legacy `.agent/` directory.
- Pointer files are seeded for the tools actually in use: `CLAUDE.md` (Claude Code), `GEMINI.md` (Antigravity), `.cursorrules` (Cursor). Codex reads `AGENTS.md` natively and needs no pointer.
- `adopt.sh` now checks every rules file against Antigravity's 12,000-character cap and flags files that exceed or approach it.
- Added `VERSION` and this changelog.
- Added `.agents/rules/README.md` index.

### Technical
- `CLAUDE.md` now uses an `@AGENTS.md` import instead of prose instruction. Claude Code does not read `AGENTS.md` natively; the import is the supported bridge, and prose is not reliably acted on.
- Moved the `.agents/` layout documentation from the repo root `README.md` into `.agents/README.md`, where it belongs. The root `README.md` is now an actual repo README covering adoption and sync.
- Updated `AGENTS.md` §3a routing table with the five new rules, ordered so session-start files come first.
- Added `AGENTS.md` §3d documenting the sub-agent roster.
- `AGENTS.md` §4 step 5 now points at `stack.md` rather than saying "run the relevant checks."

### Notes
- Directory convention is `.agents/` (plural). Beyond the `.agents` Protocol draft and the `~/.agents/` global convention, **Antigravity reads `.agents/rules/` natively as workspace rules** — a singular `.agent/` is invisible to it. Repos using the singular form should rename; `adopt.sh` detects and flags this.
- Supersedes and replaces the abandoned `chore/standardize-agent-paths` branch (commit `9b1b3fdb5d7ca4c913337a28cf89061991eff258`, 2026-05-21), which renamed `.agents/` to `.agent/` — the opposite direction, and one that would have hidden the rules directory from Antigravity. That branch was the source of the singular/plural split between this template and the downstream repos. Everything unique to it has been merged here before deletion:
  - AES-256-GCM parameters (32-byte key, 12-byte IV, 16-byte tag) → `rules/encryption.md`
  - Semantic-commit type table → `rules/logging.md`
  - Keep a Changelog section names → `rules/logging.md`
  - `.strict()` and coercion guidance, separate body/header/query validation, webhook signature verification, and the typed failure envelope → `rules/validation.md`

  The commit SHA above remains valid for recovery via `git show` for as long as the object survives GC.
- New rule files carry `description`/`globs` frontmatter for Cursor auto-attach. Pre-existing rule files do not yet — adding it is a safe follow-up, deliberately left out of this release to keep the diff reviewable.

## [0.1.0] — 2026-05-07

### Features
- Initial framework: `AGENTS.md` entry point, `.agents/rules/` (9 files), `.agents/personas/` (2), `.agents/workflows/` (2), and `CLAUDE.md` / `GEMINI.md` pointers.
