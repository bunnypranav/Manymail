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
import 'sent_detail_sheet.dart';

/// A local record of everything successfully sent.
///
/// Nothing here comes from a server — there is no IMAP in this app. These are
/// the messages this device sent, with the identity each was sent from.
class SentLogScreen extends ConsumerStatefulWidget {
  const SentLogScreen({super.key});

  @override
  ConsumerState<SentLogScreen> createState() => _SentLogScreenState();
}

class _SentLogScreenState extends ConsumerState<SentLogScreen> {
  final _search = TextEditingController();

  /// Kept in local state and passed to the provider family, so each distinct
  /// search is its own query.
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sent = ref.watch(sentMessagesProvider(_query));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sent'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear') _confirmClearAll();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'clear', child: Text('Clear sent log')),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: TextField(
              controller: _search,
              decoration: InputDecoration(
                hintText: 'Search sender, recipient, subject or body',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _search.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _search.clear();
                          setState(() => _query = '');
                        },
                      ),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
        ),
      ),
      body: sent.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (messages) => messages.isEmpty
            ? _Empty(searching: _search.text.isNotEmpty)
            : ListView.separated(
                itemCount: messages.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) =>
                    _SentTile(message: messages[index]),
              ),
      ),
    );
  }

  Future<void> _confirmClearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear the sent log?'),
        content: const Text(
          'This deletes every record on this device. It does not recall any '
          'message that was already delivered.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await ref.read(messageRepositoryProvider).deleteAllSent();
    }
  }
}

class _SentTile extends ConsumerWidget {
  const _SentTile({required this.message});

  final OutgoingMessage message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return ListTile(
      title: Text(
        message.subject.isEmpty ? '(no subject)' : message.subject,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The From identity is shown first: which address a message went out
          // as is the thing this app is for.
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
      trailing: Text(
        _formatDate(message.sentAt ?? message.updatedAt),
        style: theme.textTheme.bodySmall,
      ),
      onTap: () => showSentDetailSheet(context: context, message: message),
    );
  }
}

/// Short relative-ish date, enough to scan a list by.
String _formatDate(DateTime when) {
  final now = DateTime.now();
  final sameDay =
      when.year == now.year && when.month == now.month && when.day == now.day;
  if (sameDay) {
    return '${when.hour.toString().padLeft(2, '0')}:'
        '${when.minute.toString().padLeft(2, '0')}';
  }
  return '${when.day}/${when.month}';
}

class _Empty extends StatelessWidget {
  const _Empty({required this.searching});

  final bool searching;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            searching ? Icons.search_off : Icons.outbox_outlined,
            size: 56,
          ),
          const SizedBox(height: 16),
          Text(
            searching ? 'Nothing matches' : 'Nothing sent yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (!searching) ...[
            const SizedBox(height: 8),
            const Text(
              'Messages you send are recorded here, with the address each one '
              'was sent from.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.go(Routes.compose),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Write a message'),
            ),
          ],
        ],
      ),
    ),
  );
}
