// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/outgoing_message.dart';
import '../../providers.dart';
import '../../routing/app_router.dart';
import '../common/protocol_widgets.dart';

/// The full record of one sent message, including what the server replied.
Future<void> showSentDetailSheet({
  required BuildContext context,
  required OutgoingMessage message,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (context) => DraggableScrollableSheet(
    expand: false,
    initialChildSize: 0.7,
    maxChildSize: 0.95,
    builder: (context, controller) =>
        _SentDetailView(message: message, scrollController: controller),
  ),
);

class _SentDetailView extends ConsumerWidget {
  const _SentDetailView({
    required this.message,
    required this.scrollController,
  });

  final OutgoingMessage message;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      children: [
        Text(
          message.subject.isEmpty ? '(no subject)' : message.subject,
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 16),

        _Field(label: 'From', value: message.fromHeader, monospace: true),
        if (message.replyTo != null)
          _Field(label: 'Reply-To', value: message.replyTo!, monospace: true),
        if (message.to.isNotEmpty)
          _Field(label: 'To', value: message.to.join(', ')),
        if (message.cc.isNotEmpty)
          _Field(label: 'Cc', value: message.cc.join(', ')),
        if (message.bcc.isNotEmpty)
          _Field(
            label: 'Bcc',
            value: message.bcc.join(', '),
            note: 'Delivered through the envelope only — never in the headers.',
          ),
        _Field(
          label: 'Sent',
          value: (message.sentAt ?? message.updatedAt).toString(),
        ),
        _Field(
          label: 'Server',
          value: message.hostSnapshot.isEmpty
              ? message.domainSnapshot
              : message.hostSnapshot,
        ),
        if (message.messageId != null)
          _Field(
            label: 'Message-Id',
            value: message.messageId!,
            monospace: true,
          ),
        if (message.lastResponseLine != null)
          _Field(
            label: 'Server response',
            value: message.lastResponseLine!,
            monospace: true,
          ),

        const SizedBox(height: 12),
        Text('Message', style: theme.textTheme.titleSmall),
        const SizedBox(height: 4),
        SelectableText(
          message.bodyPlain.isEmpty ? '(empty)' : message.bodyPlain,
        ),

        const SizedBox(height: 12),
        if (message.transcript != null)
          TranscriptExpander(transcript: message.transcript!),

        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _duplicate(context, ref),
                icon: const Icon(Icons.copy_outlined),
                label: const Text('Duplicate'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: () => _resend(context, ref),
                icon: const Icon(Icons.send_outlined),
                label: const Text('Resend'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => _delete(context, ref),
          icon: const Icon(Icons.delete_outline),
          label: const Text('Delete this entry'),
        ),
      ],
    );
  }

  /// Opens a fresh draft prefilled from this message, for editing before
  /// sending.
  Future<void> _duplicate(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final copy = message.copyWith(
      id: null,
      status: MessageStatus.draft,
      createdAt: now,
      updatedAt: now,
      sentAt: null,
      messageId: null,
      transcript: null,
      lastError: null,
      lastResponseLine: null,
      retryCount: 0,
    );
    final id = await ref.read(messageRepositoryProvider).insert(copy);
    if (!context.mounted) return;
    Navigator.of(context).pop();
    context.go(Routes.editDraft(id));
  }

  /// Sends the same content to the same recipients again, via the composer so
  /// the send path and its result sheet stay identical.
  Future<void> _resend(BuildContext context, WidgetRef ref) async {
    await _duplicate(context, ref);
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final id = message.id;
    if (id == null) return;
    await ref.read(messageRepositoryProvider).delete(id);
    if (context.mounted) Navigator.of(context).pop();
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.value,
    this.monospace = false,
    this.note,
  });

  final String label;
  final String value;
  final bool monospace;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelSmall),
          SelectableText(
            value,
            style: monospace
                ? const TextStyle(fontFamily: 'monospace', fontSize: 13)
                : null,
          ),
          if (note != null)
            Text(
              note!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
        ],
      ),
    );
  }
}
