// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.


import '../db/database.dart';
import '../models/app_settings.dart';

/// Reads and writes the single settings row.
///
/// The row is created by the database's migration, so reads never have to cope
/// with its absence.
class SettingsRepository {
  SettingsRepository(this._db);

  final ManymailDatabase _db;

  static const int _rowId = 1;

  Stream<AppSettings> watch() => (_db.select(
    _db.appSettingsTable,
  )..where((s) => s.id.equals(_rowId))).watchSingleOrNull().map(_toModel);

  Future<AppSettings> get() async {
    final row = await (_db.select(
      _db.appSettingsTable,
    )..where((s) => s.id.equals(_rowId))).getSingleOrNull();
    return _toModel(row);
  }

  Future<void> save(AppSettings settings) async {
    await _db
        .into(_db.appSettingsTable)
        .insertOnConflictUpdate(
          AppSettingsRow(
            id: _rowId,
            defaultDomainId: settings.defaultDomainId,
            defaultPresetId: settings.defaultPresetId,
            biometricLockEnabled: settings.biometricLockEnabled,
            attachmentWarnBytes: settings.attachmentWarnBytes,
            sentLogRetentionDays: settings.sentLogRetentionDays,
            composeHtmlByDefault: settings.composeHtmlByDefault,
            keepSentAttachments: settings.keepSentAttachments,
            defaultSignature: settings.defaultSignature,
          ),
        );
  }

  /// Applies one change without the caller having to read first.
  Future<AppSettings> update(
    AppSettings Function(AppSettings current) change,
  ) async {
    final next = change(await get());
    await save(next);
    return next;
  }

  AppSettings _toModel(AppSettingsRow? row) => row == null
      ? const AppSettings()
      : AppSettings(
          defaultDomainId: row.defaultDomainId,
          defaultPresetId: row.defaultPresetId,
          biometricLockEnabled: row.biometricLockEnabled,
          attachmentWarnBytes: row.attachmentWarnBytes,
          sentLogRetentionDays: row.sentLogRetentionDays,
          composeHtmlByDefault: row.composeHtmlByDefault,
          keepSentAttachments: row.keepSentAttachments,
          defaultSignature: row.defaultSignature,
        );
}
