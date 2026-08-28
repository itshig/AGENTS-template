---
description: Rules for encrypting data at rest and handling key material. Load before implementing or changing any crypto.
globs: ["**/lib/crypto/**", "**/lib/encryption/**", "**/*crypto*", "**/*encrypt*"]
---

# Encryption

> Load this before writing, changing, or reviewing any code that encrypts data or handles key material. See also `.agents/rules/security.md` — this file covers encryption specifically; that one covers the broader surface.

> **TODO when adopting:** set the status line below, and if encryption is implemented, replace the generic guidance with this project's actual algorithm, key source, and storage format.

**Status in this project:** `not implemented` / `implemented — see <path>`

## The first rule

**Do not implement cryptographic primitives.** Use the platform's vetted library. Every hand-rolled cipher, padding scheme, or MAC in production started as someone thinking this rule didn't apply to them.

## Centralize

- [ ] All crypto lives in **one module** (e.g. `lib/encryption.*`) exposing `encrypt()` / `decrypt()`.
- [ ] No crypto logic scattered across components, hooks, route handlers, or services.
- [ ] Callers never touch IVs, salts, or key derivation directly — the module handles it.

A single chokepoint means one place to audit, one place to rotate, one place to fix.

## Algorithm

- [ ] **Authenticated encryption only.** AES-256-GCM or ChaCha20-Poly1305. Never AES-CBC without a separate MAC — and if you're adding the MAC yourself, see the first rule.
- [ ] **A fresh, random IV/nonce per encryption operation.** Never reuse a nonce with the same key. This is the single most common way GCM implementations fail catastrophically.
- [ ] IVs come from a CSPRNG, not a counter you maintain, unless you have a documented reason.
- [ ] The auth tag is stored and **verified on decrypt**. Decryption that ignores the tag is not authenticated encryption.

### AES-256-GCM parameters

If the project uses AES-256-GCM, these are not preferences — wrong values break the guarantee:

| Parameter | Value | Why |
| --------- | ----- | --- |
| Key | **32 bytes** (256 bits) | From a KDF (`scrypt`, `pbkdf2`, `argon2`) or a high-entropy env var. |
| IV / nonce | **12 bytes** (96 bits) | GCM's native size. Other lengths trigger an internal rehash and lose the security proof. |
| Auth tag | **16 bytes** (128 bits) | Truncated tags weaken forgery resistance. |

- [ ] IV is generated per-operation from a CSPRNG (`crypto.randomBytes(12)` or platform equivalent).
- [ ] The tag is explicitly set before decrypting, and a bad tag raises rather than returning plaintext.

## Storage format

- [ ] Ciphertext is stored as a single self-describing string or blob that includes everything needed to decrypt except the key — typically `iv:authTag:ciphertext`, base64 or hex encoded.
- [ ] The format is **versioned** (a prefix like `v1:`) so the algorithm can change without a flag-day migration.
- [ ] Encrypted columns are `text`/`bytea` (or the equivalent) — never a type that might normalize, truncate, or re-encode the value.

## Keys

- [ ] Keys come from environment variables or a secrets manager. **Never** from source, never from a config file that's committed, never a default value.
- [ ] The app **fails to start** if a required key is missing. A silent fallback to a default key is worse than a crash.
- [ ] Keys are never logged, never included in error messages, never returned in an API response.
- [ ] Key rotation is possible without a code change — the version prefix above is what makes this work.
- [ ] Different environments use different keys. A dev key that also decrypts production is a production key.

## What not to encrypt

- **Passwords are hashed, not encrypted.** Use argon2id, scrypt, or bcrypt. Encrypted passwords are recoverable, which is exactly what you don't want.
- Data you need to query, sort, or index on. Encrypting it means you can't. Decide before you encrypt, not after the query gets slow.

## Checklist before shipping

- [ ] Round-trip test: encrypt → decrypt → original value, including unicode and empty string.
- [ ] Tamper test: modify one byte of ciphertext, confirm decrypt **fails** rather than returning garbage.
- [ ] No key material in the test fixtures, the logs, or the diff.
- [ ] `.agents/rules/security.md` checklist applied.
