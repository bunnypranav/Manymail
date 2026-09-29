// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

import 'package:flutter_test/flutter_test.dart';
import 'package:manymail/background/retry_policy.dart';
import 'package:manymail/data/models/outgoing_message.dart';
import 'package:manymail/data/outbox_transition.dart';
import 'package:manymail/smtp/send_service.dart';
import 'package:manymail/smtp/smtp_failure.dart';

/// The rules that decide whether a message waits, gives up, or is done.
void main() {
  final now = DateTime(2026, 9, 18, 12);

  OutgoingMessage inFlight({int retryCount = 0}) => OutgoingMessage(
    id: 1,
    status: MessageStatus.sending,
    domainId: 1,
    domainSnapshot: 'example.com',
    localPart: 'hello',
    displayName: 'Bunny Hopper',
    to: const ['someone@example.com'],
    subject: 'Test',
    retryCount: retryCount,
    createdAt: now,
    updatedAt: now,
  );

  SendOutcome failure(SmtpFailureKind kind, SmtpStage stage) => SendOutcome(
    success: false,
    transcript: 'C: EHLO',
    failure: SmtpFailure(
      kind: kind,
      stage: stage,
      summary: 'something went wrong',
      serverResponse: '550 nope',
    ),
  );

  group('accepted', () {
    test('becomes sent with no retry pending', () {
      final result = OutboxTransition.apply(
        inFlight(),
        const SendOutcome(
          success: true,
          transcript: 'S: 250 Ok',
          messageId: '<abc@example.com>',
          acceptedResponse: '250 Ok',
        ),
        now: now,
      );

      expect(result.status, MessageStatus.sent);
      expect(result.sentAt, now);
      expect(result.messageId, '<abc@example.com>');
      expect(result.lastResponseLine, '250 Ok');
      expect(result.lastError, isNull);
      expect(result.nextRetryAt, isNull);
    });
  });

  group('refused — a 5xx is final', () {
    test('a rejected sender is never retried', () {
      final result = OutboxTransition.apply(
        inFlight(),
        failure(SmtpFailureKind.permanent, SmtpStage.envelopeSender),
        now: now,
      );

      expect(result.status, MessageStatus.failed);
      expect(result.nextRetryAt, isNull);
      expect(result.retryCount, 1);
      expect(result.lastResponseLine, '550 nope');
    });

    test('a rejected login is never retried either', () {
      final result = OutboxTransition.apply(
        inFlight(),
        failure(SmtpFailureKind.permanent, SmtpStage.authenticate),
        now: now,
      );

      expect(result.status, MessageStatus.failed);
      expect(result.nextRetryAt, isNull);
    });

    test('a TLS failure is not retried, since config must change first', () {
      final result = OutboxTransition.apply(
        inFlight(),
        failure(SmtpFailureKind.tls, SmtpStage.startTls),
        now: now,
      );

      expect(result.status, MessageStatus.failed);
      expect(result.nextRetryAt, isNull);
    });
  });

  group('retryable — waits and tries again', () {
    test('a network failure stays queued with the next attempt booked', () {
      final result = OutboxTransition.apply(
        inFlight(),
        failure(SmtpFailureKind.network, SmtpStage.connect),
        now: now,
      );

      expect(result.status, MessageStatus.queued);
      expect(result.retryCount, 1);
      expect(result.nextRetryAt, now.add(const Duration(seconds: 30)));
    });

    test('a 4xx is queued, not failed', () {
      final result = OutboxTransition.apply(
        inFlight(),
        failure(SmtpFailureKind.transient, SmtpStage.envelopeSender),
        now: now,
      );

      expect(result.status, MessageStatus.queued);
      expect(result.nextRetryAt, isNotNull);
    });

    test('backs off further with each successive attempt', () {
      final first = OutboxTransition.apply(
        inFlight(),
        failure(SmtpFailureKind.network, SmtpStage.connect),
        now: now,
      );
      final second = OutboxTransition.apply(
        first.copyWith(status: MessageStatus.sending),
        failure(SmtpFailureKind.network, SmtpStage.connect),
        now: now,
      );

      expect(first.nextRetryAt, now.add(const Duration(seconds: 30)));
      expect(second.nextRetryAt, now.add(const Duration(minutes: 1)));
      expect(second.retryCount, 2);
    });

    test('gives up after the attempt limit and says so plainly', () {
      final result = OutboxTransition.apply(
        inFlight(retryCount: RetryPolicy.maxAttempts - 1),
        failure(SmtpFailureKind.network, SmtpStage.connect),
        now: now,
      );

      // Still in the outbox for a manual retry, but no longer pretending it
      // is on its way.
      expect(result.status, MessageStatus.queued);
      expect(result.retryCount, RetryPolicy.maxAttempts);
      expect(result.nextRetryAt, isNull);
      expect(result.lastError, contains('Automatic retrying stopped'));
      expect(result.lastError, contains('Retry manually'));
    });
  });

  group('the transcript survives either way', () {
    test('on success and on failure alike', () {
      final sent = OutboxTransition.apply(
        inFlight(),
        const SendOutcome(success: true, transcript: 'S: 250'),
        now: now,
      );
      final failed = OutboxTransition.apply(
        inFlight(),
        failure(SmtpFailureKind.permanent, SmtpStage.data),
        now: now,
      );

      expect(sent.transcript, 'S: 250');
      expect(failed.transcript, 'C: EHLO');
    });
  });
}
