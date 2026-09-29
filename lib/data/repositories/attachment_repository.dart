// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../db/database.dart';
import '../models/message_attachment.dart';

/// Stores attachment files and their records.
///
/// Picked files are **copied** into app storage rather than referenced in
/// place: the content URI a picker hands back is short-lived, and a draft may
/// sit for days before it is sent.
class AttachmentRepository {
  AttachmentRepository(this._db);

  final ManymailDatabase _db;

  static const Uuid _uuid = Uuid();

  /// Everything attached to one message.
  Future<List<MessageAttachment>> forMessage(int messageId) async {
    final rows = await (_db.select(
      _db.attachments,
    )..where((a) => a.messageId.equals(messageId))).get();
    return rows.map(_toModel).toList();
  }

  Stream<List<MessageAttachment>> watchForMessage(int messageId) =>
      (_db.select(
        _db.attachments,
      )..where((a) => a.messageId.equals(messageId))).watch().map(
        (rows) => rows.map(_toModel).toList(),
      );

  /// Copies [source] into app storage and records it against [messageId].
  ///
  /// [inline] marks an image the HTML body references; it gets a `Content-ID`
  /// so the body can point at it with `cid:`.
  Future<MessageAttachment> add({
    required int messageId,
    required File source,
    String? fileName,
    bool inline = false,
  }) async {
    final name = fileName ?? p.basename(source.path);
    final directory = await _attachmentDirectory();

    // A folder per attachment keeps the original filename usable even when two
    // attachments share it.
    final id = _uuid.v4();
    final folder = Directory(p.join(directory.path, id));
    await folder.create(recursive: true);
    final stored = await source.copy(p.join(folder.path, name));

    final attachment = MessageAttachment(
      messageId: messageId,
      fileName: name,
      mimeType: _mimeTypeOf(name, stored),
      sizeBytes: await stored.length(),
      storedPath: stored.path,
      contentId: inline ? '$id@manymail' : null,
      isInline: inline,
    );

    final rowId = await _db
        .into(_db.attachments)
        .insert(
          AttachmentsCompanion.insert(
            messageId: messageId,
            fileName: attachment.fileName,
            mimeType: attachment.mimeType,
            sizeBytes: attachment.sizeBytes,
            storedPath: Value(attachment.storedPath),
            contentId: Value(attachment.contentId),
            isInline: Value(attachment.isInline),
          ),
        );
    return attachment.copyWith(id: rowId);
  }

  /// Removes the record and the stored bytes.
  Future<void> remove(MessageAttachment attachment) async {
    final id = attachment.id;
    if (id != null) {
      await (_db.delete(_db.attachments)..where((a) => a.id.equals(id))).go();
    }
    await _deleteFile(attachment.storedPath);
  }

  /// Discards the bytes of a sent message's attachments while keeping the
  /// record of what was attached.
  ///
  /// The sent log stays honest about names, sizes and types without the app
  /// quietly hoarding every file ever sent.
  Future<void> discardFilesFor(int messageId) async {
    final attachments = await forMessage(messageId);
    for (final attachment in attachments) {
      await _deleteFile(attachment.storedPath);
    }
    await (_db.update(
      _db.attachments,
    )..where((a) => a.messageId.equals(messageId))).write(
      const AttachmentsCompanion(storedPath: Value(null)),
    );
  }

  /// Copies every attachment of [fromMessageId] onto [toMessageId], for
  /// "duplicate" and "resend".
  Future<void> copyAll({
    required int fromMessageId,
    required int toMessageId,
  }) async {
    for (final attachment in await forMessage(fromMessageId)) {
      final path = attachment.storedPath;
      if (path == null) continue;
      final source = File(path);
      if (!source.existsSync()) continue;
      await add(
        messageId: toMessageId,
        source: source,
        fileName: attachment.fileName,
        inline: attachment.isInline,
      );
    }
  }

  /// Total size of a message's attachments, for the size warning.
  Future<int> totalSize(int messageId) async {
    final attachments = await forMessage(messageId);
    return attachments.fold<int>(0, (sum, a) => sum + a.sizeBytes);
  }

  Future<Directory> _attachmentDirectory() async {
    final base = await getApplicationDocumentsDirectory();
    final directory = Directory(p.join(base.path, 'attachments'));
    if (!directory.existsSync()) await directory.create(recursive: true);
    return directory;
  }

  Future<void> _deleteFile(String? path) async {
    if (path == null) return;
    final file = File(path);
    if (!file.existsSync()) return;
    try {
      await file.delete();
      // Remove the per-attachment folder too, so storage does not fill with
      // empty directories.
      final folder = file.parent;
      if (folder.existsSync() && folder.listSync().isEmpty) {
        await folder.delete();
      }
    } catch (_) {
      // A file we cannot delete is not worth failing a send over.
    }
  }

  /// Sniffs the type from the file's magic bytes, falling back to its
  /// extension, then to a generic binary type.
  String _mimeTypeOf(String name, File file) {
    List<int>? header;
    try {
      final raw = file.openSync();
      header = raw.readSync(defaultMagicNumbersMaxLength);
      raw.closeSync();
    } catch (_) {
      header = null;
    }
    return lookupMimeType(name, headerBytes: header) ??
        'application/octet-stream';
  }

  MessageAttachment _toModel(AttachmentRow row) => MessageAttachment(
    id: row.id,
    messageId: row.messageId,
    fileName: row.fileName,
    mimeType: row.mimeType,
    sizeBytes: row.sizeBytes,
    storedPath: row.storedPath,
    contentId: row.contentId,
    isInline: row.isInline,
  );
}
