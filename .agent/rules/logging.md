# Version Logging

> Load this rule for all changelog updates, version bumps, or when preparing commits/releases.

## Triggers
- Any release, version bump, or patch.
- Adding, modifying, or removing features that affect users or API consumers.
- Bug fixes, security patches, or configuration changes that require cataloging.

## 1. Commit Messages (Semantic Commits)
All commits MUST follow the Semantic Commit format: `type(scope): description`
- `feat`: A new feature (e.g., `feat(auth): add MFA support`)
- `fix`: A bug fix (e.g., `fix(encryption): resolve IV reuse issue`)
- `chore`: Maintenance tasks, dependencies, build, or tooling (e.g., `chore(deps): update prisma`)
- `docs`: Documentation changes (e.g., `docs(api): update server action inputs`)
- `refactor`: Code changes that neither fix a bug nor add a feature
- `test`: Adding or correcting tests

## 2. Changelog Standard (`CHANGELOG.md`)
Every user-facing or significant change MUST be logged in a root-level `CHANGELOG.md` file using the Keep a Changelog standard.

### Structure
Group changes under the following subheadings:
- `### Added` for new features.
- `### Changed` for changes in existing functionality.
- `### Deprecated` for soon-to-be-removed features.
- `### Removed` for now-removed features.
- `### Fixed` for any bug fixes.
- `### Security` in case of vulnerabilities.

### Guidelines
- **Be clear**: Write descriptions for developers and consumers, not just git history dumps.
- **Reference issues/PRs**: Include ticket or pull request numbers in parentheses.
- **Version bump**: Follow Semantic Versioning (`MAJOR.MINOR.PATCH`).
  - `MAJOR`: Incompatible API changes.
  - `MINOR`: Backwards-compatible functionality additions.
  - `PATCH`: Backwards-compatible bug fixes.

---

**When in doubt, log it.** Future developers will thank you.
