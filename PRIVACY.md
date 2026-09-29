# Manymail privacy policy

**Last updated: 19 September 2026**
**Applies to: Manymail for Android (`com.bunnypranav.manymail`), all versions**

## The short version

Manymail collects nothing. There is no account, no sign-up, no analytics, no
crash reporting, no advertising and no server operated by me. Everything the
app knows stays on your device, except the messages you choose to send — which
go directly to the SMTP server **you** configured, and nowhere else.

I cannot see your messages, your addresses, your domains or your passwords. Not
because I promise not to look, but because nothing is ever sent to me.

## Who is responsible

Manymail is published by **Bunny Pranav**, an individual developer.

Contact: `manymail@bunnyorg.in`

## What the app stores on your device

| What | Where | Notes |
|---|---|---|
| Domain and server settings (label, domain, host, port, security mode, username) | App-private SQLite database | Never leaves the device |
| **SMTP passwords** | **Android Keystore**, via `EncryptedSharedPreferences` | Encrypted at rest. Never written to the database, a log, an error message or an unencrypted export |
| Identity presets (local parts, display names, signatures) | App-private SQLite database | Never leaves the device |
| Drafts, queued messages and the sent log — including recipients, subjects and message bodies | App-private SQLite database | Never leaves the device |
| Attachments you add | App-private storage | Kept after sending only if you enable that setting |
| SMTP protocol transcripts | App-private SQLite database | Credentials are stripped before the transcript is ever written |
| App preferences | App-private SQLite database | Never leaves the device |

"App-private" means Android's per-app sandbox: other apps cannot read it.

## What is transmitted, and to whom

Exactly one thing: **the messages you send.**

When you tap Send, Manymail opens a connection to the SMTP server you entered
and transmits your message to it — the sender address, recipients, subject,
body and attachments — together with the username and password you saved, in
order to authenticate.

That server is yours, or your mail provider's. It is not mine. What happens to
your message after it reaches that server is governed by that provider's
privacy policy, not this one.

Manymail makes **no other network connection of any kind**. No telemetry, no
update check, no remote configuration, no font or asset fetching, no error
reporting.

## Data collected or shared with the developer or third parties

**None.**

For the purposes of Google Play's Data safety disclosure: Manymail collects no
data, shares no data, and has no data-deletion mechanism to offer because it
holds nothing about you. Uninstalling the app removes everything it stored.

## Encryption

- **In transit.** Whether your message is encrypted on its way to your SMTP
  server depends on the security mode you pick for that domain: Implicit TLS
  (usually port 465) and STARTTLS (usually port 587) are encrypted; "None"
  (usually port 25) is not. The app shows you which you have chosen and warns
  before sending credentials over an unencrypted connection.
- **"Allow insecure certificate"** is an off-by-default, per-domain setting for
  self-signed servers. Turning it on disables certificate validation for that
  domain, which means the connection can be intercepted. The app tells you so
  at the point you enable it.
- **At rest.** SMTP passwords are encrypted under the Android Keystore.
  Configuration exports you protect with a passphrase use Argon2id key
  derivation and AES-GCM-256.

## Permissions, and why each exists

| Permission | Why |
|---|---|
| `INTERNET` | To reach the SMTP servers you configure. This is the only thing it is used for. |
| `ACCESS_NETWORK_STATE` | To hold a queued message back until the device actually has a network, instead of waking up to fail. |
| `WAKE_LOCK`, `RECEIVE_BOOT_COMPLETED` | Required by Android's WorkManager so a queued message can be retried in the background and pending retries survive a reboot. |
| `USE_BIOMETRIC`, `USE_FINGERPRINT` | Only if you enable the optional app lock. No biometric data is read, stored or transmitted — Android reports only success or failure. `USE_FINGERPRINT` is the pre-Android-10 equivalent. |
| `DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` | Generated automatically by Android's own AndroidX libraries. It is a signature-level permission that only this app can hold; it grants no access to anything. |

Every one of these is granted at install time. **Manymail never shows a runtime
permission prompt**, because it never asks for anything that needs one.

Three permissions that Android's WorkManager library declares by default have
been **deliberately removed** from the app, because Manymail does not use them:
`FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_SHORT_SERVICE` and
`POST_NOTIFICATIONS`. The app runs no foreground service and posts no
notifications.

Manymail requests **no** access to your contacts, location, camera, microphone,
call logs, SMS, or the device advertising ID.

## Children

Manymail is not directed at children and collects no data from anyone,
including children under 13.

## Your rights

Because no personal data ever reaches me, there is no data of yours for me to
provide, correct, export or erase. You control all of it directly on the
device: delete individual messages or domains in the app, or uninstall it to
remove everything at once.

## Verifying any of this

Manymail is free software under the GNU General Public License v3.0. The
complete source is published at `https://github.com/bunnypranav/Manymail`. You do not have to take
these claims on trust — you can read the code, or build the app yourself and
compare it to what is on the Play Store.

## Changes to this policy

If this policy changes, the updated version will be published at the same URL
with a new "Last updated" date, and material changes will be noted in the
release notes of the version that introduces them.

## Contact

`manymail@bunnyorg.in`
