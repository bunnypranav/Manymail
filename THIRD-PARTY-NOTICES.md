# Third-party notices

Manymail is licensed under the **GNU General Public License v3.0 or later**
(see [`LICENSE`](LICENSE)). It is built on the packages listed below, each of
which keeps its own licence.

Every one of the **187 packages** in the resolved dependency graph
(`pubspec.lock`) uses a licence compatible with GPL-3.0. The breakdown:

| Licence | Packages | GPL-3.0 compatible |
|---|---:|---|
| BSD-3-Clause | 115 | yes |
| MIT | 54 | yes |
| Apache-2.0 | 7 | yes — compatible with GPLv3 (not GPLv2) |
| MPL-2.0 | 4 | yes — MPL-2.0 §3.3 permits distribution under a Secondary License |
| BSD-2-Clause | 2 | yes |
| Bundled with the Flutter SDK | 5 | yes — BSD-3-Clause |

No package in the graph is under a GPL-incompatible licence.

## Direct dependencies

| Package | Version | Licence | Scope |
|---|---|---|---|
| `flutter` | SDK | BSD-3-Clause | runtime |
| `flutter_localizations` | SDK | BSD-3-Clause | runtime |
| `cupertino_icons` | 1.0.9 | MIT | runtime |
| `flutter_riverpod` | 3.4.3 | MIT | runtime |
| `drift` | 2.35.0 | MIT | runtime |
| `drift_flutter` | 0.3.1 | MIT | runtime |
| `path` | 1.9.1 | BSD-3-Clause | runtime |
| `path_provider` | 2.1.6 | BSD-3-Clause | runtime |
| `flutter_secure_storage` | 11.2.0 | BSD-3-Clause | runtime |
| `enough_mail` | 2.1.7 | MPL-2.0 | runtime — MIME construction only |
| `crypto` | 3.0.7 | BSD-3-Clause | runtime |
| `flutter_quill` | 11.6.0 | MIT | runtime |
| `vsc_quill_delta_to_html` | 1.0.5 | MIT | runtime |
| `file_picker` | 13.1.0 | MIT | runtime |
| `mime` | 2.1.0 | BSD-3-Clause | runtime |
| `receive_sharing_intent` | 1.9.0 | Apache-2.0 | runtime |
| `workmanager` | 0.10.10 | MIT | runtime |
| `connectivity_plus` | 7.3.1 | BSD-3-Clause | runtime |
| `local_auth` | 3.0.2 | BSD-3-Clause | runtime |
| `cryptography` | 2.9.0 | Apache-2.0 | runtime |
| `go_router` | 18.0.1 | BSD-3-Clause | runtime |
| `uuid` | 4.6.0 | MIT | runtime |
| `intl` | 0.20.3 | BSD-3-Clause | runtime |
| `collection` | 1.19.1 | BSD-3-Clause | runtime |
| `flutter_lints` | 6.0.0 | BSD-3-Clause | build/test only |
| `drift_dev` | 2.35.0 | MIT | build/test only |
| `build_runner` | 2.16.1 | BSD-3-Clause | build/test only |

`flutter_test` is part of the Flutter SDK and is test-only.

## A note on `enough_mail` (MPL-2.0)

MPL-2.0 is a file-level copyleft licence. Manymail does not modify any
`enough_mail` source file, so MPL-2.0 §3.2's obligation to distribute modified
files under MPL-2.0 does not arise. §3.3 expressly permits the larger work to
be distributed under a Secondary License, which includes GPL-3.0.

Manymail uses `enough_mail` for MIME message construction only — **not** for
SMTP transport. The reason is documented in
[`lib/smtp/smtp_transport.dart`](lib/smtp/smtp_transport.dart) and in the
README: its `SmtpSendMailCommand` advances from `MAIL FROM` to `RCPT TO`
without inspecting the reply, so a `5xx` sender rejection is swallowed and the
send reports success. Surfacing exactly that rejection is the point of this
app.

## Reading the licences in the app

Settings → About → **Open source licences** shows the full licence text of
every bundled package, collected at runtime by Flutter's `LicenseRegistry`.

## Regenerating this file

The audit script lives at [`tool/audit_licenses.py`](tool/audit_licenses.py):

    python tool/audit_licenses.py

It reads `pubspec.lock`, resolves each package in the local pub cache and
classifies its licence from the licence text itself.
