// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

import 'package:drift/drift.dart';

import '../models/enums.dart';

/// A configured domain and its SMTP server.
///
/// There is deliberately no password column. SMTP passwords live only in
/// `flutter_secure_storage` (Android Keystore); this table stores
/// [credentialKeyId], an opaque handle used to look one up. Nothing in this
/// database can leak a credential.
@DataClassName('DomainRow')
class Domains extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Friendly name shown in the composer's dropdown.
  TextColumn get label => text().withLength(min: 1, max: 120)();

  /// The mail domain used to build From addresses, e.g. `example.com`.
  TextColumn get domain => text().withLength(min: 1, max: 255)();

  TextColumn get host => text().withLength(min: 1, max: 255)();
  IntColumn get port => integer()();

  /// Stored as the enum index — see the ordering warning in `enums.dart`.
  IntColumn get security => intEnum<SmtpSecurity>()();
  IntColumn get authMode => intEnum<SmtpAuthMode>()();

  TextColumn get username => text().withDefault(const Constant(''))();

  /// Secure-storage key for the password. Never the password itself.
  TextColumn get credentialKeyId => text()();

  BoolColumn get allowInsecureCertificate =>
      boolean().withDefault(const Constant(false))();
  IntColumn get timeoutSeconds => integer().withDefault(const Constant(30))();

  /// Prefilled into the composer when this domain is chosen; always editable.
  TextColumn get defaultLocalPart => text().nullable()();
  TextColumn get defaultDisplayName => text().nullable()();
  TextColumn get defaultReplyTo => text().nullable()();

  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

/// A saved identity for a domain — a convenience over the free-text fields,
/// never a constraint on them.
@DataClassName('IdentityPresetRow')
class IdentityPresets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get domainId =>
      integer().references(Domains, #id, onDelete: KeyAction.cascade)();

  TextColumn get name => text().withLength(min: 1, max: 120)();
  TextColumn get localPart => text()();
  TextColumn get displayName => text().withDefault(const Constant(''))();
  TextColumn get replyTo => text().nullable()();

  /// Overrides the global default signature when set.
  TextColumn get signature => text().nullable()();

  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

/// Drafts, outbox and sent log in one table, distinguished by [status].
@DataClassName('MessageRow')
class Messages extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get status => intEnum<MessageStatus>()();

  /// Nulled rather than cascaded when a domain is deleted, so sent history
  /// survives. The `*Snapshot` columns keep it readable afterwards.
  IntColumn get domainId => integer()
      .nullable()
      .references(Domains, #id, onDelete: KeyAction.setNull)();

  TextColumn get domainSnapshot => text().withDefault(const Constant(''))();
  TextColumn get hostSnapshot => text().withDefault(const Constant(''))();
  TextColumn get domainLabelSnapshot =>
      text().withDefault(const Constant(''))();

  // The free-form sender identity, exactly as typed in the composer.
  TextColumn get localPart => text().withDefault(const Constant(''))();
  TextColumn get displayName => text().withDefault(const Constant(''))();
  TextColumn get replyTo => text().nullable()();

  /// JSON arrays of addresses.
  TextColumn get toAddresses => text().withDefault(const Constant('[]'))();
  TextColumn get ccAddresses => text().withDefault(const Constant('[]'))();
  TextColumn get bccAddresses => text().withDefault(const Constant('[]'))();

  TextColumn get subject => text().withDefault(const Constant(''))();

  TextColumn get bodyHtml => text().nullable()();
  TextColumn get bodyPlain => text().withDefault(const Constant(''))();

  /// Quill document, so a draft reopens in the rich editor without loss.
  TextColumn get bodyDeltaJson => text().nullable()();

  BoolColumn get isHtml => boolean().withDefault(const Constant(true))();

  /// JSON object of user-supplied headers.
  TextColumn get customHeaders => text().withDefault(const Constant('{}'))();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get sentAt => dateTime().nullable()();

  /// Our summary of the last failure.
  TextColumn get lastError => text().nullable()();

  /// The server's own words, stored verbatim.
  TextColumn get lastResponseLine => text().nullable()();

  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextRetryAt => dateTime().nullable()();

  TextColumn get messageId => text().nullable()();

  /// Redacted SMTP dialogue from the last attempt.
  TextColumn get transcript => text().nullable()();
}

/// Files attached to a message, including inline images referenced by `cid:`.
@DataClassName('AttachmentRow')
class Attachments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get messageId =>
      integer().references(Messages, #id, onDelete: KeyAction.cascade)();

  TextColumn get fileName => text()();
  TextColumn get mimeType => text()();
  IntColumn get sizeBytes => integer()();

  /// Path in app storage. Null once a sent message's files are discarded.
  TextColumn get storedPath => text().nullable()();

  /// Content-ID for inline parts, without angle brackets.
  TextColumn get contentId => text().nullable()();
  BoolColumn get isInline => boolean().withDefault(const Constant(false))();
}

/// Application settings. Exactly one row, with [id] pinned to 1.
@DataClassName('AppSettingsRow')
class AppSettingsTable extends Table {
  @override
  String get tableName => 'app_settings';

  IntColumn get id => integer().withDefault(const Constant(1))();

  IntColumn get defaultDomainId => integer().nullable()();
  IntColumn get defaultPresetId => integer().nullable()();

  BoolColumn get biometricLockEnabled =>
      boolean().withDefault(const Constant(false))();

  /// Warn above this total attachment size. Default 20 MB.
  IntColumn get attachmentWarnBytes =>
      integer().withDefault(const Constant(20 * 1024 * 1024))();

  /// Days of sent history to keep. 0 means keep everything.
  IntColumn get sentLogRetentionDays =>
      integer().withDefault(const Constant(0))();

  BoolColumn get composeHtmlByDefault =>
      boolean().withDefault(const Constant(true))();

  /// Whether to keep attachment files after sending, not just their metadata.
  BoolColumn get keepSentAttachments =>
      boolean().withDefault(const Constant(false))();

  TextColumn get defaultSignature => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
