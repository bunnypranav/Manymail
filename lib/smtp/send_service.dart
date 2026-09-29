// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

import '../core/transcript.dart';
import '../data/models/mail_domain.dart';
import '../data/models/message_attachment.dart';
import '../data/models/outgoing_message.dart';
import 'message_composer.dart';
import 'smtp_config.dart';
import 'smtp_failure.dart';
import 'smtp_session.dart';

/// A recipient the server refused, with its own words.
class RejectedRecipient {
  const RejectedRecipient({
    required this.address,
    required this.code,
    required this.response,
  });

  final String address;
  final int code;
  final String response;
}

/// The result of one send attempt.
class SendOutcome {
  const SendOutcome({
    required this.success,
    required this.transcript,
    this.messageId,
    this.acceptedResponse,
    this.rejectedRecipients = const [],
    this.failure,
  });

  final bool success;

  /// Redacted protocol dialogue, shown behind "details" and stored with the
  /// message.
  final String transcript;

  final String? messageId;

  /// The server's final reply to the message data, e.g. `250 2.0.0 Ok: queued`.
  final String? acceptedResponse;

  /// Recipients refused at `RCPT TO`. The message still went to the others.
  final List<RejectedRecipient> rejectedRecipients;

  final SmtpFailure? failure;

  /// Accepted for some recipients but not all.
  bool get isPartial => success && rejectedRecipients.isNotEmpty;

  /// Whether the outbox should retry automatically.
  bool get isRetryable => failure?.isRetryable ?? false;
}

/// Sends a message over SMTP.
///
/// Every reply is checked. In particular the reply to `MAIL FROM` is checked
/// *before* moving on, which is the whole reason this app does not use
/// `enough_mail`'s send sequence — see `smtp_transport.dart`.
class SendService {
  const SendService({this.composer = const MessageComposer()});

  final MessageComposer composer;

  Future<SendOutcome> send({
    required OutgoingMessage message,
    required MailDomain domain,
    String? password,
    List<MessageAttachment> attachments = const [],
  }) async {
    final transcript = SmtpTranscript();
    final built = await composer.build(message, attachments: attachments);

    if (built.recipients.isEmpty) {
      return SendOutcome(
        success: false,
        transcript: transcript.render(),
        failure: SmtpFailure(
          kind: SmtpFailureKind.permanent,
          stage: SmtpStage.recipient,
          summary: 'This message has no recipients.',
        ),
      );
    }

    SmtpSession? session;
    try {
      session = await SmtpSession.open(
        SmtpConfig.fromDomain(domain),
        password: password,
        transcript: transcript,
      );

      final transport = session.transport;

      // 1. Envelope sender — the free-form address, unmodified. A server that
      //    restricts senders refuses here, and we stop and report it rather
      //    than pressing on to RCPT TO.
      final from = await transport.mailFrom(
        built.envelopeSender,
        use8BitMime: session.capabilities.contains('8BITMIME'),
      );
      if (!from.isPositive) {
        throw SmtpFailure.fromReply(
          from,
          stage: SmtpStage.envelopeSender,
          transcript: transcript.render(),
          rejectedAddress: built.envelopeSender,
        );
      }

      // 2. Recipients. A refusal of one address does not have to sink the
      //    message, but it must never be silent, so rejects are collected and
      //    reported alongside the result.
      final rejected = <RejectedRecipient>[];
      var accepted = 0;
      for (final recipient in built.recipients) {
        final reply = await transport.rcptTo(recipient);
        if (reply.isPositive) {
          accepted++;
        } else {
          rejected.add(
            RejectedRecipient(
              address: recipient,
              code: reply.code,
              response: reply.text,
            ),
          );
        }
      }

      if (accepted == 0) {
        final first = rejected.first;
        throw SmtpFailure(
          kind: first.code >= 500
              ? SmtpFailureKind.permanent
              : SmtpFailureKind.transient,
          stage: SmtpStage.recipient,
          summary: 'Every recipient was refused.',
          code: first.code,
          serverResponse: rejected
              .map((r) => '${r.address}: ${r.response}')
              .join('\n'),
          transcript: transcript.render(),
        );
      }

      // 3. DATA — a 354 means "go ahead".
      final data = await transport.data();
      if (data.code != 354) {
        throw SmtpFailure.fromReply(
          data,
          stage: SmtpStage.data,
          transcript: transcript.render(),
        );
      }

      // 4. The message itself, then the server's verdict.
      final result = await transport.sendMessageData(built.mime);
      if (!result.isPositive) {
        throw SmtpFailure.fromReply(
          result,
          stage: SmtpStage.data,
          transcript: transcript.render(),
        );
      }

      await session.close();

      return SendOutcome(
        success: true,
        transcript: transcript.render(),
        messageId: built.messageId,
        acceptedResponse: result.text,
        rejectedRecipients: rejected,
      );
    } catch (error) {
      final failure = classifyError(
        error,
        stage: _stageOf(error),
        transcript: transcript.render(),
      );
      await session?.close(graceful: false);
      return SendOutcome(
        success: false,
        transcript: transcript.render(),
        messageId: built.messageId,
        failure: failure,
      );
    }
  }

  SmtpStage _stageOf(Object error) =>
      error is SmtpFailure ? error.stage : SmtpStage.connect;
}

/// Convenience for reading the sent-log summary line from an outcome.
extension SendOutcomeSummary on SendOutcome {
  String get headline {
    if (isPartial) {
      return 'Sent, but ${rejectedRecipients.length} recipient'
          '${rejectedRecipients.length == 1 ? ' was' : 's were'} refused';
    }
    if (success) return 'Sent';
    return failure?.summary ?? 'Send failed';
  }
}
