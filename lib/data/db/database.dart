// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

// The generated part file references these enums directly. A part sees only
// its parent library's own imports, not transitive ones, so importing the
// enums here is required even though `tables.dart` already does.
import '../models/enums.dart';
import 'tables.dart';

export '../models/enums.dart';
export 'tables.dart';

part 'database.g.dart';

/// Manymail's local store.
///
/// Everything the app knows lives here — there is no server sync of any kind.
/// The one exception is SMTP passwords, which are held in
/// `flutter_secure_storage` and referenced from `Domains.credentialKeyId`.
///
/// WAL is enabled so the WorkManager outbox worker, which runs in its own
/// isolate with its own connection, can read while the UI writes.
@DriftDatabase(
  tables: [Domains, IdentityPresets, Messages, Attachments, AppSettingsTable],
)
class ManymailDatabase extends _$ManymailDatabase {
  ManymailDatabase() : super(_openConnection());

  /// In-memory instance for tests.
  ManymailDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _ensureSettingsRow();
    },
    beforeOpen: (details) async {
      // Referential integrity is off by default in SQLite; the schema relies on
      // it for cascade deletes of presets and attachments.
      await customStatement('PRAGMA foreign_keys = ON');
      await customStatement('PRAGMA journal_mode = WAL');
      if (details.wasCreated) return;
      await _ensureSettingsRow();
    },
  );

  /// Guarantees the single settings row exists, so reads never have to cope
  /// with its absence.
  Future<void> _ensureSettingsRow() async {
    await into(appSettingsTable).insert(
      const AppSettingsTableCompanion(id: Value(1)),
      mode: InsertMode.insertOrIgnore,
    );
  }
}

QueryExecutor _openConnection() => driftDatabase(name: 'manymail');
