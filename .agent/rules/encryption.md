# Encryption and Cryptography

> Load this for any AES-256-GCM implementations, key derivations, or handling of sensitive secrets.

## Triggers
- Handling database encryption or storing PII (names, emails, credentials, API keys).
- Implementing AES-256-GCM or hashing algorithms.
- Storing or rotating keys, tokens, or encryption secrets.

## 1. Standard: AES-256-GCM Protocol
All symmetric encryption MUST use AES-256-GCM. Never use outdated algorithms like AES-CBC or RC4.

- [ ] **Cryptographic Library**: Use the built-in Node.js `crypto` library. Do not write custom cryptographic primitives.
- [ ] **Secret Key**: Must be exactly 32 bytes (256 bits), derived securely via KDF (e.g. `scrypt` or `pbkdf2`) or loaded as a high-entropy string from a secure environment variable.
- [ ] **Initialization Vector (IV)**:
  - Must be unique for every single encryption operation.
  - Must be exactly 12 bytes (96 bits) for GCM.
  - Must be generated using a CSPRNG: `crypto.randomBytes(12)`.
  - **NEVER reuse an IV** under any circumstances. IV reuse in GCM breaks confidentiality.
- [ ] **Auth Tag**:
  - Must be exactly 16 bytes (128 bits).
  - Must be checked during decryption using `decipher.setAuthTag(tag)`.
  - Decryption must fail immediately and securely if the auth tag is invalid.

## 2. Storage Layout
When storing encrypted data, the IV, ciphertext, and auth tag must be kept together.
- Standard format: `iv:ciphertext:tag` (colon-separated base64 or hex values).
- Alternatively, store them in separate database columns (`encrypted_data`, `encryption_iv`, `encryption_tag`).

## 3. Code Template (TypeScript)
```typescript
import crypto from 'crypto';

const ALGORITHM = 'aes-256-gcm';
const IV_LENGTH = 12;
const TAG_LENGTH = 16;

export function encrypt(text: string, key: Buffer): string {
  const iv = crypto.randomBytes(IV_LENGTH);
  const cipher = crypto.createCipheriv(ALGORITHM, key, iv);
  
  let encrypted = cipher.update(text, 'utf8', 'hex');
  encrypted += cipher.final('hex');
  
  const tag = cipher.getAuthTag();
  
  // Format: iv:encrypted_content:auth_tag
  return `${iv.toString('hex')}:${encrypted}:${tag.toString('hex')}`;
}

export function decrypt(encryptedData: string, key: Buffer): string {
  const [ivHex, encryptedHex, tagHex] = encryptedData.split(':');
  if (!ivHex || !encryptedHex || !tagHex) {
    throw new Error('Invalid encrypted data format');
  }
  
  const iv = Buffer.from(ivHex, 'hex');
  const tag = Buffer.from(tagHex, 'hex');
  const decipher = crypto.createDecipheriv(ALGORITHM, key, iv);
  
  decipher.setAuthTag(tag);
  
  let decrypted = decipher.update(encryptedHex, 'hex', 'utf8');
  decrypted += decipher.final('utf8');
  
  return decrypted;
}
```

## 4. Key Management & Environment Variables
- [ ] Keys must never be committed to source code or logged.
- [ ] Secrets must be rotated periodically. Ensure old data can be decrypted during the transition window.
- [ ] Use constant-time comparisons (`crypto.timingSafeEqual`) to prevent timing side-channel attacks when verifying tokens or signatures.

---

**Do not invent your own crypto.** Trust vetted primitives, protect your IVs, and enforce integrity.
