# Migrations

> Load this for **any** change to database schema, persisted state, message contracts, or breaking API changes. State changes are the most expensive mistakes — treat them carefully.

## The principle

You can revert a code change in seconds. You cannot revert a deployed migration that ran against millions of rows in seconds, ever. Plan accordingly.

## Before writing the migration

Answer these:

- [ ] **What problem does this solve?** A migration without a clear reason is technical debt that's already drawn interest.
- [ ] **Is this reversible?** If yes, write the down migration. If no, document *why* and get explicit approval.
- [ ] **How big is the table?** A million-row migration is a different beast than a thousand-row one.
- [ ] **Does it block writes?** Locks during migration mean downtime. Plan for it or avoid it.
- [ ] **What runs in between?** During the rollout window, old code and new code are both running. Both have to work.

## The expand / contract pattern

Most schema changes that look like one step are safer as three:

1. **Expand** — add the new thing. Don't use it yet. Old code still works.
2. **Migrate** — backfill data, switch reads/writes to the new thing. Both shapes are valid.
3. **Contract** — remove the old thing once nothing reads or writes it.

This sequence shipped over multiple deploys is dramatically safer than "rename column" in one go.

### Examples

**Renaming a column:**
1. Add `new_name`. Backfill from `old_name` on write.
2. Switch reads to `new_name`. Keep writing both.
3. Remove writes to `old_name`. Drop `old_name`.

**Splitting one field into two:**
1. Add the two new fields. Compute and write them alongside the old field.
2. Switch reads to use the new fields. Verify in production.
3. Stop writing the old field. Drop it.

**Removing a field:**
1. Stop writing it. Verify nothing breaks.
2. Stop reading it. Verify nothing breaks.
3. Drop the column.

Each step is independently reversible. A bad deploy in step 2 doesn't lose data.

## Backfills

Backfills are migrations that touch every row. They have their own rules:

- [ ] **Batch.** Don't load a million rows into memory. Process in chunks (1k, 10k, depending on row size).
- [ ] **Idempotent.** Running the backfill twice produces the same result. If it doesn't, you can't safely retry.
- [ ] **Resumable.** A backfill that crashes halfway should resume from where it stopped, not restart.
- [ ] **Observable.** Log progress. A 6-hour backfill that emits nothing is indistinguishable from a hung one.
- [ ] **Throttled.** Don't saturate the database. Other queries are still happening.

## Locking and downtime

Operations to be careful with on busy databases:

- Adding a column with a default value (some engines rewrite the table).
- Adding an index (locks vary by engine — use concurrent / online variants where available).
- Changing a column's type.
- Adding a `NOT NULL` constraint to an existing column.
- Foreign key additions.

Know your engine's behavior. When in doubt, test on a copy of production-sized data first.

## Data integrity

- **Validate before, validate after.** Count rows. Spot-check a sample. Confirm the migration did what it claimed.
- **Constraints catch bugs.** If a field should never be null, enforce it in the schema, not just in code. Code lies; constraints don't.
- **Foreign keys are not optional** unless you have a deliberate reason. Orphan rows are forever.

## Breaking API / contract changes

Same principle as schemas: expand → migrate → contract.

- Don't change a field's meaning. Add a new field with the new meaning, deprecate the old one, remove later.
- Don't repurpose an enum value. Add a new one.
- Versioning headers, URL versions, or content-type versions — pick one, document it, stick with it.
- Deprecation period announced before removal, not after.

## Rollback plan

For every migration, write down:

- [ ] **How to roll back the deploy** if the migration succeeded but the code is broken.
- [ ] **How to roll back the migration** if the migration itself is the problem.
- [ ] **How to recover the data** if both the migration and the rollback are wrong.

If the answer to the third one is "we can't" — that's a stop. Get a backup, take a snapshot, *then* run.

## Production safety checklist

Before running anything destructive against production:

- [ ] Backup or snapshot taken within the last hour.
- [ ] Migration tested on staging with production-shaped data.
- [ ] Runbook reviewed by someone who isn't running it.
- [ ] Rollback path tested, not just written.
- [ ] A human is watching the deploy. Not "will check later." Watching.
- [ ] Off-hours or low-traffic window if the operation is heavy.

## Things to never do

- **Never** `DROP TABLE` / `DROP COLUMN` in the same deploy as the code change that stops using it. Two deploys minimum.
- **Never** run an untested migration against production "to see what happens."
- **Never** edit a migration file after it's been applied to any environment. Write a new migration that fixes it forward.
- **Never** backfill via an unbounded `UPDATE … WHERE …` on a large table. Batch it.
- **Never** trust that "no one is using that column." Search the codebase. Check the logs. Ask the team.
