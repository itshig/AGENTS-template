# Dangerous Paths

> **Always read this file at the start of any session.** It lists files, directories, and operations that require explicit human approval — not implicit, not "I think they meant this."

## How to use

When the task involves anything below, **stop and ask** before acting. A specific question with the exact intended change is the right move:

> "I'm about to run `prisma migrate deploy` against the production database to add the `accounts.deactivated_at` column. The migration is in `prisma/migrations/2024…`. Confirm to proceed?"

Not:

> "Should I run the migration?"

---

## Files and directories

> **TODO when adopting:** list the actual paths in your project. Examples below.

- `infra/` — infrastructure as code (Terraform, Pulumi, CDK).
- `.github/workflows/` — CI/CD pipelines.
- `migrations/` / `prisma/migrations/` / `db/migrate/` — database schema changes.
- `Dockerfile`, `docker-compose.*.yml` — runtime environment definitions.
- `package.json` (the `scripts` and `dependencies` blocks specifically).
- `.env*` files — never commit, never read out loud, never echo to logs.
- `secrets/`, `keys/`, `certs/` — credentials of any kind.
- The protected branch (`main` / `master`) — never push directly.

## Commands

Operations that require approval **every time**, even if they worked yesterday:

- `git push --force` (or `--force-with-lease` on shared branches).
- `git reset --hard` on anything not strictly local.
- `rm -rf` on anything outside a clearly scratch directory.
- Any database command containing `DROP`, `TRUNCATE`, `DELETE FROM` without a `LIMIT`.
- Any production deploy, migration, or restart.
- `npm publish`, `cargo publish`, `pypi upload` — anything that publishes a package.
- Sending email or notifications from production credentials.
- Charging, refunding, or moving money via a payment processor — even in a "test mode" that's pointed at a real account.
- Bulk operations against a third-party API (sending many messages, mass-updating records).

## State changes that look harmless but aren't

- Modifying a feature flag in production.
- Changing a DNS record.
- Updating a redirect or rewrite rule.
- Editing a webhook URL or secret.
- Rotating a key (the rotation itself is fine; the question is whether everything that uses it has been updated).
- "Quick" config edits in a hosting dashboard that don't go through code review.

## Approval format

When asking for approval, include:

1. **What** — the exact command or change.
2. **Where** — environment, account, target.
3. **Why** — the task this is part of.
4. **Blast radius** — what's affected if it goes wrong.
5. **Rollback** — how you'd undo it.

Approval is for the specific change described, not a class of changes. "Yes, deploy the migration" doesn't authorize the next migration.

## Session boundaries

Approvals do not carry across sessions. If a previous session was authorized to do X, this session is not — re-confirm.

---

**When in doubt: ask.** The cost of asking is seconds. The cost of guessing wrong is sometimes hours, sometimes a weekend, sometimes a job.
