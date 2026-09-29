// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../../data/models/message_attachment.dart';

/// Renders an inline image in the editor.
///
/// Inline images are stored in the document as `cid:<contentId>` rather than a
/// file path, because that is the reference the assembled MIME message needs —
/// the `multipart/related` part is matched by Content-ID. Nothing in
/// `flutter_quill` knows how to resolve a `cid:` URL, so without this builder
/// the editor throws
///
///     UnimplementedError: Embeddable type "image" is not supported by
///     supplied embed builders.
///
/// while building the line. In a release build an exception thrown during
/// build is swallowed by `ErrorWidget`, which paints a **plain grey box** — so
/// the symptom is the entire message body going grey and unusable the moment
/// an image is inserted, with no error shown.
///
/// The fix is to resolve the `cid:` back to the attachment's file on disk.
class CidImageEmbedBuilder extends EmbedBuilder {
  const CidImageEmbedBuilder(this.attachments);

  /// The attachments of the message being composed. Inline ones carry the
  /// `contentId` that the document references.
  final List<MessageAttachment> attachments;

  @override
  String get key => BlockEmbed.imageType;

  /// Keeps an image from silently vanishing when the document is flattened to
  /// plain text, e.g. in a draft preview.
  @override
  String toPlainText(Embed node) => '[image]';

  File? _resolve(String reference) {
    if (!reference.startsWith('cid:')) {
      // A plain path can appear if a draft was written by a future version or
      // an image was pasted in. Treat it as a file path.
      final file = File(reference);
      return file.existsSync() ? file : null;
    }
    final contentId = reference.substring(4);
    for (final attachment in attachments) {
      if (attachment.contentId != contentId) continue;
      final path = attachment.storedPath;
      if (path == null) return null;
      final file = File(path);
      return file.existsSync() ? file : null;
    }
    return null;
  }

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final reference = embedContext.node.value.data;
    final file = reference is String ? _resolve(reference) : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: file == null
            ? _MissingImage(reference: '$reference')
            : ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 260),
                child: Image.file(
                  file,
                  fit: BoxFit.contain,
                  // A corrupt or unreadable file must degrade to a placeholder,
                  // never to an exception during build.
                  errorBuilder: (context, error, stack) =>
                      _MissingImage(reference: '$reference'),
                ),
              ),
      ),
    );
  }
}

/// Shown when an inline image cannot be displayed.
///
/// The message is still perfectly sendable — the attachment and its Content-ID
/// live in the database, not in the editor — so this is deliberately a quiet
/// placeholder rather than an error.
class _MissingImage extends StatelessWidget {
  const _MissingImage({required this.reference});

  final String reference;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.image_not_supported_outlined,
              size: 18, color: scheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Inline image · $reference',
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Catch-all so an embed type this app does not know about can never take the
/// editor down the way `image` did.
class UnknownEmbedBuilder extends EmbedBuilder {
  const UnknownEmbedBuilder();

  @override
  String get key => 'unknown';

  @override
  String toPlainText(Embed node) => '[${node.value.type}]';

  @override
  Widget build(BuildContext context, EmbedContext embedContext) =>
      _MissingImage(reference: embedContext.node.value.type);
}
