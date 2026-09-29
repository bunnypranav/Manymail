# Security policy

## Reporting a vulnerability

Please report security issues **privately**, not in the public issue tracker.

- GitHub: use **Security → Report a vulnerability** on this repository
  (GitHub Private Vulnerability Reporting).
- Email: `manymail@bunnyorg.in`

Please include what you did, what you expected and what happened. If a proof
of concept involves a real mail account, redact the credentials — the whole
app is built around never printing those, so please don't send me some.

I will acknowledge within a week. Manymail is maintained by one person in his
spare time, so please allow reasonable time for a fix before disclosing.

## Supported versions

The latest released version only.

## What Manymail guarantees

These are the properties worth attacking. Each is enforced in code and covered
by tests.

| Guarantee | Enforced by |
|---|---|
| SMTP passwords never reach the SQLite database | `lib/data/secure/credential_store.dart` — the `domains` table has **no password column**, only an opaque `credentialKeyId` |
| Passwords are encrypted at rest under the Android Keystore | `flutter_secure_storage` 11.x: AES-GCM under an RSA-OAEP key held in the Keystore |
| Passwords never appear in a protocol transcript | `lib/core/transcript.dart` redacts on **write**, at one chokepoint, so a credential cannot reach a buffer, a log, an error message or an export |
| An unencrypted config export contains no passwords | `lib/features/settings/export_import/config_export.dart` — `plainFile()` excludes them and says so inside the file |
| An encrypted config export is not readable without the passphrase | Argon2id (m=19456 KiB, t=2, p=1) + AES-GCM-256, `config_crypto.dart` |
| The app makes no network connection other than to configured SMTP servers | No analytics, crash-reporting or ad SDK is present; `INTERNET` is the only network permission |

## Threat model, stated plainly

**In scope.** Credential disclosure through the database, logs, transcripts,
exports or backups. Weaknesses in the export crypto. Sending a message to the
wrong recipient. Leaking Bcc recipients into message headers. Accepting a TLS
certificate the user did not agree to accept.

**Out of scope.**

- **A rooted or compromised device.** Keystore-backed storage protects data at
  rest against another app and against offline extraction; it cannot protect
  against root.
- **The optional app lock.** It gates the UI, not the data. It is there so a
  handed-over phone does not expose your drafts and sent log. It is not a
  second encryption layer and is not a substitute for a device passcode.
- **"Allow insecure certificate" connections.** This is a per-domain setting a
  user must turn on deliberately, for self-signed servers. It disables
  certificate validation for that domain and the UI says so. Turning it on and
  then being intercepted is the documented consequence, not a vulnerability.
- **SMTP servers themselves**, and whether a given server permits the sender
  address you typed. Manymail deliberately does not police that — see below.
- **Android's own backup.** `allowBackup` follows the platform default;
  Keystore-wrapped secrets are not restorable onto a different device.

## Not a vulnerability: free-form sender addresses

Manymail lets you type any local part on any domain you have configured, and
sends `MAIL FROM` with exactly that address. This is the entire purpose of the
app, and it is not a spoofing vulnerability:

- It does not let you send *as* a domain you have not configured with working
  SMTP credentials.
- The receiving infrastructure still enforces SPF, DKIM and DMARC.
- Most SMTP servers reject a sender the authenticated account does not own.
  Manymail surfaces that rejection verbatim instead of hiding it.

In other words, the app does not grant authority it does not already have; it
declines to add a client-side restriction that the server is going to enforce
anyway, and shows you the server's answer.
