// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

import 'dart:math';

import '../background/retry_policy.dart';
import '../smtp/send_service.dart';
import 'models/outgoing_message.dart';

/// Decides what a message becomes after a send attempt.
///
/// Pure: no database, no sockets, no clock of its own. Everything the composer,
/// a manual retry and the background worker need to agree on is decided here,
/// so the three cannot drift apart — and so the rules can be tested directly.
abstract final class OutboxTransition {
  /// Applies [outcome] to [message].
  ///
  /// The three endings:
  ///
  /// - **accepted** → `sent`, timestamped, no retry pending
  /// - **retryable** (no network, timeout, 4xx) → stays `queued` with the next
  ///   attempt booked, until the attempt limit is reached
  /// - **refused** (5xx) → `failed` with no retry, because asking the same
  ///   server the same question again cannot change the answer
  static OutgoingMessage apply(
    OutgoingMessage message,
    SendOutcome outcome, {
    required DateTime now,
    Random? jitter,
  }) {
    if (outcome.success) {
      return message.copyWith(
        status: MessageStatus.sent,
        sentAt: now,
        updatedAt: now,
        messageId: outcome.messageId,
        transcript: outcome.transcript,
        lastResponseLine: outcome.acceptedResponse,
        lastError: null,
        nextRetryAt: null,
      );
    }

    final attempts = message.retryCount + 1;

    if (!outcome.isRetryable) {
      return message.copyWith(
        status: MessageStatus.failed,
        updatedAt: now,
        transcript: outcome.transcript,
        lastError: outcome.failure?.summary,
        lastResponseLine: outcome.failure?.serverResponse,
        retryCount: attempts,
        nextRetryAt: null,
      );
    }

    final next = RetryPolicy.nextAttemptAt(attempts, now: now, jitter: jitter);
    return message.copyWith(
      status: MessageStatus.queued,
      updatedAt: now,
      transcript: outcome.transcript,
      lastResponseLine: outcome.failure?.serverResponse,
      retryCount: attempts,
      nextRetryAt: next,
      lastError: next == null
          // Out of automatic attempts. Say so plainly rather than leaving it
          // looking like it is still on its way.
          ? '${outcome.failure?.summary ?? 'Sending failed'}. '
                'Automatic retrying stopped after $attempts attempts. '
                'Retry manually once the problem is fixed.'
          : outcome.failure?.summary,
    );
  }
}
