# Adopting this template

The runbook for putting this template into a repo, and for keeping it current afterward.

`adopt.sh` does the mechanical part in about a second. The rest — the part that actually makes the config worth having — is filling in six files with facts about *this* repo. That's the work. Budget 30–60 minutes for a first adoption.

---

## Part 1 — First-time adoption

### 0. Branch first

```bash
cd /path/to/target-repo
git checkout -b chore/adopt-agents-template
```

Never adopt on `main`. The diff is large and you want it reviewable.

### 1. Survey before you touch anything

You're about to write down this repo's commands and constraints. Get them right by looking, not by assuming.

```bash
# What agent config already exists?
git ls-files | grep -Ei '^\.agent|^\.claude|^\.cursor|AGENT|CLAUDE|GEMINI'

# Commands, versions, package manager
node -e 'const p=require("./package.json");console.log(p.version);console.log(p.scripts)'
ls | grep -Ei 'lock|nvmrc'

# Is there actually a test suite?
find . -path ./node_modules -prune -o \( -name '*.test.*' -o -name '*.spec.*' \) -print | head

# Does the repo hide .claude/ from git?  ← the trap, see step 3
grep -nE '^\s*!?\.(claude|agents?|cursor)' .gitignore
```

**Salvage check.** If the repo already has rules with the same names the template ships (`dod.md`, `security.md`), `--init` will overwrite them. Diff them against the template first and move anything project-specific into a seam file, where it's safe.

### 2. Run it

```bash
/path/to/AGENTS-template/adopt.sh . --init
```

`--init` seeds everything: template-owned rules, personas, workflows, sub-agents, the six seam files, and the root pointers. It **never overwrites** a root file or a seam file that already exists — so an existing `AGENTS.md` survives and you merge by hand.

Run it with no `--init` any time to see drift without changing anything.

### 3. Fix `.gitignore` — the trap that has bitten every repo so far

The template ships `.claude/agents/` and `.claude/agent-memory/`. If your `.gitignore` has a bare `.claude/`, **git silently refuses to track them** and the adoption looks complete locally while arriving empty for everyone else.

Git cannot re-include a child of an ignored *directory*. Exclude the contents instead:

```gitignore
.claude/*
!.claude/agents/
!.claude/agent-memory/
!.claude/launch.json      # and anything else you share
```

Local state (`settings.local.json`, `worktrees/`, `skills/`) stays ignored. Verify rather than assume:

```bash
git check-ignore -v .claude/agents/reviewer.md   # should print nothing
```

### 4. Fill the six seams

This is the actual work. `--init` seeds these with `TODO when adopting` markers:

```bash
grep -rn 'TODO when adopting' AGENTS.md .agents/rules/
```

| Seam | What goes in it | Where the facts are |
| ---- | --------------- | ------------------- |
| `stack.md` | Every command, the package manager, pinned versions, layout, gotchas | `package.json`, lockfile, config files |
| `dangerous-paths.md` | What needs approval — money, email, migrations, secrets, deploys | `src/app/api/`, cron routes, `.env.example`, CI workflows |
| `design.md` | Pointer to the design source of truth, plus the traps | `globals.css`, `tailwind.config.*`, `DESIGN.md`, design specs |
| `validation.md` | The library and version, where schemas live, every input boundary | Route handlers, server actions |
| `encryption.md` | The real algorithm and format — or **"dormant"** and what would change that | The crypto module, if any |
| `logging.md` | Which manifest carries the version; whether a `CHANGELOG.md` exists | `package.json`, `CHANGELOG.md` |

**Rules for filling them well:**

- **Run every command you write down.** A command you didn't run is a guess. This is how you learn `npm run lint` is bare `eslint`, not `next lint`.
- **Write what's absent, loudly.** "There is no test suite" prevents an agent from running `npm test`, getting a missing-script error, and reporting a broken suite.
- **Pin versions that are ahead of training data.** Next 16, Tailwind 4, Zod 4, Auth.js v5 beta — say so explicitly, because recalled knowledge will be wrong and confidently so.
- **Record gaps you find but don't fix.** Missing rate limit, PII in logs. Recording is the deliverable; fixing is a separate decision.
- **Point, don't copy.** If a 13KB `DESIGN.md` exists, `design.md` points at it. Copying creates the drift this template exists to prevent — and anything over 12,000 bytes can't live in `.agents/rules/` anyway.

