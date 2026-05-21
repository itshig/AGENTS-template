# Workflow: Incident Response

> Use when production is broken, behaving wrong, or showing symptoms that suggest it might be. The goal is **stop the bleeding first, understand the wound second.**

## Trigger

Any of:

- An alert is firing.
- A user reports the system is broken or behaving wrong.
- A deploy is showing post-release symptoms.
- A metric is moving in a direction that suggests something's off.
- You have a bad feeling. Bad feelings are signal.

## Prerequisites

- [ ] You have credentials to read production logs / metrics. If not, escalate immediately.
- [ ] You know how to roll back the most recent deploy. If you don't, find out *before* doing anything else.
- [ ] You've read `.agent/rules/dangerous-paths.md`. Many incident-response actions live there.

---

## Step 1 — Acknowledge and timestamp

**Exit when:** you've started a running log of what's happening and what you're doing.

- Note the time you started.
- Note the symptom in one sentence.
- Open a scratch doc, a chat thread, or an incident channel and write to it as you go. **Future-you needs the timeline.**

The log doesn't have to be pretty. It has to exist.

## Step 2 — Stabilize first, diagnose second

**Exit when:** the bleeding has stopped, even if you don't yet know why.

Order of operations is **not** "find the bug, then fix it." It's:

1. **Is rollback possible and likely to help?** If the symptom started after a recent deploy, roll back. Diagnose afterward. A reverted deploy is recoverable; a multi-hour outage is not.
2. **Can you disable the broken feature?** Feature flag, kill switch, traffic shift. Take the bad code path out of the request flow.
3. **Can you reduce blast radius?** Rate limit, circuit-break, queue, or shed load until you understand it.
4. **Only then**, start diagnosing the root cause.

Heroic debugging in production while users are affected is a failure mode, not a virtue.

## Step 3 — Communicate

**Exit when:** the people who need to know, know.

- Internal: the team, on-call, anyone whose work depends on the affected system.
- External (if applicable): the customer-facing status page or comms channel. Even a "we're investigating" message buys enormous goodwill compared to silence.
- Cadence: update at least every 30 minutes during an active incident, even if the update is "still investigating, no new info."

Underpromise. Don't predict resolution times unless you're sure.

## Step 4 — Identify scope

**Exit when:** you can answer: *who is affected, since when, by how much?*

- Which users, regions, tenants, or features?
- When did it start? Correlate with deploys, config changes, traffic spikes, third-party incidents.
- What is the user-visible impact? (Errors? Slowness? Wrong data? Silent failure?)

Scope shapes everything else: a 100% outage and a 0.1% error spike get different treatment.

## Step 5 — Root cause

**Exit when:** you can name the actual cause, not just the symptom.

Load `.agent/rules/debugger.md` if you're stuck. The structured loop applies in production too — actually more so, because the cost of a wrong guess is higher.

Resist these tempting traps:

- **"It started working again on its own."** No it didn't. Something changed. Find out what.
- **"It must be the network."** Maybe. But "the network" is rarely the root cause; it's usually the trigger that exposed a latent bug.
- **"This one weird record."** One weird record means there are probably others. Investigate the class, not the instance.

## Step 6 — Real fix

**Exit when:** the fix is deployed and the symptom is gone *and stays gone*.

- The fix addresses the root cause, not the symptom. (If you only have time for a symptom fix, that's fine — but log the followup explicitly.)
- The fix has a test that would have caught the bug. If it doesn't, you'll see this incident again.
- The fix went through the normal change process where possible. Emergency overrides exist; they should be rare and documented.
- Verify in production. "Should be fixed" is not the same as "is fixed." Watch metrics after the deploy.

## Step 7 — Stand down

**Exit when:** the system is stable, comms are closed out, and the timeline is captured.

- Final external comms: "incident resolved at HH:MM, post-mortem to follow."
- Final internal comms: thank the people who helped.
- Snapshot the timeline before details fade.

## Step 8 — Post-mortem (within ~5 days)

**Exit when:** the post-mortem is written, reviewed, and action items are filed.

A useful post-mortem covers:

- **Timeline** — what happened, when, in chronological order.
- **Impact** — who was affected, how much, for how long.
- **Root cause** — the actual technical cause, *and* the system-level reasons it wasn't caught earlier.
- **What went well** — yes, even in a bad incident. You want to reinforce these.
- **What went badly** — honestly. Blameless, but specific.
- **Action items** — concrete, owned, dated. "Improve monitoring" is not an action item. "Add alert on X metric > Y, by Z date, owned by Person" is.

**Blameless does not mean consequence-less for the system.** People are not at fault; missing tests, missing alerts, missing checks, and unclear runbooks are.

---

## Decision points

- **Symptom started after a recent deploy** → roll back first, diagnose second. Almost always.
- **Root cause unclear and bleeding has stopped** → it's OK to step back and bring in fresh eyes. Heroes get tunnel vision.
- **Fix requires a dangerous operation** (per `.agent/rules/dangerous-paths.md`) → escalate for explicit approval, even mid-incident. Especially mid-incident.
- **Same incident pattern as a previous one** → that's a system failure, not a coincidence. The post-mortem must address why the previous fix didn't prevent this.

## Exit criteria

- System stable for at least one full traffic cycle (typically a peak-hours window).
- Symptom verified resolved by the same signal that detected it.
- Internal and external comms closed.
- Post-mortem scheduled or written.
- Action items filed and owned.

## Pairs naturally with

- `.agent/rules/debugger.md` during Step 5 (root cause).
- `.agent/rules/dangerous-paths.md` whenever production-changing actions are on the table — which is most of this workflow.
- `.agent/personas/lead-engineer.md` for Step 8 (post-mortem) — the long-horizon view is what turns an incident into a system improvement.
