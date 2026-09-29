// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

import 'package:workmanager/workmanager.dart';

import '../data/models/outgoing_message.dart';
import '../data/repositories/message_repository.dart';
import 'outbox_worker.dart';

/// Schedules the background outbox run.
///
/// There is deliberately **one** source of truth for when a message is tried
/// again: the `nextRetryAt` column. WorkManager is asked to wake us at the
/// earliest of those times and nothing more, so its own backoff and ours can
/// never disagree about the schedule.
class OutboxScheduler {
  const OutboxScheduler();

  /// Unique name, so re-scheduling replaces the pending run rather than
  /// stacking up a queue of duplicate wake-ups.
  static const String uniqueName = 'manymail.outbox';

  /// Registered once at startup so the retry callback exists.
  static Future<void> initialize() =>
      Workmanager().initialize(callbackDispatcher);

  /// Asks WorkManager to run the outbox after [delay], once there is a network.
  Future<void> scheduleIn(Duration delay) => Workmanager().registerOneOffTask(
    uniqueName,
    outboxTaskName,
    initialDelay: delay.isNegative ? Duration.zero : delay,
    // No point waking without a network — this work is nothing but network.
    constraints: Constraints(networkType: NetworkType.connected),
    // Replace, so the newest computed time wins.
    existingWorkPolicy: ExistingWorkPolicy.replace,
    // Applies only if the task itself fails to complete, not to message retry.
    backoffPolicy: BackoffPolicy.exponential,
    backoffPolicyDelay: const Duration(minutes: 1),
  );

  /// Works out when the next attempt is due and schedules for then.
  ///
  /// Cancels the pending run when nothing is waiting, so an empty outbox does
  /// not keep waking the device.
  Future<void> scheduleNextFrom(MessageRepository messages) async {
    final outbox = await messages.watchOutbox().first;
    final waiting = outbox
        .where((m) => m.status == MessageStatus.queued)
        .toList();

    if (waiting.isEmpty) {
      await cancel();
      return;
    }

    final now = DateTime.now();
    DateTime? earliest;
    for (final message in waiting) {
      // A queued message with no time set is due immediately.
      final at = message.nextRetryAt ?? now;
      if (earliest == null || at.isBefore(earliest)) earliest = at;
    }

    if (earliest == null) {
      await cancel();
      return;
    }
    await scheduleIn(earliest.difference(now));
  }

  /// Convenience for the moment a message is queued by the composer.
  Future<void> scheduleFor(OutgoingMessage message) {
    final at = message.nextRetryAt;
    return scheduleIn(
      at == null ? Duration.zero : at.difference(DateTime.now()),
    );
  }

  Future<void> cancel() => Workmanager().cancelByUniqueName(uniqueName);
}
