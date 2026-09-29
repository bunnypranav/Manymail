// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

import 'package:drift/drift.dart';

import '../db/database.dart';
import '../models/mail_domain.dart';
import '../secure/credential_store.dart';

/// The values needed to create or update a domain.
///
/// Separate from [MailDomain] because a new domain has no id or timestamps yet,
/// and because the password travels alongside rather than inside it.
class DomainInput {
  const DomainInput({
    required this.label,
    required this.domain,
    required this.host,
    required this.port,
    required this.security,
    required this.authMode,
    required this.username,
    this.allowInsecureCertificate = false,
    this.timeoutSeconds = 30,
    this.defaultLocalPart,
    this.defaultDisplayName,
    this.defaultReplyTo,
    this.isDefault = false,
  });

  final String label;
  final String domain;
  final String host;
  final int port;
  final SmtpSecurity security;
  final SmtpAuthMode authMode;
  final String username;
  final bool allowInsecureCertificate;
  final int timeoutSeconds;
  final String? defaultLocalPart;
  final String? defaultDisplayName;
  final String? defaultReplyTo;
  final bool isDefault;
}

/// Reads and writes domains and their identity presets.
///
/// This is the only place that pairs a domain row with its stored password: it
/// holds the [CredentialStore] so that no UI or SMTP code has to know how
/// secrets are kept.
class DomainRepository {
  DomainRepository(this._db, this._credentials);

  final ManymailDatabase _db;
  final CredentialStore _credentials;

  // ---------------------------------------------------------------- domains

  Stream<List<MailDomain>> watchAll() =>
      (_db.select(_db.domains)..orderBy([
            (d) => OrderingTerm(expression: d.sortOrder),
            (d) => OrderingTerm(expression: d.label),
          ]))
          .watch()
          .map((rows) => rows.map(_toModel).toList());

  Future<List<MailDomain>> getAll() async {
    final rows =
        await (_db.select(_db.domains)..orderBy([
              (d) => OrderingTerm(expression: d.sortOrder),
              (d) => OrderingTerm(expression: d.label),
            ]))
            .get();
    return rows.map(_toModel).toList();
  }

