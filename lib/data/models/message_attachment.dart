// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

/// A file attached to a message.
///
/// Inline images (those referenced from the HTML body by `cid:`) are the same
/// thing with [isInline] set and a [contentId] assigned — the difference is
/// only how the part is disposed in the MIME tree, not how it is stored.
class MessageAttachment {
  const MessageAttachment({
    required this.fileName,
    required this.mimeType,
    required this.sizeBytes,
    this.id,
    this.messageId,
    this.storedPath,
    this.contentId,
    this.isInline = false,
  });

  final int? id;
  final int? messageId;

  final String fileName;
  final String mimeType;
  final int sizeBytes;

  /// Where the bytes live in app storage. Null once a sent message's files
  /// have been discarded, leaving only the record of what was attached.
  final String? storedPath;

  /// `Content-ID` without angle brackets, for parts the HTML refers to.
  final String? contentId;

  final bool isInline;

  /// Whether the bytes are still on disk and can be sent.
  bool get isAvailable => storedPath != null;

  /// A human-readable size, e.g. `1.4 MB`.
  String get readableSize => formatBytes(sizeBytes);

  MessageAttachment copyWith({
    int? id,
    int? messageId,
    String? fileName,
    String? mimeType,
    int? sizeBytes,
    Object? storedPath = _unset,
    Object? contentId = _unset,
    bool? isInline,
  }) => MessageAttachment(
    id: id ?? this.id,
    messageId: messageId ?? this.messageId,
    fileName: fileName ?? this.fileName,
    mimeType: mimeType ?? this.mimeType,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    storedPath: storedPath == _unset ? this.storedPath : storedPath as String?,
    contentId: contentId == _unset ? this.contentId : contentId as String?,
    isInline: isInline ?? this.isInline,
  );
}

const Object _unset = Object();

/// Formats a byte count for display.
///
/// Uses binary units, because that is what a file manager will show for the
/// same file and a mismatch looks like a bug.
String formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  const units = ['KB', 'MB', 'GB'];
  var value = bytes / 1024;
  var unit = 0;
  while (value >= 1024 && unit < units.length - 1) {
    value /= 1024;
    unit++;
  }
  final rounded = value >= 10 ? value.toStringAsFixed(0) : value
      .toStringAsFixed(1);
  return '$rounded ${units[unit]}';
}
