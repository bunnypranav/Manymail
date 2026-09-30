# Manymail architecture and internals

The detail behind [`README.md`](README.md). Read that first for what the app
is; this is for changing it.

---

## Architecture

Four layers, one direction of dependency: **UI → repositories → (drift |
secure storage | SMTP)**. Riverpod providers are the only wiring; no widget
touches the database or a socket directly.

```
lib/
  core/
    transcript.dart              SMTP transcript capture + credential redaction
    validation/rfc5322.dart      local-part validation, address parsing
    header_policy.dart           which custom headers are allowed
    rich_text/body_converter.dart  Delta -> HTML and Delta -> plain text
  data/
    db/database.dart             drift database, migrations, WAL
    db/tables.dart               schema
    models/                      plain Dart models, drift-free
    repositories/                domain + preset CRUD, pairs rows with secrets
    secure/credential_store.dart the only place passwords are read or written
  smtp/
    smtp_transport.dart          the SMTP protocol itself
    smtp_session.dart            connect → EHLO → STARTTLS → AUTH
    send_service.dart            MAIL FROM → RCPT TO → DATA, every reply checked
    message_composer.dart        our model → MIME (via enough_mail)
    smtp_failure.dart            transient / permanent classification
    connection_tester.dart       per-step connection report
    smtp_config.dart             resolved connection settings
  background/
    retry_policy.dart            exponential backoff, attempt limit
    outbox_worker.dart           WorkManager entry point, runs due messages
    outbox_scheduler.dart        books the next wake-up
  data/outbox_transition.dart    pure rules: sent / queued / failed
  features/compose/              the composer, From row, recipient chips
  features/drafts/ outbox/ sent/ the three message lists
  features/domains/              domain + identity management UI
  features/shell/                bottom navigation
  routing/, providers.dart, app.dart, main.dart
tool/fake_smtp_server.dart       scriptable SMTP server for tests
```

### Why Manymail speaks SMTP directly

The app uses `enough_mail` to **build MIME messages** — that part is excellent —
but not to send them. Its `SmtpClient` has a defect that is disqualifying for
this particular app:

```dart
// enough_mail 2.1.7, smtp_sendmail_command.dart
case _SmtpSendCommandSequence.mailFrom:
  _currentStep = _SmtpSendCommandSequence.rcptTo;
  _recipientIndex++;
  return _getRecipientToCommand(recipientEmails[0]);   // never checks the reply
```

After `MAIL FROM`, it advances to `RCPT TO` **without inspecting the response**.
A `550 5.7.1 Sender address rejected: not owned by user` is therefore ignored,
the conversation continues, and `sendMessage` reports **success** for a message
the server refused.

Surfacing exactly that rejection is this app's core promise, so
`lib/smtp/smtp_transport.dart` implements SMTP directly (~400 lines) and checks
every reply. This is verified by
`test/smtp_integration_test.dart` → *"a 5xx on MAIL FROM is reported, never
swallowed"*.

A second, smaller reason: `enough_mail`'s EHLO only completes when the whole
multi-line reply arrives in a single read, so a server whose reply is split
across TCP segments hangs the client. The transport here assembles replies by
the RFC 5321 continuation rule (`250-` vs `250 `) instead.

---

---


## Security model

**Passwords never touch the database.** A `Domains` row stores only
`credentialKeyId`, an opaque UUID. The password lives in
`flutter_secure_storage`, which on Android v11 encrypts values with AES-GCM
under a key wrapped by the Android Keystore (RSA-OAEP, API 23+).

**Redaction happens at one chokepoint.** `SmtpTranscript.add()` redacts
credentials *as it records*, not at the UI layer:

- `AUTH PLAIN <base64>` → the mechanism is kept, the payload is replaced
- every client line during an AUTH exchange (LOGIN's two base64 steps,
  CRAM-MD5's digest) is replaced
- any registered secret is scrubbed wherever it appears, as a second defence

A credential therefore cannot reach the transcript, the database, an error
message or a log without passing through that one method. Covered by
`test/transcript_test.dart` and asserted end-to-end in
*"never leaks the password into the transcript"*.

**CRAM-MD5 is preferred on unencrypted connections** so the password stays off
the wire. If only PLAIN/LOGIN are offered without TLS, the app says so plainly
rather than quietly sending them.

**No analytics, no telemetry, no crash reporting.** The app makes no network
connection other than to the SMTP servers you configure. Android permissions
are limited to:

| Permission | Why |
|---|---|
| `INTERNET` | connecting to your SMTP servers, and nothing else |
| `ACCESS_NETWORK_STATE` | holds a retry back until there is a network, instead of waking to fail |
| `WAKE_LOCK` | lets WorkManager finish an outbox retry without the device sleeping mid-send |
| `RECEIVE_BOOT_COMPLETED` | restores pending retries after a reboot, so a queued message is not stranded |
| `USE_BIOMETRIC`, `USE_FINGERPRINT` | the optional app lock, only used once you turn it on. `USE_FINGERPRINT` is the pre-API-29 equivalent, added by `local_auth` |
| `DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` | generated by AndroidX itself. Signature-level, holdable only by this app, grants access to nothing |

That is the **complete** merged list, plugins included — verify it yourself with:

    grep -o 'android:name="android.permission[^"]*"'       build/app/intermediates/merged_manifests/release/processReleaseManifest/AndroidManifest.xml | sort -u

All seven are granted at install time, so **Manymail never shows a runtime
permission prompt**.

Three permissions that `androidx.work` declares by default are explicitly
removed in `android/app/src/main/AndroidManifest.xml` with `tools:node="remove"`:
`FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_SHORT_SERVICE` and
`POST_NOTIFICATIONS`. The outbox schedules ordinary deferred work — it never
calls `setForegroundAsync`, never asks for expedited quota and never posts a
notification. Keeping them would also oblige the Play listing to justify a
foreground service that does not exist.

The app also registers share-sheet intent filters (`SEND`, `SEND_MULTIPLE`) so
other apps can share text and files into a new message. Intent filters need no
permission. Files shared in are **copied** into app storage immediately, because
Android is free to clear the cache directory it hands them over in.

---

---


## How a message is assembled

The MIME tree matches what the message actually holds, and nothing more — a
needlessly nested message is one some clients render badly:

```
plain only                  text/plain
rich                        multipart/alternative
                             |- text/plain        (derived from the document)
                             '- text/html
rich + inline images        multipart/related
                             |- multipart/alternative
                             '- image/*           (Content-ID, inline)
any of the above + files    multipart/mixed
                             |- <the above>
                             '- application/*     (attachment)
```

Two details worth stating:

- **The plain-text alternative is derived from the editor's Delta, not by
  stripping tags from the HTML.** Going through the source document keeps list
  markers, quote markers and link targets that tag-stripping throws away — a
  link renders as `the docs <https://example.com/docs>` rather than a bare
  label pointing nowhere.
- **The plain-text toggle is not cosmetic.** In plain mode no `text/html` part
  is generated at all, even if a rich body was written earlier and is still
  stored on the draft.

`test/mime_structure_test.dart` asserts each shape above, including that Bcc
never reaches the headers whatever the structure.

---

---


## How the outbox decides to retry

There is one rule, in one place (`lib/data/outbox_transition.dart`), so the
composer, a manual retry and the background worker cannot disagree:

| Outcome | Status | Retried? |
|---|---|---|
| Accepted | `sent` | — |
| No network, timeout, dropped connection | `queued` | yes, with backoff |
| `4xx` — server busy or temporarily unable | `queued` | yes, with backoff |
| `5xx` — sender refused, bad credentials | `failed` | **no** |
| TLS handshake or certificate failure | `failed` | **no** |

A refusal is never retried, because asking the same server the same question
again cannot change the answer — it would only hide the real problem behind a
spinner. Backoff is 30s, 1m, 2m, 4m … capped at 6 hours, with ±20% jitter, for
up to 10 attempts; after that the message waits in the outbox for a manual
retry and says so.

The schedule has a single source of truth: each queued message stores its own
`nextRetryAt`, and WorkManager is asked to wake once at the earliest of those,
constrained to `NetworkType.connected`. WorkManager's own backoff applies only
if the *task* fails to run, never to individual messages.

**Caveat worth knowing:** OEM battery optimisation can delay or drop background
work arbitrarily, and Android will not run a force-stopped app's jobs at all
until it is opened again. The outbox therefore always offers a manual retry and
never depends solely on the scheduler.

---

---


## Configuration backup

**Encrypted export** carries everything, SMTP passwords included. The
passphrase is stretched with **Argon2id** (19 MiB, 2 iterations, 1 lane — the
OWASP floor) and the payload sealed with **AES-GCM-256**. The salt, nonce and
the KDF cost are written into the file, so a file exported today still opens
after those defaults are tuned. AES-GCM is authenticated, so an altered file
fails to open rather than yielding plausible rubbish.

```json
{
  "format": "manymail.config",
  "encrypted": true,
  "kdf":    { "algorithm": "argon2id", "memoryKiB": 19456, "salt": "..." },
  "cipher": { "algorithm": "aes-gcm-256", "nonce": "...", "ciphertext": "...", "mac": "..." }
}
```

**Unencrypted export never contains passwords.** There is no option to write
them in the clear. The file says so itself, in a `README` field, so finding it
later does not leave you wondering why importing it cannot connect.

**Where exports land.** Both go through Android's system save sheet, opened on
**Downloads** with the file name filled in, via
`FilePicker.saveFile(initialDirectory: …)` and `EXTRA_INITIAL_URI`. They used
to be written to the app's private documents directory, which nothing else on
the device can browse — a backup you could not retrieve.

Writing straight into `/Download` without the sheet was rejected deliberately:
it needs `WRITE_EXTERNAL_STORAGE` on API 28 and below, or a MediaStore insert
through a platform channel above it. Manymail shows no runtime permission
prompts at all, and a backup file is not worth being the first one. The sheet
costs a single tap and tells the user exactly where the file went.

The save sheet returns only the document URI's *path*
(`/document/primary:Download/manymail-config-….json`), not a `content://`
URI, so the confirmation dialog strips everything up to the storage volume's
colon and shows `Download/manymail-config-….json`.

Import previews what it found before changing anything, and offers **merge** or
**replace**; replace deletes through the repository so stored passwords go with
their domains rather than being orphaned in the keystore.

`test/config_crypto_test.dart` covers the round trip, a wrong passphrase, a
tampered ciphertext, a foreign file, and that a fresh salt and nonce are used
every time.

---

---


## Testing

```bash
flutter test           # unit, widget and local integration tests
flutter analyze        # must be clean
```

`tool/fake_smtp_server.dart` is a scriptable SMTP server the integration tests
drive, so the interesting failure modes are deterministic and need no real mail
host. Run it by hand too:

```bash
dart run tool/fake_smtp_server.dart --port 2525                    # accepts everything
dart run tool/fake_smtp_server.dart --port 2526 --reject-sender    # 550 on MAIL FROM
dart run tool/fake_smtp_server.dart --port 2527 --transient        # 451 on MAIL FROM
dart run tool/fake_smtp_server.dart --port 2528 --reject-auth      # 535 on AUTH
```

Credentials are `user` / `password`, and it prints each accepted message with
its envelope and full MIME, which is the quickest way to see what the app
actually puts on the wire. From the Android emulator the host machine is
`10.0.2.2`, so configure a domain with host `10.0.2.2`, port `2525`, security
`None`.

What the suite covers:

| Area | File |
|---|---|
| Credential redaction in transcripts | `test/transcript_test.dart` |
| Local-part validation, address parsing | `test/rfc5322_test.dart` |
| SMTP handshake, auth mechanisms, sender rejection | `test/smtp_integration_test.dart` |
| Envelope, Bcc, custom headers, send outcomes | `test/send_path_test.dart` |
| MIME tree for every body/attachment combination | `test/mime_structure_test.dart` |
| Delta to HTML and plain text | `test/body_converter_test.dart` |
| Retry backoff and the attempt limit | `test/retry_policy_test.dart` |
| sent / queued / failed transitions | `test/outbox_transition_test.dart` |
| Export encryption, tampering, wrong passphrase | `test/config_crypto_test.dart` |
| Recipient chip entry | `test/recipient_field_test.dart` |

---

## Build configuration notes

### SQLite is compiled from source

`package:sqlite3`'s build hook downloads a precompiled `libsqlite3.so` from
GitHub unless told otherwise. `pubspec.yaml` tells it otherwise:

```yaml
hooks:
  user_defines:
    sqlite3:
      source: source
      path: third_party/sqlite/sqlite3.c
```

The amalgamation in `third_party/sqlite/` is the exact SQLite release the
package would have downloaded (3.53.4 for `sqlite3` 3.5.2), so behaviour did
not change. After stripping, the library in the APK is byte-identical to the
one compiled from that file, and a database written by the old prebuilt library
opens unchanged.

F-Droid forbids prebuilt native binaries, which is why this exists. It applies
to every build so that Play and F-Droid ship the same SQLite.

The hook compiles for each Android ABI with the NDK, and for the host during
`flutter test`. `flutter build apk` does **not** compile for the host, so a
build server needs only the NDK.

### Release signing

`android/key.properties` present → release builds are signed with the upload
key. Absent → release builds are **unsigned**, because F-Droid's recipe output
must be an unsigned APK. Setting `MANYMAIL_UNSIGNED=true` forces an unsigned
build even with a keystore present, to reproduce F-Droid's output locally.

If `key.properties` names a keystore that does not exist, the build **fails**
rather than falling back to an unsigned or debug build. `storeFile` separators
are normalised, because a `.properties` file treats a backslash as an escape
and silently mangles `D:\path\to\key.jks`.

### Version codes per ABI

`flutter build apk --split-per-abi` produces one APK per CPU architecture, and
each needs its own version code:

| pubspec | armeabi-v7a | arm64-v8a | x86_64 |
|---|---|---|---|
| `1.0.0+1` | 11 | 12 | 13 |

That is `versionCode × 10 + abi`, the scheme fdroiddata's Flutter template
expects. Flutter's own scheme, `abi × 1000 + versionCode`, is switched off with
`force-version-code-ignoring-abi=true` in `android/gradle.properties`: it puts
the ABI in the highest digits, so an old arm64 build would outrank every later
armeabi-v7a build and block updates.

The override in `build.gradle.kts` touches only outputs that carry an ABI
filter. The Play App Bundle and a universal APK keep the plain pubspec version
code.

`tool/fdroid_changelogs.py` writes the matching F-Droid changelogs, one per
ABI version code, from a single notes file.

### No dependency-info block in APKs

`dependenciesInfo { includeInApk = false }`. By default AGP writes the
dependency list into each signed APK's signing block, encrypted to a key only
Google holds. F-Droid asks apps to turn it off, and it would break any
reproducible-build comparison. It stays on for the App Bundle, where Play
Console uses it to flag known-vulnerable SDKs.

### Other non-default settings

- `android/app/build.gradle.kts` does **not** set `ndkVersion`. Flutter's
  plugin supplies its own (`28.2.13676358` for Flutter 3.47.4), and setting it
  here makes Gradle try to auto-install the NDK through the deprecated
  `sdkmanager` shim, which crashes on current cmdline-tools. Install the NDK
  through Android Studio instead.
- `compileSdk` is 37 rather than 36, because `receive_sharing_intent` compiles
  against 37. `targetSdk` stays at 36, so runtime behaviour is unchanged.
- `compileSdkMinor = 0` accompanies it. Android 17 ships as the platform
  package `android-37.0`, but AGP turns a bare `compileSdk = 37` into the
  lookup hash `android-37`. That resolves when the platform was installed
  beforehand and fails when Gradle installs it mid-build — which is every
  fresh CI runner and F-Droid's build server — with *"Failed to find target
  with hash string 'android-37'"*. The minor level makes AGP ask for
  `android-37.0`. Verified by building against an SDK with API 37 absent:
  fails without it, passes with it.
- The same fix is applied to **plugin** modules from `android/build.gradle.kts`,
  because `receive_sharing_intent` sets a bare `compileSdk 37` in its own build
  file, which lives in the pub cache and cannot be edited. A
  `finalizeDsl` callback adds the minor level to any library module asking for
  a bare 37, after its script runs and before AGP locks the DSL. Checked by
  printing every module's resolved `compileSdkVersion`: no module requests
  `android-37`.
- `android/gradle.properties` sets `kotlin.incremental=false` and
  `kotlin.compiler.execution.strategy=in-process`. Kotlin's incremental
  compiler leaves `.tab` cache files locked on Windows, failing the build with
  *"Could not close incremental caches"*.

If `adb` cannot see your device and `flutter doctor` warns about multiple `adb`
binaries, the SDK's copy and another one (Chocolatey's, say) are fighting.
Restart the server from the SDK's:

```bash
adb kill-server
"$ANDROID_HOME/platform-tools/adb" start-server
```

---