  Future<MailDomain?> getById(int id) async {
    final row = await (_db.select(
      _db.domains,
    )..where((d) => d.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toModel(row);
  }

  /// The domain marked default, falling back to the first configured one.
  Future<MailDomain?> getDefault() async {
    final marked = await (_db.select(
      _db.domains,
    )..where((d) => d.isDefault.equals(true))).getSingleOrNull();
    if (marked != null) return _toModel(marked);
    final all = await getAll();
    return all.isEmpty ? null : all.first;
  }

  /// Creates a domain and stores its password under a freshly minted key id.
  Future<int> create(DomainInput input, {String? password}) async {
    final credentialKeyId = CredentialStore.newKeyId();
    final now = DateTime.now();
    final nextOrder = await _nextSortOrder();

    final id = await _db
        .into(_db.domains)
        .insert(
          DomainsCompanion.insert(
            label: input.label,
            domain: input.domain,
            host: input.host,
            port: input.port,
            security: input.security,
            authMode: input.authMode,
            username: Value(input.username),
            credentialKeyId: credentialKeyId,
            allowInsecureCertificate: Value(input.allowInsecureCertificate),
            timeoutSeconds: Value(input.timeoutSeconds),
            defaultLocalPart: Value(input.defaultLocalPart),
            defaultDisplayName: Value(input.defaultDisplayName),
            defaultReplyTo: Value(input.defaultReplyTo),
            isDefault: Value(input.isDefault),
            sortOrder: Value(nextOrder),
            createdAt: now,
            updatedAt: now,
          ),
        );

    await _credentials.write(credentialKeyId, password);
    if (input.isDefault) await setDefault(id);
    return id;
  }

  /// Updates a domain.
  ///
  /// The password is only touched when [changePassword] is true, so editing
  /// unrelated fields never requires re-entering — or even reading — the
  /// secret.
  Future<void> update(
    int id,
    DomainInput input, {
    bool changePassword = false,
    String? password,
  }) async {
    final existing = await getById(id);
    if (existing == null) return;

    await (_db.update(_db.domains)..where((d) => d.id.equals(id))).write(
      DomainsCompanion(
        label: Value(input.label),
        domain: Value(input.domain),
        host: Value(input.host),
        port: Value(input.port),
        security: Value(input.security),
        authMode: Value(input.authMode),
        username: Value(input.username),
        allowInsecureCertificate: Value(input.allowInsecureCertificate),
        timeoutSeconds: Value(input.timeoutSeconds),
        defaultLocalPart: Value(input.defaultLocalPart),
        defaultDisplayName: Value(input.defaultDisplayName),
        defaultReplyTo: Value(input.defaultReplyTo),
        updatedAt: Value(DateTime.now()),
      ),
    );

    if (changePassword) {
      await _credentials.write(existing.credentialKeyId, password);
    }
    if (input.isDefault) await setDefault(id);
  }

  /// Deletes a domain, its presets (by cascade) and its stored password.
  Future<void> delete(int id) async {
    final existing = await getById(id);
    await (_db.delete(_db.domains)..where((d) => d.id.equals(id))).go();
    if (existing != null) {
      await _credentials.delete(existing.credentialKeyId);
    }
  }

  /// Copies a domain and its presets.
  ///
  /// The copy gets its own credential key id and its own copy of the password,
  /// so deleting either domain later cannot strand the other.
  Future<int> duplicate(int id) async {
    final source = await getById(id);
    if (source == null) throw StateError('Domain $id not found');

    final password = await _credentials.read(source.credentialKeyId);
    final newId = await create(
      DomainInput(
        label: '${source.label} (copy)',
        domain: source.domain,
        host: source.host,
        port: source.port,
        security: source.security,
        authMode: source.authMode,
        username: source.username,
        allowInsecureCertificate: source.allowInsecureCertificate,
        timeoutSeconds: source.timeoutSeconds,
        defaultLocalPart: source.defaultLocalPart,
        defaultDisplayName: source.defaultDisplayName,
        defaultReplyTo: source.defaultReplyTo,
      ),
      password: password,
    );

    for (final preset in await getPresets(id)) {
      await createPreset(
        newId,
        name: preset.name,
        localPart: preset.localPart,
        displayName: preset.displayName,
        replyTo: preset.replyTo,
        signature: preset.signature,
      );
    }
    return newId;
  }

  /// Marks one domain as default, clearing the flag on all others.
  Future<void> setDefault(int id) async {
    await _db.transaction(() async {
      await _db
          .update(_db.domains)
          .write(const DomainsCompanion(isDefault: Value(false)));
      await (_db.update(_db.domains)..where((d) => d.id.equals(id))).write(
        const DomainsCompanion(isDefault: Value(true)),
      );
    });
  }

  /// Persists a new ordering, given domain ids in display order.
  Future<void> reorder(List<int> orderedIds) async {
    await _db.transaction(() async {
      for (var i = 0; i < orderedIds.length; i++) {
        await (_db.update(
          _db.domains,
        )..where((d) => d.id.equals(orderedIds[i]))).write(
          DomainsCompanion(sortOrder: Value(i)),
        );
      }
    });
  }

  /// Fetches the password for a domain, immediately before connecting.
  Future<String?> passwordFor(MailDomain domain) =>
      _credentials.read(domain.credentialKeyId);

  Future<bool> hasPassword(MailDomain domain) =>
      _credentials.has(domain.credentialKeyId);

  /// How many stored messages still reference this domain.
  ///
  /// Used to warn before deleting a domain that drafts or queued mail depend
  /// on.
  Future<int> referencingMessageCount(int domainId) async {
    final count = _db.messages.id.count();
    final query = _db.selectOnly(_db.messages)
      ..addColumns([count])
      ..where(_db.messages.domainId.equals(domainId));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  Future<int> _nextSortOrder() async {
    final max = _db.domains.sortOrder.max();
    final row = await (_db.selectOnly(_db.domains)..addColumns([max]))
        .getSingle();
    return (row.read(max) ?? -1) + 1;
  }

  // ---------------------------------------------------------------- presets

  Stream<List<IdentityPreset>> watchPresets(int domainId) =>
      (_db.select(_db.identityPresets)
            ..where((p) => p.domainId.equals(domainId))
            ..orderBy([(p) => OrderingTerm(expression: p.sortOrder)]))
          .watch()
          .map((rows) => rows.map(_toPresetModel).toList());

  Future<List<IdentityPreset>> getPresets(int domainId) async {
    final rows =
        await (_db.select(_db.identityPresets)
              ..where((p) => p.domainId.equals(domainId))
              ..orderBy([(p) => OrderingTerm(expression: p.sortOrder)]))
            .get();
    return rows.map(_toPresetModel).toList();
  }

  Future<int> createPreset(
    int domainId, {
    required String name,
    required String localPart,
    required String displayName,
    String? replyTo,
    String? signature,
  }) async {
    final order = await _nextPresetOrder(domainId);
    return _db
        .into(_db.identityPresets)
        .insert(
          IdentityPresetsCompanion.insert(
            domainId: domainId,
            name: name,
            localPart: localPart,
            displayName: Value(displayName),
            replyTo: Value(replyTo),
            signature: Value(signature),
            sortOrder: Value(order),
          ),
        );
  }

  Future<void> updatePreset(IdentityPreset preset) async {
    await (_db.update(
      _db.identityPresets,
    )..where((p) => p.id.equals(preset.id))).write(
      IdentityPresetsCompanion(
        name: Value(preset.name),
        localPart: Value(preset.localPart),
        displayName: Value(preset.displayName),
        replyTo: Value(preset.replyTo),
        signature: Value(preset.signature),
      ),
    );
  }

  Future<void> deletePreset(int id) =>
      (_db.delete(_db.identityPresets)..where((p) => p.id.equals(id))).go();

  Future<void> reorderPresets(List<int> orderedIds) async {
    await _db.transaction(() async {
      for (var i = 0; i < orderedIds.length; i++) {
        await (_db.update(
          _db.identityPresets,
        )..where((p) => p.id.equals(orderedIds[i]))).write(
          IdentityPresetsCompanion(sortOrder: Value(i)),
        );
      }
    });
  }

  Future<int> _nextPresetOrder(int domainId) async {
    final max = _db.identityPresets.sortOrder.max();
    final row =
        await (_db.selectOnly(_db.identityPresets)
              ..addColumns([max])
              ..where(_db.identityPresets.domainId.equals(domainId)))
            .getSingle();
    return (row.read(max) ?? -1) + 1;
  }

  // ---------------------------------------------------------------- mapping

  MailDomain _toModel(DomainRow row) => MailDomain(
    id: row.id,
    label: row.label,
    domain: row.domain,
    host: row.host,
    port: row.port,
    security: row.security,
    authMode: row.authMode,
    username: row.username,
    credentialKeyId: row.credentialKeyId,
    allowInsecureCertificate: row.allowInsecureCertificate,
    timeoutSeconds: row.timeoutSeconds,
    defaultLocalPart: row.defaultLocalPart,
    defaultDisplayName: row.defaultDisplayName,
    defaultReplyTo: row.defaultReplyTo,
    isDefault: row.isDefault,
    sortOrder: row.sortOrder,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );

  IdentityPreset _toPresetModel(IdentityPresetRow row) => IdentityPreset(
    id: row.id,
    domainId: row.domainId,
    name: row.name,
    localPart: row.localPart,
    displayName: row.displayName,
    replyTo: row.replyTo,
    signature: row.signature,
    sortOrder: row.sortOrder,
  );
}