### 5. Write `AGENTS.md` section 2

`--init` leaves section 2 as TODOs if the file is new, or keeps your existing file untouched. Either way you write this by hand: what the project is, the stack, entry points, and the run/test/build commands.

**Watch the byte count.** Antigravity truncates every file in `.agents/rules/` — and this file — at 12,000 bytes, silently.

```bash
wc -c AGENTS.md    # aim under ~11,000
```

**Watch for machine-managed blocks.** Next.js injects a `<!-- BEGIN:nextjs-agent-rules -->` block into `AGENTS.md` and may rewrite it. Preserve it byte-identical, keep it at the top, and say in the file that nothing should edit inside those markers.

### 6. Verify

```bash
/path/to/AGENTS-template/adopt.sh .        # must exit 0, no TODOs left
```

Then run the gauntlet you just documented in `stack.md` — if you wrote it correctly, this is the proof:

```bash
npm run lint && npx tsc --noEmit && npm test
```

Last check: confirm you touched no application code.

```bash
git status --porcelain | awk '{print $2}' | grep -Ev '^\.agents/|^\.claude/|^(AGENTS|CLAUDE|GEMINI)\.md$|^\.gitignore$'
```

### 7. Commit

Say what you found, not just what you added. The findings are the valuable part of the diff.

---

## Part 2 — Syncing an already-adopted repo

When the template gets a new version:

```bash
cd /path/to/adopted-repo && git checkout -b chore/sync-agents-template
/path/to/AGENTS-template/adopt.sh . --apply
```

`--apply` overwrites template-owned files and **never touches your seam files**. Verify that claim rather than trusting the "kept" label:

```bash
git diff --name-only -- .agents/rules/stack.md .agents/rules/design.md \
  .agents/rules/dangerous-paths.md .agents/rules/encryption.md \
  .agents/rules/logging.md .agents/rules/validation.md
# empty = your work is intact
```

Then check three things `--apply` deliberately cannot do for you:

1. **Root files.** `AGENTS.md` is yours — `--apply` never rewrites it. New template features (like sub-agent memory) need a manual paragraph in section 3d.
2. **`.gitignore`.** A new shipped directory may need a new negation.
3. **The gauntlet.** Run it.

---

## What `adopt.sh` will and won't do

| Category | Files | `--apply` behavior |
| -------- | ----- | ------------------ |
| Template-owned | Generic rules, personas, workflows, sub-agents, both READMEs | **Overwritten.** Don't edit these in place — edit the template and re-sync. |
| Seam files | `stack`, `design`, `dangerous-paths`, `validation`, `encryption`, `logging` | **Never overwritten.** `--check` tells you when the template's copy moved. |
| Root files | `AGENTS.md`, `CLAUDE.md`, `GEMINI.md` | **Seeded once** on `--init`, never after. |
| Yours | Anything you author, plus all of `.claude/agent-memory/` | **Untouched.** Listed as `? unshipped`, never deleted. |

Exit codes: `1` on drift, an over-cap rules file, or a broken symlink. `0` when clean. Sub-agent memory over its 200-line / 25KB window is reported but never fails the check.

---

## The traps, in one list

Every one of these has actually happened.

1. **Bare `.claude/` in `.gitignore`** — sub-agents and their memory silently untracked.
2. **Two stacked YAML frontmatter blocks** in a rule file — only the first is parsed; the second is inert text. Check with `awk '/^---$/{c++} END{print c}' file.md` — more than 2 means trouble.
3. **`AGENTS.md` over 12,000 bytes** — truncated silently, and the tail is usually a real rule.
4. **A large `DESIGN.md` moved into `.agents/rules/`** — same cap, same silent truncation. Leave it at the root and point at it.
5. **Duplicate root files** — `AGENT.md`, `AGENTS.md`, and `CLAUDE.md` holding the same body. One canonical file; the rest are pointers.
6. **A verification command with a side effect** — `npm run build` that runs `prisma migrate deploy` writes to whatever database is loaded. Never put it in the default gauntlet.
7. **Machine-managed blocks** in `AGENTS.md` — preserve them byte-identical.
8. **Docs that tell you to create files the template no longer ships.** After changing the template, grep the prose, not just the file list.
