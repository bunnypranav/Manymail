// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/db/database.dart';
import 'data/models/app_settings.dart';
import 'data/models/mail_domain.dart';
import 'data/models/message_attachment.dart';
import 'data/models/outgoing_message.dart';
import 'data/repositories/attachment_repository.dart';
import 'data/repositories/domain_repository.dart';
import 'data/repositories/message_repository.dart';
import 'data/repositories/send_coordinator.dart';
import 'data/repositories/settings_repository.dart';
import 'data/secure/credential_store.dart';
import 'data/share_intake.dart';
import 'smtp/connection_tester.dart';
import 'smtp/send_service.dart';

/// The single database instance for the UI isolate.
///
/// The outbox worker opens its own connection in its own isolate; WAL mode
/// (set in [ManymailDatabase.migration]) lets the two coexist.
final databaseProvider = Provider<ManymailDatabase>((ref) {
  final db = ManymailDatabase();
  ref.onDispose(db.close);
  return db;
});

final credentialStoreProvider = Provider<CredentialStore>(
  (ref) => CredentialStore(),
);

final domainRepositoryProvider = Provider<DomainRepository>(
  (ref) => DomainRepository(
    ref.watch(databaseProvider),
    ref.watch(credentialStoreProvider),
  ),
);

final messageRepositoryProvider = Provider<MessageRepository>(
  (ref) => MessageRepository(ref.watch(databaseProvider)),
);

final attachmentRepositoryProvider = Provider<AttachmentRepository>(
  (ref) => AttachmentRepository(ref.watch(databaseProvider)),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(databaseProvider)),
);

/// Application preferences, live.
final settingsProvider = StreamProvider<AppSettings>(
  (ref) => ref.watch(settingsRepositoryProvider).watch(),
);

/// Share-sheet intake. Watched by the composer.
final shareIntakeProvider = Provider<ShareIntake>((ref) => ShareIntake());

final connectionTesterProvider = Provider<ConnectionTester>(
  (ref) => const ConnectionTester(),
);

final sendServiceProvider = Provider<SendService>(
  (ref) => const SendService(),
);

/// The one path a message takes to the server, used by both the composer and
/// the outbox so their behaviour cannot drift apart.
final sendCoordinatorProvider = Provider<SendCoordinator>(
  (ref) => SendCoordinator(
    messages: ref.watch(messageRepositoryProvider),
    domains: ref.watch(domainRepositoryProvider),
    sender: ref.watch(sendServiceProvider),
    attachments: ref.watch(attachmentRepositoryProvider),
  ),
);

/// All configured domains, in display order.
final domainsProvider = StreamProvider<List<MailDomain>>(
  (ref) => ref.watch(domainRepositoryProvider).watchAll(),
);

/// Identity presets for one domain.
final presetsProvider = StreamProvider.family<List<IdentityPreset>, int>(
  (ref, domainId) =>
      ref.watch(domainRepositoryProvider).watchPresets(domainId),
);

/// The domain to preselect in the composer.
final defaultDomainProvider = FutureProvider<MailDomain?>((ref) async {
  // Depend on the list so this refreshes whenever domains change.
  await ref.watch(domainsProvider.future);
  return ref.watch(domainRepositoryProvider).getDefault();
});

/// Saved drafts, newest first.
final draftsProvider = StreamProvider<List<OutgoingMessage>>(
  (ref) =>
      ref.watch(messageRepositoryProvider).watchByStatus(MessageStatus.draft),
);

/// Queued, in-flight and failed messages.
final outboxProvider = StreamProvider<List<OutgoingMessage>>(
  (ref) => ref.watch(messageRepositoryProvider).watchOutbox(),
);

/// Attachments on one message.
final messageAttachmentsProvider =
    StreamProvider.family<List<MessageAttachment>, int>(
      (ref, messageId) =>
          ref.watch(attachmentRepositoryProvider).watchForMessage(messageId),
    );

/// The sent log, filtered by the given search term ('' for everything).
final sentMessagesProvider =
    StreamProvider.family<List<OutgoingMessage>, String>(
      (ref, query) =>
          ref.watch(messageRepositoryProvider).watchSent(query: query),
    );
