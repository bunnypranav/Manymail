// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

import 'dart:async';
import 'dart:io';

import 'smtp_transport.dart';

/// Where in the SMTP conversation something went wrong.
enum SmtpStage {
  connect,
  greeting,
  ehlo,
  startTls,
  authenticate,
  envelopeSender,
  recipient,
  data,
  quit;

  String get label => switch (this) {
    SmtpStage.connect => 'Connect',
    SmtpStage.greeting => 'Server greeting',
    SmtpStage.ehlo => 'EHLO',
    SmtpStage.startTls => 'STARTTLS',
    SmtpStage.authenticate => 'Authentication',
    SmtpStage.envelopeSender => 'Sender (MAIL FROM)',
    SmtpStage.recipient => 'Recipient (RCPT TO)',
    SmtpStage.data => 'Message data',
    SmtpStage.quit => 'Disconnect',
  };
}

/// The nature of a failure, which decides whether the outbox retries.
enum SmtpFailureKind {
  /// DNS, connection refused, timeout, dropped connection. Worth retrying.
  network,

  /// TLS handshake or certificate rejection. Retrying changes nothing until
  /// the configuration does.
  tls,

  /// A 4xx reply: the server is temporarily unable. Worth retrying.
  transient,

  /// A 5xx reply: the server refuses. Retrying will not help.
  permanent,

  /// Unclassifiable. Treated as permanent so the outbox never loops.
  unknown;

  bool get isRetryable =>
      this == SmtpFailureKind.network || this == SmtpFailureKind.transient;
}

/// A failed SMTP operation, carrying the server's own words.
///
/// [serverResponse] is reproduced verbatim and is what the UI shows. It is
/// never rewritten or softened: when a server refuses a free-form sender, its
/// exact wording is the most useful thing the app can display.
class SmtpFailure implements Exception {
  SmtpFailure({
    required this.kind,
    required this.stage,
    required this.summary,
    this.code,
    this.serverResponse,
    this.transcript,
    this.rejectedAddress,
  });

  /// Builds a failure from a negative reply.
  factory SmtpFailure.fromReply(
    SmtpReply reply, {
    required SmtpStage stage,
    String? transcript,
    String? rejectedAddress,
  }) => SmtpFailure(
    kind: reply.isTransient
        ? SmtpFailureKind.transient
        : reply.isPermanent
        ? SmtpFailureKind.permanent
        : SmtpFailureKind.unknown,
    stage: stage,
    summary: reply.message.isEmpty
        ? 'The server rejected the ${stage.label} step.'
        : reply.message,
    code: reply.code,
    serverResponse: reply.text,
    transcript: transcript,
    rejectedAddress: rejectedAddress,
  );

  final SmtpFailureKind kind;
  final SmtpStage stage;

  /// Short description written by us, for the headline.
  final String summary;

  /// The SMTP reply code, when the failure came from the server.
  final int? code;

  /// The server's reply, unmodified.
  final String? serverResponse;

  /// Redacted protocol transcript, shown behind the "details" expander.
  final String? transcript;

  /// The address the server refused, when the failure was address-specific.
  final String? rejectedAddress;

  bool get isRetryable => kind.isRetryable;

  /// Whether this is the server refusing a sender identity it does not
  /// consider ours — the situation Manymail is built to make visible.
  bool get isSenderRejection =>
      stage == SmtpStage.envelopeSender && kind == SmtpFailureKind.permanent;

  /// An explanatory note shown under the verbatim error.
  String? get hint {
    if (isSenderRejection) {
      return 'Most SMTP servers only accept a From address that matches the '
          'authenticated account or one of its approved aliases. The address '
          'was sent exactly as you typed it — this is the server refusing it, '
          'not the app rewriting it. To use this address, allow it as an '
          'alias on the server, or send it through a provider that permits '
          'arbitrary senders.';
    }
    if (stage == SmtpStage.authenticate &&
        kind == SmtpFailureKind.permanent) {
      return 'The server rejected these credentials. Check the username and '
          'password, and whether this account needs an app-specific password.';
    }
    if (stage == SmtpStage.recipient) {
      return 'The server refused this recipient address.';
    }
    if (kind == SmtpFailureKind.tls) {
      return 'The server\'s certificate could not be verified. If this is a '
          'server you control with a self-signed certificate, you can allow '
          'invalid certificates for this domain — but only if you understand '
          'that it removes protection against an intercepted connection.';
    }
    return null;
  }

  @override
  String toString() => code == null
      ? '${stage.label}: $summary'
      : '${stage.label}: $code $summary';
}

/// Turns any thrown object into a classified [SmtpFailure].
SmtpFailure classifyError(
  Object error, {
  required SmtpStage stage,
  String? transcript,
}) {
  if (error is SmtpFailure) return error;

  if (error is SmtpTransportException) {
    final cause = error.cause;
    return SmtpFailure(
      kind: switch (cause) {
        HandshakeException() => SmtpFailureKind.tls,
        CertificateException() => SmtpFailureKind.tls,
        TlsException() => SmtpFailureKind.tls,
        SocketException() => SmtpFailureKind.network,
        _ => SmtpFailureKind.network,
      },
      stage: stage,
      summary: error.message,
      transcript: transcript,
    );
  }

  if (error is HandshakeException ||
      error is CertificateException ||
      error is TlsException) {
    return SmtpFailure(
      kind: SmtpFailureKind.tls,
      stage: stage,
      summary: 'TLS failed: ${_briefly(error)}',
      transcript: transcript,
    );
  }

  if (error is SocketException) {
    return SmtpFailure(
      kind: SmtpFailureKind.network,
      stage: stage,
      summary: 'Network error: ${error.message}',
      transcript: transcript,
    );
  }

  if (error is TimeoutException) {
    return SmtpFailure(
      kind: SmtpFailureKind.network,
      stage: stage,
      summary: 'Timed out waiting for the server.',
      transcript: transcript,
    );
  }

  return SmtpFailure(
    kind: SmtpFailureKind.unknown,
    stage: stage,
    summary: _briefly(error),
    transcript: transcript,
  );
}

String _briefly(Object error) {
  final text = error.toString();
  return text.length > 300 ? '${text.substring(0, 300)}…' : text;
}
