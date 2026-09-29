// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

import 'dart:convert';

import 'package:drift/drift.dart';

import '../db/database.dart';
import '../models/outgoing_message.dart';

/// Reads and writes drafts, outbox entries and the sent log.
///
/// All three live in one table, separated by [MessageStatus]; this class is the
/// only thing that knows that.
class MessageRepository {
  MessageRepository(this._db);

  final ManymailDatabase _db;

  // ----------------------------------------------------------------- queries

  Stream<List<OutgoingMessage>> watchByStatus(MessageStatus status) =>
      (_db.select(_db.messages)
            ..where((m) => m.status.equalsValue(status))
            ..orderBy([
              (m) => OrderingTerm(
                expression: m.updatedAt,
                mode: OrderingMode.desc,
              ),
            ]))
          .watch()
          .map((rows) => rows.map(_toModel).toList());

  /// Everything in the outbox: queued, in flight, or permanently failed.
  Stream<List<OutgoingMessage>> watchOutbox() =>
      (_db.select(_db.messages)
            ..where(
              (m) => m.status.isIn([
                MessageStatus.queued.index,
                MessageStatus.sending.index,
                MessageStatus.failed.index,
              ]),
            )
            ..orderBy([
              (m) => OrderingTerm(expression: m.createdAt),
            ]))
          .watch()
          .map((rows) => rows.map(_toModel).toList());

  /// The sent log, newest first, optionally filtered by a search term.
  ///
  /// The search covers recipients, subject, body and the From identity, so
  /// "billing" finds messages sent *from* `billing@` as well as *to* it.
  Stream<List<OutgoingMessage>> watchSent({String query = ''}) {
    final select = _db.select(_db.messages)
      ..where((m) => m.status.equalsValue(MessageStatus.sent))
      ..orderBy([
        (m) => OrderingTerm(expression: m.sentAt, mode: OrderingMode.desc),
      ]);

    final term = query.trim().toLowerCase();
    if (term.isEmpty) return select.watch().map(_mapRows);

    // Filtering in Dart keeps the match rules identical to what the UI shows
    // and avoids LIKE-escaping the user's input.
    return select.watch().map(
      (rows) => rows.map(_toModel).where((m) => _matches(m, term)).toList(),
    );
  }

  List<OutgoingMessage> _mapRows(List<MessageRow> rows) =>
      rows.map(_toModel).toList();

  bool _matches(OutgoingMessage message, String term) =>
      message.subject.toLowerCase().contains(term) ||
      message.bodyPlain.toLowerCase().contains(term) ||
      message.fromHeader.toLowerCase().contains(term) ||
      message.allRecipients.any((r) => r.toLowerCase().contains(term));

  Future<OutgoingMessage?> getById(int id) async {
    final row = await (_db.select(
      _db.messages,
    )..where((m) => m.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toModel(row);
  }

  Future<int> countByStatus(MessageStatus status) async {
    final count = _db.messages.id.count();
    final row =
        await (_db.selectOnly(_db.messages)
              ..addColumns([count])
              ..where(_db.messages.status.equalsValue(status)))
            .getSingle();
    return row.read(count) ?? 0;
  }

  // ------------------------------------------------------------------ writes

  /// Inserts a new message, returning its id.
  Future<int> insert(OutgoingMessage message) =>
      _db.into(_db.messages).insert(_toCompanion(message, forInsert: true));

  /// Updates an existing message. Returns the id either way, inserting when
  /// the message has none yet — which is what draft autosave needs.
  Future<int> save(OutgoingMessage message) async {
    final id = message.id;
    if (id == null) return insert(message);
    await (_db.update(_db.messages)..where((m) => m.id.equals(id))).write(
      _toCompanion(message.copyWith(updatedAt: DateTime.now())),
    );
    return id;
  }

  Future<void> delete(int id) =>
      (_db.delete(_db.messages)..where((m) => m.id.equals(id))).go();

  Future<void> deleteAllSent() => (_db.delete(
    _db.messages,
  )..where((m) => m.status.equalsValue(MessageStatus.sent))).go();

  /// Applies retention, deleting sent messages older than [days].
  ///
  /// A [days] of 0 means keep everything.
  Future<int> pruneSentOlderThan(int days) async {
    if (days <= 0) return 0;
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return (_db.delete(_db.messages)
          ..where(
            (m) =>
                m.status.equalsValue(MessageStatus.sent) &
                m.sentAt.isSmallerThanValue(cutoff),
          ))
        .go();
  }

  // ------------------------------------------------------------------ mapping

  MessagesCompanion _toCompanion(
    OutgoingMessage m, {
    bool forInsert = false,
  }) => MessagesCompanion(
    id: forInsert || m.id == null ? const Value.absent() : Value(m.id!),
    status: Value(m.status),
    domainId: Value(m.domainId),
    domainSnapshot: Value(m.domainSnapshot),
    hostSnapshot: Value(m.hostSnapshot),
    domainLabelSnapshot: Value(m.domainLabelSnapshot),
    localPart: Value(m.localPart),
    displayName: Value(m.displayName),
    replyTo: Value(m.replyTo),
    toAddresses: Value(jsonEncode(m.to)),
    ccAddresses: Value(jsonEncode(m.cc)),
    bccAddresses: Value(jsonEncode(m.bcc)),
    subject: Value(m.subject),
    bodyHtml: Value(m.bodyHtml),
    bodyPlain: Value(m.bodyPlain),
    bodyDeltaJson: Value(m.bodyDeltaJson),
    isHtml: Value(m.isHtml),
    customHeaders: Value(jsonEncode(m.customHeaders)),
    createdAt: Value(m.createdAt),
    updatedAt: Value(m.updatedAt),
    sentAt: Value(m.sentAt),
    lastError: Value(m.lastError),
    lastResponseLine: Value(m.lastResponseLine),
    retryCount: Value(m.retryCount),
    nextRetryAt: Value(m.nextRetryAt),
    messageId: Value(m.messageId),
    transcript: Value(m.transcript),
  );

  OutgoingMessage _toModel(MessageRow row) => OutgoingMessage(
    id: row.id,
    status: row.status,
    domainId: row.domainId,
    domainSnapshot: row.domainSnapshot,
    hostSnapshot: row.hostSnapshot,
    domainLabelSnapshot: row.domainLabelSnapshot,
    localPart: row.localPart,
    displayName: row.displayName,
    replyTo: row.replyTo,
    to: _decodeList(row.toAddresses),
    cc: _decodeList(row.ccAddresses),
    bcc: _decodeList(row.bccAddresses),
    subject: row.subject,
    bodyHtml: row.bodyHtml,
    bodyPlain: row.bodyPlain,
    bodyDeltaJson: row.bodyDeltaJson,
    isHtml: row.isHtml,
    customHeaders: _decodeMap(row.customHeaders),
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    sentAt: row.sentAt,
    lastError: row.lastError,
    lastResponseLine: row.lastResponseLine,
    retryCount: row.retryCount,
    nextRetryAt: row.nextRetryAt,
    messageId: row.messageId,
    transcript: row.transcript,
  );

  /// Tolerates malformed JSON rather than making a row unreadable.
  List<String> _decodeList(String json) {
    try {
      final decoded = jsonDecode(json);
      if (decoded is! List) return const [];
      return decoded.map((e) => e.toString()).toList();
    } catch (_) {
      return const [];
    }
  }

  Map<String, String> _decodeMap(String json) {
    try {
      final decoded = jsonDecode(json);
      if (decoded is! Map) return const {};
      return decoded.map((k, v) => MapEntry(k.toString(), v.toString()));
    } catch (_) {
      return const {};
    }
  }
}
