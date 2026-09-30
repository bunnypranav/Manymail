<div align="center">

![Manymail icon](docs/icon-160.png)

# Manymail

**Many addresses, one app.**

[![Get it on Google Play](docs/playbadge.svg)](https://play.google.com/store/apps/details?id=com.bunnypranav.manymail)

</div>

A **send-only** Android mail client for domains you own, where the sender
address is genuinely free-form. Configure a domain and its SMTP server once;
after that you choose the address every message comes from — the part before
the `@` and the display name are both free text, exactly as they are in a
desktop mail client.

```
"Billing" <billing@example.com>
```

| | |
|---|---|
| `"Billing"` | display name — free text, every time |
| `billing` | alias — free text, every time |
| `example.com` | chosen from the domains you configured once |

Desktop clients have allowed this for decades. Almost every Android mail app
does not: the From address is welded to the account you signed in with, so
`billing@`, `no-reply@` or a one-off alias on your own domain is simply
unreachable from a phone. Manymail exists because that restriction is a
client-side choice, not a rule of the mail protocol.

Your saved SMTP credentials authenticate the *connection*. They place no
constraint on the *identity* a message is sent from. That separation is the
whole point.

---

## What it does

- Any alias and display name, on any domain you have configured
- Per-domain SMTP settings — STARTTLS, implicit TLS or none, with PLAIN,
  LOGIN or CRAM-MD5 authentication and auto-detection
- A connection test that reports every step, with the server's raw banner and
  advertised capabilities
- Rich text or plain text, with a real plain-text alternative built from the
  document rather than stripped out of HTML
- Attachments, inline images, Reply-To and custom headers
- Saved identity presets for each domain
- Drafts, an outbox that retries with exponential backoff, and a searchable
  sent log
- Encrypted configuration backup and restore
- An optional lock using your biometrics or device PIN

## What it deliberately does not do

- **No inbox.** No IMAP, no POP, no sync. Manymail sends mail; it does not
  receive it.
- **No account.** There is no sign-up and no server of ours involved at any
  point.
- **No telemetry.** No analytics, no crash reporting, no ads, no advertising
  ID. The only network connections are to the SMTP servers you enter yourself.
- **No second-guessing your server.** If a server is going to refuse a sender
  address, Manymail does not try to predict it — it sends as typed and shows
  you the reply, word for word.

## Your passwords

SMTP passwords live in the Android Keystore and nowhere else. They are never
written to the app's database, never logged, and stripped out of every protocol
transcript before it is stored. An unencrypted configuration export leaves them
out entirely and says so inside the file.

The app requests seven permissions, all granted at install time — it never
shows a runtime permission prompt. See
[`PRIVACY.md`](PRIVACY.md) for what each one is for.

---

## Known SMTP server restrictions on the From address

This is the thing to understand before expecting free-form senders to work
everywhere.

Most SMTP providers **will not let you send from an arbitrary address**, no
matter what client you use. They check the envelope sender (`MAIL FROM`) and
often the `From` header against the authenticated account, and reject anything
else:

| Provider | Typical behaviour |
|---|---|
| Gmail / Google Workspace | Only the account address or a verified "Send mail as" alias. Others get `550-5.7.1`. |
| Microsoft 365 / Outlook | Only the mailbox or an address it has SendAs rights on. `550 5.7.60 SMTP; Client does not have permissions to send as this sender`. |
| Fastmail, Zoho, Proton Bridge | Account address or a configured alias only. |
| Amazon SES, Postmark, Mailgun, SendGrid | Any address on a **verified domain** — these are usually the ones that work. |
| A mail server you run (Postfix, etc.) | Whatever you configure. `smtpd_sender_login_maps` controls it in Postfix. |

**Manymail does not try to predict this.** It sends the address exactly as you
typed it and shows you the server's verbatim response, with the full SMTP
transcript behind an expander. If the server refuses, you see its own words and
a note explaining that the refusal came from the server, not from the app
rewriting your address.

That is deliberate: a client that silently rewrote your From address, or
refused to try, would be hiding the one fact you need in order to fix the
configuration on the server side.

If you want arbitrary senders to work reliably, send through a domain you
control on a provider that authorises per-domain rather than per-mailbox.

---

## Building it yourself

You need:

- the [Flutter SDK](https://docs.flutter.dev/get-started/install) — the version
  releases are built with is in [`.flutter-version`](.flutter-version)
- the Android SDK, with **NDK `28.2.13676358`** (r28c)
- a C compiler for your own machine — Visual Studio Build Tools on Windows,
  Xcode command-line tools on macOS, `clang` or `gcc` on Linux

The last two are because Manymail compiles SQLite from source rather than
downloading a prebuilt library; see
[`third_party/sqlite/README.md`](third_party/sqlite/README.md). The NDK builds it
for Android, and the host compiler builds it for `flutter test`.

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter test
```

`build_runner` generates the drift database code — nothing compiles without it.

A debug build, on a connected device or emulator:

```bash
flutter run
```

A release build, one APK per CPU architecture:

```bash
flutter build apk --release --split-per-abi
```

Without an `android/key.properties` the release APKs are **unsigned** and will
not install until you sign them — that is what F-Droid's build server needs.
For a quick install without a keystore, use `flutter run` or
`flutter build apk --debug`. [`ARCHITECTURE.md`](ARCHITECTURE.md) has the
signing setup, the per-ABI version codes and the rest of the build
configuration.

### Trying it without a real mail server

A scriptable fake SMTP server is included, which is what the integration tests
drive:

```bash
dart tool/fake_smtp_server.dart --port 2525
```

It takes `--reject-sender` for a 5xx sender refusal, `--transient` for a 4xx,
`--reject-auth` and `--no-auth`. From an Android emulator the host is
`10.0.2.2`.

---

## Licence

Manymail is free software under the **GNU General Public License v3.0 or
later**. See [`LICENSE`](LICENSE) for the full text.

```
Copyright (C) 2026 Bunny Pranav

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
```

In practice: use it, read it, change it, ship it. If you distribute a modified
version you must publish your source under the GPL too, and keep the copyright
notice. Nobody can take Manymail closed-source or ship a proprietary rebrand.

Every source file carries an SPDX header, and the full licence text is bundled
into the app — readable at **Settings → About → Open source licences**,
alongside the licence of every package the app ships.

### Dependency licences

All **187** packages in the resolved graph are GPL-3.0 compatible — 115
BSD-3-Clause, 54 MIT, 7 Apache-2.0, 4 MPL-2.0, 2 BSD-2-Clause, and 5 bundled
with the Flutter SDK. [`THIRD-PARTY-NOTICES.md`](THIRD-PARTY-NOTICES.md) has
the breakdown, including why MPL-2.0 (`enough_mail`) is fine inside a GPL work.

Re-check after changing a dependency — it exits non-zero on a problem, so it
can gate CI:

```bash
python tool/audit_licenses.py
```

---

## Contributing

[`CONTRIBUTING.md`](CONTRIBUTING.md) covers what the project will and will not
accept, and why. The short version: Manymail never blocks a send client-side,
never grows an inbox, and never phones home.

- [`SECURITY.md`](SECURITY.md) — how to report a vulnerability, and the threat
  model
- [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md) — Contributor Covenant 2.1

---

## Technical overview

Full detail in [`ARCHITECTURE.md`](ARCHITECTURE.md). The parts worth knowing
before reading the code:

**Four layers, one direction of dependency:** UI → repositories →
(drift | secure storage | SMTP). Riverpod providers are the only wiring between
them; no widget touches the database or a socket directly.

**Manymail speaks SMTP itself,** over `dart:io` sockets, rather than through
`enough_mail`'s `SmtpClient`. That client's `SmtpSendMailCommand` advances from
`MAIL FROM` to `RCPT TO` without inspecting the reply, so a `5xx` sender
rejection is swallowed and the send reports success. Surfacing exactly that
rejection is the point of this app, so it was disqualifying. `enough_mail` is
still used to build the MIME tree, which it does well.

**Credentials are redacted on write,** at a single chokepoint in
[`lib/core/transcript.dart`](lib/core/transcript.dart). A password therefore
cannot reach a buffer, a log, an error message or an export — there is one
place to get this right rather than several.

**There is no password column.** The `domains` table stores an opaque
`credentialKeyId`; the secret itself lives in `flutter_secure_storage`, backed
by the Android Keystore.

**The envelope sender is the address you typed,** not the SMTP username. That
is what triggers server rejections, and showing them is a feature.

**Every native library is built from source,** SQLite included. The SQLite
amalgamation is vendored in [`third_party/sqlite/`](third_party/sqlite/) and
compiled by the build instead of being downloaded prebuilt, so the APK contains
nothing that cannot be rebuilt from this repository.

**119 tests**, including integration tests that drive a local fake SMTP server
through sender rejection, transient failure, STARTTLS and each auth mechanism.
