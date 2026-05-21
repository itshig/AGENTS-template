# Input Validation

> Load this when touching Server Actions, API routes, database ingestion points, or external boundaries.

## Triggers
- Writing or editing a Next.js Server Action.
- Creating or editing an API route (`/api/*` or other endpoints).
- Handling form data, webhooks, or file uploads from clients.
- Accepting any parameters from the URL query or path.

## 1. The Core Protocol: Zod Boundary Defense
Every external input MUST be validated at the boundary before passing to any business or database logic. No exceptions.

- [ ] **Strict Schemas**: Use `.strict()` on object schemas where extra keys should be rejected.
- [ ] **Safe Parsing**: Prefer `safeParse()` over `parse()` to avoid unhandled exceptions, and return structured errors.
- [ ] **Coercion**: Use `z.coerce` carefully. Verify dates (`z.coerce.date()`) and numbers are in safe ranges.
- [ ] **Type Export**: Export TypeScript types derived from Zod schemas using `z.infer<typeof schema>` to maintain a single source of truth.

## 2. Server Actions Validation
Next.js Server Actions are public endpoints. They must treat all arguments as untrusted inputs.

- [ ] Every Server Action MUST parse its arguments using a Zod schema.
- [ ] Return a standard response envelope on failure:
  ```typescript
  type ActionResponse<T> =
    | { success: true; data: T }
    | { success: false; errors: Record<string, string[]>; message: string };
  ```
- [ ] Form states and validation errors must map directly to fields for client-side display.

## 3. API Routes & Webhooks
- [ ] Validate request body, headers, and query parameters separately.
- [ ] Reject requests with `400 Bad Request` and structured Zod error payloads if validation fails.
- [ ] Webhook payloads must be verified (signatures checked) *and* validated against a strict schema.

---

**Confidence starts at the boundary.** Validate early, fail fast, and avoid raw casts.
