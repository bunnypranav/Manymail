// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

import 'package:flutter/material.dart';

import '../../../data/models/message_attachment.dart';

/// Files attached to the message, with a warning once they get large.
class AttachmentList extends StatelessWidget {
  const AttachmentList({
    required this.attachments,
    required this.warnAboveBytes,
    required this.onAddFiles,
    required this.onAddInlineImage,
    required this.onRemove,
    this.allowInlineImages = true,
    super.key,
  });

  final List<MessageAttachment> attachments;

  /// Total size above which the UI warns. Large mail is routinely bounced.
  final int warnAboveBytes;

  final VoidCallback onAddFiles;
  final VoidCallback onAddInlineImage;
  final ValueChanged<MessageAttachment> onRemove;

  /// Inline images need somewhere to be referenced from, so the option is
  /// hidden in plain-text mode.
  final bool allowInlineImages;

  int get _totalBytes =>
      attachments.fold<int>(0, (sum, a) => sum + a.sizeBytes);

  bool get _isLarge => _totalBytes > warnAboveBytes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Attachments', style: theme.textTheme.labelLarge),
            const Spacer(),
            if (attachments.isNotEmpty)
              Text(
                formatBytes(_totalBytes),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _isLarge
                      ? theme.colorScheme.error
                      : theme.colorScheme.outline,
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),

        for (final attachment in attachments)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(_iconFor(attachment.mimeType)),
            title: Text(
              attachment.fileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              '${attachment.readableSize} · ${attachment.mimeType}'
              '${attachment.isInline ? ' · inline' : ''}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Remove',
              onPressed: () => onRemove(attachment),
            ),
          ),

        if (_isLarge)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_amber,
                  size: 20,
                  color: theme.colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'These attachments total ${formatBytes(_totalBytes)}. '
                    'Many servers refuse messages above '
                    '${formatBytes(warnAboveBytes)}, so this one may bounce.',
                    style: TextStyle(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),

        Wrap(
          spacing: 8,
          children: [
            TextButton.icon(
              onPressed: onAddFiles,
              icon: const Icon(Icons.attach_file),
              label: const Text('Attach files'),
            ),
            if (allowInlineImages)
              TextButton.icon(
                onPressed: onAddInlineImage,
                icon: const Icon(Icons.image_outlined),
                label: const Text('Insert image'),
              ),
          ],
        ),
      ],
    );
  }

  IconData _iconFor(String mimeType) {
    if (mimeType.startsWith('image/')) return Icons.image_outlined;
    if (mimeType.startsWith('video/')) return Icons.movie_outlined;
    if (mimeType.startsWith('audio/')) return Icons.audiotrack_outlined;
    if (mimeType.startsWith('text/')) return Icons.description_outlined;
    if (mimeType.contains('pdf')) return Icons.picture_as_pdf_outlined;
    if (mimeType.contains('zip') || mimeType.contains('compressed')) {
      return Icons.folder_zip_outlined;
    }
    return Icons.insert_drive_file_outlined;
  }
}
