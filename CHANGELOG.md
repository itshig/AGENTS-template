# Changelog

All notable changes to this template. Adopting repos can use this to tell what they're behind.

## [0.2.0] — 2026-08-28

### Features
- Added `rules/stack.md` — canonical commands, package manager, and verification sequence. Read at session start so no agent guesses a command.
- Added `rules/design.md` — design-system constraints: tokens, semantic color, component states, responsive behavior, accessibility floor.
- Added `rules/encryption.md`, `rules/validation.md`, `rules/logging.md` — backported from downstream repos and genericized (project-specific paths and libraries replaced with `TODO when adopting` seams).
- Added `.claude/agents/` with five sub-agent definitions: `verifier`, `reviewer`, `debugger`, `architect`, `design-reviewer`. Each is a thin wrapper over the matching rule file; none edit code.
- Added `adopt.sh` — adoption and drift-check script. Reports by default, `--apply` syncs template-owned files, `--init` seeds a new repo. Warns on the legacy `.agent/` directory.
- Added `.cursorrules` and `.github/copilot-instructions.md` pointer files.
- Added `VERSION` and this changelog.
- Added `.agents/rules/README.md` index.

### Technical
- `CLAUDE.md` now uses an `@AGENTS.md` import instead of prose instruction. Claude Code does not read `AGENTS.md` natively; the import is the supported bridge, and prose is not reliably acted on.
- Moved the `.agents/` layout documentation from the repo root `README.md` into `.agents/README.md`, where it belongs. The root `README.md` is now an actual repo README covering adoption and sync.
- Updated `AGENTS.md` §3a routing table with the five new rules, ordered so session-start files come first.
- Added `AGENTS.md` §3d documenting the sub-agent roster.
- `AGENTS.md` §4 step 5 now points at `stack.md` rather than saying "run the relevant checks."

### Notes
- Directory convention is `.agents/` (plural), consistent with the `.agents` Protocol draft and the `~/.agents/` global convention. Repos using the singular `.agent/` should rename; `adopt.sh` detects and flags this.
- New rule files carry `description`/`globs` frontmatter for Cursor auto-attach. Pre-existing rule files do not yet — adding it is a safe follow-up, deliberately left out of this release to keep the diff reviewable.

## [0.1.0] — 2026-05-07

### Features
- Initial framework: `AGENTS.md` entry point, `.agents/rules/` (9 files), `.agents/personas/` (2), `.agents/workflows/` (2), and `CLAUDE.md` / `GEMINI.md` pointers.
