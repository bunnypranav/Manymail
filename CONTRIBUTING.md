# Contributing to Manymail

Thanks for looking. Manymail is a small, deliberately narrow app and I would
rather keep it that way than grow it into a general mail client.

## The one rule that shapes everything

**Manymail never prevents a send client-side.** If a server is going to reject
a From address it does not own, the app attempts the send as typed and shows
the server's actual reply, verbatim. Patches that add "helpful" client-side
validation which *blocks* a send will be declined. Warnings and hints are
welcome; gates are not.

Three related rules:

1. **Send-only.** No IMAP, no POP, no inbox, no sync. Ever.
2. **No telemetry.** No analytics, no crash reporting, no phone-home. The only
   network connections are to the SMTP servers the user configures. A patch
   that adds a network call anywhere else will be declined.
3. **Passwords never leave the Keystore.** They must not reach the SQLite
   database, a log, an error message, a transcript or an export. There is one
   redaction chokepoint, [`lib/core/transcript.dart`](lib/core/transcript.dart),
   and it should stay the only one.

## Licence of contributions

Manymail is **GPL-3.0-or-later**. By opening a pull request you agree that your
contribution is licensed under those terms. There is no CLA and I do not ask
you to assign copyright — you keep yours.

New source files need the standard header:

    // Manymail - Many addresses, one app.
    // Copyright (C) 2026 Bunny Pranav
    // SPDX-License-Identifier: GPL-3.0-or-later
    //
    // This file is part of Manymail, distributed under the GNU General Public
    // License v3 or later. See the LICENSE file at the root of this repository.

If you are adding a substantial new file of your own, add yourself on a second
copyright line rather than replacing the existing one.

## Adding a dependency

Manymail is GPL-3.0, so a new dependency must be under a GPL-compatible
licence. Run the audit before you open the PR:

    python tool/audit_licenses.py

It exits non-zero on anything incompatible. Please also say in the PR why the
dependency earns its place — the app ships a lot of functionality on a short
list of packages and that is intentional.

## Getting set up

    flutter pub get
    dart run build_runner build --delete-conflicting-outputs
    flutter test

`build_runner` generates the drift database code; nothing compiles without it.

## Before you open a pull request

    flutter analyze            # must be clean
    flutter test               # must be green

Both are non-negotiable. If you touch the SMTP layer, test against the local
fake server rather than a real one:

    dart tool/fake_smtp_server.dart --port 2525

It scripts the awkward cases on demand — `--reject-sender` for a 5xx sender
refusal, `--transient` for a 4xx, `--reject-auth`, `--no-auth`. The integration
tests drive it directly.

## Things I will probably say no to

- Receiving mail, in any form.
- Binding the From address to the SMTP username "for safety".
- Contact autocomplete that reads the device address book. It needs a
  permission the app is proud not to ask for.
- Cloud sync or cloud backup of configuration.
- Anything that makes a password recoverable outside the Keystore.

## Things I would genuinely welcome

- iOS support. The code is already platform-clean; nobody has built or tested
  it there.
- Localisation. `flutter_localizations` is wired up and the UI strings are not
  extracted yet.
- More SASL mechanisms, particularly XOAUTH2 for providers that require it.
- Real-world SMTP quirks: servers whose replies break the current parser, with
  a transcript attached.
- Accessibility fixes. Screen-reader labelling has had no dedicated pass.

## Reporting a bug

A redacted SMTP transcript is worth more than a description. The app produces
one for you, already stripped of credentials — Settings and the send-result
sheet both expose it. Please check it before posting anyway.

Security issues go to [`SECURITY.md`](SECURITY.md), not the public tracker.
