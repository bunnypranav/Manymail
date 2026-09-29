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

/// Saved and auto-saved drafts.
///
/// Anything typed into the composer lands here automatically, so a message is
/// never lost by navigating away or backgrounding the app.
class DraftsScreen extends ConsumerWidget {
  const DraftsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drafts = ref.watch(draftsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Drafts')),
      body: drafts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (items) => items.isEmpty
            ? const _Empty()
            : ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) =>
                    _DraftTile(message: items[index]),
              ),
      ),
    );
  }
}

class _DraftTile extends ConsumerWidget {
  const _DraftTile({required this.message});

  final OutgoingMessage message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Dismissible(
      key: ValueKey(message.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: theme.colorScheme.errorContainer,
        child: Icon(
          Icons.delete_outline,
          color: theme.colorScheme.onErrorContainer,
        ),
      ),
      onDismissed: (_) => _deleteWithUndo(context, ref),
      child: ListTile(
        title: Text(
          message.subject.isEmpty ? '(no subject)' : message.subject,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.fromHeader,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'to ${message.recipientSummary}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        isThreeLine: true,
        onTap: () => context.go(Routes.editDraft(message.id!)),
      ),
    );
  }

  /// Deletes immediately but keeps the record in hand, so Undo can restore it
  /// exactly rather than approximately.
  Future<void> _deleteWithUndo(BuildContext context, WidgetRef ref) async {
    final repository = ref.read(messageRepositoryProvider);
    final snapshot = message;
    await repository.delete(snapshot.id!);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Draft deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => repository.insert(snapshot.copyWith(id: null)),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.drafts_outlined, size: 56),
          const SizedBox(height: 16),
          Text('No drafts', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const Text(
            'Anything you start writing is saved here automatically.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
