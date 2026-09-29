// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

/// Shared enumerations.
///
/// These are persisted by index into SQLite, so the declaration order of every
/// enum here is part of the on-disk schema. Append new values at the end; never
/// reorder or remove.
library;

/// How the SMTP connection is secured.
enum SmtpSecurity {
  /// Plain TCP, no encryption. Credentials would travel in the clear.
  none,

  /// Connect in plain text, then issue STARTTLS to upgrade. Usually port 587.
  starttls,

  /// TLS from the first byte ("SMTPS"). Usually port 465.
  implicitTls;

  /// The conventional port for this mode, auto-filled in the domain editor and
  /// always editable afterwards.
  int get defaultPort => switch (this) {
    SmtpSecurity.none => 25,
    SmtpSecurity.starttls => 587,
    SmtpSecurity.implicitTls => 465,
  };

  String get label => switch (this) {
    SmtpSecurity.none => 'None (insecure)',
    SmtpSecurity.starttls => 'STARTTLS',
    SmtpSecurity.implicitTls => 'Implicit TLS (SSL)',
  };

  /// Whether the socket is encrypted before any credential is sent.
  bool get isEncrypted => this != SmtpSecurity.none;
}

/// Which SASL mechanism to authenticate with.
enum SmtpAuthMode {
  /// Choose from the mechanisms the server advertises in its EHLO response.
  auto,

  /// Do not authenticate at all.
  none,

  plain,
  login,
  cramMd5;

  String get label => switch (this) {
    SmtpAuthMode.auto => 'Auto-detect',
    SmtpAuthMode.none => 'No authentication',
    SmtpAuthMode.plain => 'PLAIN',
    SmtpAuthMode.login => 'LOGIN',
    SmtpAuthMode.cramMd5 => 'CRAM-MD5',
  };

  /// True when this mode sends the password in a recoverable form, making an
  /// unencrypted connection dangerous.
  bool get exposesPasswordInCleartext =>
      this == SmtpAuthMode.plain || this == SmtpAuthMode.login;
}

/// Lifecycle of a message. Drafts, outbox and sent log are one table
/// distinguished by this value.
enum MessageStatus {
  /// Being written, or saved for later.
  draft,

  /// Accepted by the user for sending, waiting for a send attempt.
  queued,

  /// A send attempt is in flight.
  sending,

  /// Accepted by the server.
  sent,

  /// Permanently rejected (5xx). Not retried automatically.
  failed;

  String get label => switch (this) {
    MessageStatus.draft => 'Draft',
    MessageStatus.queued => 'Queued',
    MessageStatus.sending => 'Sending',
    MessageStatus.sent => 'Sent',
    MessageStatus.failed => 'Failed',
  };

  /// Whether this message belongs in the Outbox screen.
  bool get isInOutbox =>
      this == MessageStatus.queued ||
      this == MessageStatus.sending ||
      this == MessageStatus.failed;
}
