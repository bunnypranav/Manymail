// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import '../data/db/database.dart';
import '../data/models/outgoing_message.dart';
import '../data/repositories/attachment_repository.dart';
import '../data/repositories/domain_repository.dart';
import '../data/repositories/message_repository.dart';
import '../data/repositories/send_coordinator.dart';
import '../data/secure/credential_store.dart';
import '../smtp/send_service.dart';
import 'outbox_scheduler.dart';

/// The WorkManager task name for an outbox run.
const String outboxTaskName = 'manymail.outbox.flush';

/// Entry point WorkManager calls in a background isolate.
///
/// Must be a top-level function annotated for AOT entry, or it is tree-shaken
/// out of release builds and the task silently never runs.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName != outboxTaskName) return true;
    return const OutboxWorker().run();
  });
}

/// Sends whatever in the outbox is due.
///
/// This may run in its own isolate with the UI dead, so it builds its own
/// database connection and credential store rather than reaching for the
/// providers. The database is opened in WAL mode (see [ManymailDatabase]),
/// which is what lets this coexist with the UI isolate's connection.
class OutboxWorker {
  const OutboxWorker();

  /// Returns true when the run finished; false asks WorkManager to retry the
  /// *task* under its own backoff, which is the right answer when something
  /// went wrong at a level below any individual message.
  Future<bool> run() async {
    // Plugins are not registered in a fresh background isolate, and
    // path_provider is needed to locate the database.
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    ManymailDatabase? database;
    try {
      database = ManymailDatabase();
      final messages = MessageRepository(database);
      final coordinator = SendCoordinator(
        messages: messages,
        domains: DomainRepository(database, CredentialStore()),
        sender: const SendService(),
        attachments: AttachmentRepository(database),
      );

      for (final message in await _dueMessages(messages)) {
        // The coordinator books the next attempt (or gives up) itself, so the
        // worker does not duplicate that decision.
        await coordinator.send(message);
      }

      // Line up the next wake-up for whatever is still waiting.
      await const OutboxScheduler().scheduleNextFrom(messages);
      return true;
    } catch (_) {
      // Never let an exception escape into the platform: an uncaught error
      // here is invisible and would silently stop the outbox for good.
      return false;
    } finally {
      await database?.close();
    }
  }

  /// Queued messages whose retry time has arrived.
  Future<List<OutgoingMessage>> _dueMessages(
    MessageRepository messages,
  ) async {
    final all = await messages.watchOutbox().first;
    final now = DateTime.now();
    return all
        .where(
          (m) =>
              m.status == MessageStatus.queued &&
              (m.nextRetryAt == null || !m.nextRetryAt!.isAfter(now)),
        )
        .toList();
  }
}
