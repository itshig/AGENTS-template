---
description: Schema validation at every trust boundary. Load for forms, API handlers, data ingestion, and anything processing user input.
globs: ["**/hooks/**", "**/components/**", "**/services/**", "**/lib/**", "**/api/**", "**/actions/**"]
---

# Validation

> Load this for form handling, API handlers, server actions, data ingestion, or any code that processes input it didn't create.

> **TODO when adopting:** name this project's validation library (Zod, Valibot, Pydantic, io-ts, …) and where shared schemas live.

**Library:** `…`  ·  **Shared schemas:** `…`

## The principle

**Data from outside the process is unsafe until parsed.** Not "checked" — *parsed*, into a value whose type proves it was validated. This includes: HTTP request bodies, query params, route params, form submissions, webhook payloads, third-party API responses, file contents, environment variables, and anything read from a queue.

An external API's response is untrusted input. It changed shape without telling you at least once already.

## Schema definition

- [ ] Reusable schemas live in one shared location; single-use schemas are co-located with their consumer.
- [ ] Error messages are written for humans — they surface in the UI. `"Invalid input"` helps nobody.
- [ ] The schema is the **single source of truth for the type**. Infer the type from the schema; never declare both by hand and let them drift.

## The parse pattern

At every boundary:

1. **Define** the schema for the expected shape.
2. **Safe-parse** — use the non-throwing variant (`safeParse` and equivalents) so failures are values you handle, not exceptions that escape.
3. **Handle failure explicitly** — surface field-level errors to the UI, or return a 400. Never log-and-continue with unvalidated data.
4. **Use the parsed output**, not the original input, from that point on. If you validate `input` and then use `input`, you validated nothing.

That last point is the one that actually bites people. Pass the parsed result forward.

## Boundaries that need it

- [ ] Every API route / server action / form handler validates its input before touching business logic.
- [ ] Every database write with user-supplied data has passed validation first.
- [ ] Every third-party API response is parsed before its fields are read.
- [ ] Environment variables are validated at startup, so a missing var fails immediately and loudly rather than as `undefined` three layers deep at 2am.

## Aligning with the persistence layer

- [ ] Required database columns have non-optional schema fields.
- [ ] Strings that must not be blank are explicitly constrained — an empty string passes a naive "is a string" check.
- [ ] Field lengths match the column limits. Validation that permits 500 characters into a `varchar(255)` moves the error from the form to the database.
- [ ] Enums in the schema match the enum in the database. Both change together or neither does.

## Client and server

Client-side validation is a **UX affordance**. Server-side validation is the **security boundary**. You need both, and the server never trusts that the client ran.

- [ ] Share the schema between client and server so they can't diverge.
- [ ] The server validates even when the only caller is your own client.

---

**Instruction:** do not execute a write with user-provided data unless it has passed a safe-parse check, and do not read fields off an external response you haven't parsed.
