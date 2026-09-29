// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

import 'dart:math';

/// When the outbox should try a failed send again.
///
/// Only *retryable* failures get here — no network, a timeout, a 4xx. A 5xx
/// refusal is marked `failed` and never scheduled, because retrying a refusal
/// just annoys the server and hides the real problem from you.
abstract final class RetryPolicy {
  /// How long to wait before the first retry.
  static const Duration baseDelay = Duration(seconds: 30);

  /// Never wait longer than this between attempts, however many have failed.
  static const Duration maxDelay = Duration(hours: 6);

  /// After this many attempts the message stops retrying on its own and waits
  /// for you. Roughly a day of escalating attempts.
  static const int maxAttempts = 10;

  /// Exponential backoff: 30s, 1m, 2m, 4m, … capped at [maxDelay].
  ///
  /// [attempt] is the number of attempts already made (1 after the first
  /// failure). [jitter] spreads retries slightly so several queued messages do
  /// not all wake at the same instant; pass a seeded [Random] in tests.
  static Duration delayAfterAttempt(int attempt, {Random? jitter}) {
    if (attempt < 1) return baseDelay;

    // Cap the exponent before shifting so the multiplication cannot overflow
    // on a message that has been failing for a long time.
    final exponent = min(attempt - 1, 20);
    final scaled = baseDelay * pow(2, exponent).toDouble();
    final capped = scaled > maxDelay ? maxDelay : scaled;

    if (jitter == null) return capped;

    // ±20%, so two messages failing together drift apart.
    final spread = capped.inMilliseconds * 0.2;
    final offset = (jitter.nextDouble() * 2 - 1) * spread;
    final withJitter = capped.inMilliseconds + offset.round();
    return Duration(milliseconds: max(1000, withJitter));
  }

  /// Whether another automatic attempt should be scheduled.
  static bool shouldRetry(int attempt) => attempt < maxAttempts;

  /// When the next attempt is due, or null when automatic retrying has given
  /// up and the message is waiting for a manual retry.
  static DateTime? nextAttemptAt(
    int attempt, {
    DateTime? now,
    Random? jitter,
  }) {
    if (!shouldRetry(attempt)) return null;
    return (now ?? DateTime.now()).add(
      delayAfterAttempt(attempt, jitter: jitter),
    );
  }

  /// A short human description of the wait, for the outbox list.
  static String describeDelay(Duration delay) {
    if (delay.inMinutes < 1) return '${delay.inSeconds}s';
    if (delay.inHours < 1) return '${delay.inMinutes}m';
    return '${delay.inHours}h';
  }
}
