// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:manymail/background/retry_policy.dart';

void main() {
  group('backoff', () {
    test('doubles from the base delay', () {
      expect(RetryPolicy.delayAfterAttempt(1), const Duration(seconds: 30));
      expect(RetryPolicy.delayAfterAttempt(2), const Duration(minutes: 1));
      expect(RetryPolicy.delayAfterAttempt(3), const Duration(minutes: 2));
      expect(RetryPolicy.delayAfterAttempt(4), const Duration(minutes: 4));
      expect(RetryPolicy.delayAfterAttempt(5), const Duration(minutes: 8));
    });

    test('never exceeds the cap, however many attempts have failed', () {
      for (final attempt in [1, 5, 10, 20, 100, 100000]) {
        expect(
          RetryPolicy.delayAfterAttempt(attempt) <= RetryPolicy.maxDelay,
          isTrue,
          reason: 'attempt $attempt',
        );
      }
    });

    test('saturates at the cap once doubling would pass it', () {
      // 30s doubles past 6h at the 11th attempt (30s * 2^10 = 8h32m).
      expect(
        RetryPolicy.delayAfterAttempt(10),
        const Duration(hours: 4, minutes: 16),
      );
      for (final attempt in [11, 20, 100, 100000]) {
        expect(
          RetryPolicy.delayAfterAttempt(attempt),
          RetryPolicy.maxDelay,
          reason: 'attempt $attempt',
        );
      }
    });

    test('is monotonic up to the cap', () {
      var previous = Duration.zero;
      for (var attempt = 1; attempt <= 12; attempt++) {
        final delay = RetryPolicy.delayAfterAttempt(attempt);
        expect(delay >= previous, isTrue, reason: 'attempt $attempt');
        previous = delay;
      }
    });

    test('treats a nonsensical attempt count as the first one', () {
      expect(RetryPolicy.delayAfterAttempt(0), RetryPolicy.baseDelay);
      expect(RetryPolicy.delayAfterAttempt(-5), RetryPolicy.baseDelay);
    });

    test('jitter stays within 20% and never goes below a second', () {
      final random = Random(42);
      for (var attempt = 1; attempt <= 8; attempt++) {
        final plain = RetryPolicy.delayAfterAttempt(attempt);
        final jittered = RetryPolicy.delayAfterAttempt(
          attempt,
          jitter: random,
        );
        final drift =
            (jittered.inMilliseconds - plain.inMilliseconds).abs();
        expect(drift, lessThanOrEqualTo(plain.inMilliseconds ~/ 5 + 1));
        expect(jittered.inMilliseconds, greaterThanOrEqualTo(1000));
      }
    });
  });

  group('giving up', () {
    test('retries until the attempt limit', () {
      expect(RetryPolicy.shouldRetry(1), isTrue);
      expect(RetryPolicy.shouldRetry(RetryPolicy.maxAttempts - 1), isTrue);
      expect(RetryPolicy.shouldRetry(RetryPolicy.maxAttempts), isFalse);
      expect(RetryPolicy.shouldRetry(RetryPolicy.maxAttempts + 5), isFalse);
    });

    test('nextAttemptAt returns null once it has given up', () {
      expect(RetryPolicy.nextAttemptAt(RetryPolicy.maxAttempts), isNull);
    });

    test('nextAttemptAt is the delay added to now', () {
      final now = DateTime(2026, 9, 18, 12);
      expect(
        RetryPolicy.nextAttemptAt(1, now: now),
        now.add(const Duration(seconds: 30)),
      );
      expect(
        RetryPolicy.nextAttemptAt(3, now: now),
        now.add(const Duration(minutes: 2)),
      );
    });
  });

  group('describeDelay', () {
    test('picks a sensible unit', () {
      expect(RetryPolicy.describeDelay(const Duration(seconds: 30)), '30s');
      expect(RetryPolicy.describeDelay(const Duration(minutes: 5)), '5m');
      expect(RetryPolicy.describeDelay(const Duration(hours: 3)), '3h');
    });
  });
}
