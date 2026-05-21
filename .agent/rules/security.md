# Security

> Load this when the change touches anything in the **Triggers** list. Apply the **Checklist** before marking the change done.

## Triggers — load this file when the change involves any of:

- Authentication or session handling (login, logout, password reset, MFA, magic links, SSO)
- Authorization, RBAC, ACLs, tenant isolation, or "can user X do Y to resource Z" logic
- Payments, billing, refunds, or anything touching a payment processor
- PII (personally identifiable information): names, emails, phone numbers, addresses, government IDs, health info, location data
- File uploads or downloads
- User-supplied input that becomes a query, command, path, URL, HTML, or template
- Cryptography (hashing, encryption, signing, random number generation)
- Environment variables, secrets, API keys, tokens
- Third-party integrations (OAuth, webhooks, API consumers)
- CORS, CSP, cookies, or any HTTP security headers
- Database queries, migrations, or stored procedures
- Background jobs that run with elevated privileges
- Anything in `.agent/rules/dangerous-paths.md`

## Checklist

### Input

- [ ] **Validate at the boundary.** Every external input (HTTP request, message queue, file, webhook) is parsed and validated against an explicit schema before it reaches business logic.
- [ ] **Reject unknown fields** by default, unless there's a documented reason to allow them.
- [ ] **Length, type, and range checks** on every field that ends up in a query, file path, URL, or rendered output.

### Injection

- [ ] **No string concatenation into SQL.** Parameterized queries or a query builder, always.
- [ ] **No string concatenation into shell commands.** Use the language's `exec`/`spawn` with array args, never a shell string. If you must use a shell, the input is a hardcoded constant.
- [ ] **No string concatenation into file paths** that include user input. Resolve and verify the path is inside the expected directory.
- [ ] **HTML/template output is escaped** by default. Any "raw" / "unsafe" / "trustAsHtml" usage has a comment explaining why and what guarantees the input.

### Authentication

- [ ] Passwords are hashed with a modern KDF (argon2id, scrypt, bcrypt). Never MD5, SHA1, or unsalted SHA256.
- [ ] Sessions have a maximum lifetime and an idle timeout.
- [ ] Session tokens are random (CSPRNG), long enough (≥128 bits of entropy), and stored server-side or signed.
- [ ] Login responses do not leak whether the username exists.
- [ ] Rate limiting on login, password reset, and any endpoint that accepts user-supplied credentials.

### Authorization

- [ ] **Every endpoint checks authorization**, not just authentication. "Logged in" is not the same as "allowed to do this."
- [ ] Authorization checks happen on the **server**, not in the client.
- [ ] Multi-tenant code: every query is scoped by tenant. There is no code path that returns another tenant's data.
- [ ] IDs from the client are treated as untrusted — verify the user owns / can access the resource before acting on it (no IDOR).

### Secrets

- [ ] No secrets in source code, ever. Not even "temporarily." Not even in tests.
- [ ] Secrets come from env vars, a secrets manager, or a key vault.
- [ ] Secrets are not logged. Not in error messages, not in stack traces, not in request dumps.
- [ ] Rotated secrets work without code changes (no hardcoded key IDs).

### Cryptography

- [ ] Use the language/platform's vetted crypto library. Do not implement primitives.
- [ ] Random values that need to be unguessable use a CSPRNG, not `Math.random` / `random.random` / `rand()`.
- [ ] Comparisons of secrets, tokens, or HMACs use a constant-time function.

### HTTP and transport

- [ ] HTTPS only in production. HSTS where appropriate.
- [ ] CSRF protection on state-changing requests (cookies + same-origin checks, or anti-CSRF tokens).
- [ ] CORS is restrictive by default. `Access-Control-Allow-Origin: *` requires an explicit reason.
- [ ] Cookies that carry auth are `HttpOnly`, `Secure`, and `SameSite` set deliberately.
- [ ] Security headers: CSP, X-Content-Type-Options, X-Frame-Options or frame-ancestors, Referrer-Policy.

### Data exposure

- [ ] API responses include only the fields the client needs. No "return the whole user object" with password hashes, internal flags, or other tenants' data.
- [ ] Error messages to the client are generic. Detailed errors go to logs, not the response body.
- [ ] Stack traces are never returned to clients in production.

### Dependencies

- [ ] Any new dependency is checked: maintained, reasonable license, no known critical CVEs, not abandoned.
- [ ] Lockfile is committed and updated.

### File handling

- [ ] Uploaded files are validated by content, not just extension or MIME type from the client.
- [ ] Uploaded files are stored outside the web root, or served from a domain that doesn't share auth cookies.
- [ ] Filenames from users are sanitized before being used on disk. Never trusted as-is.
- [ ] Size limits enforced before reading the whole file into memory.

---

**When in doubt, ask.** A five-minute question to a human beats a five-day incident.
