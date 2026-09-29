// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/mail_domain.dart';
import '../../providers.dart';
import '../../routing/app_router.dart';

/// Lists configured domains with add / edit / duplicate / delete and drag
/// reordering.
class DomainListScreen extends ConsumerWidget {
  const DomainListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final domains = ref.watch(domainsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Domains'),
        actions: [
          IconButton(
            tooltip: 'Add domain',
            icon: const Icon(Icons.add),
            onPressed: () => context.push(Routes.newDomain),
          ),
        ],
      ),
      body: domains.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _ErrorView(error: error),
        data: (items) => items.isEmpty
            ? const _EmptyView()
            : _DomainList(domains: items),
      ),
    );
  }
}

class _DomainList extends ConsumerWidget {
  const _DomainList({required this.domains});

  final List<MailDomain> domains;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ReorderableListView.builder(
    padding: const EdgeInsets.only(bottom: 88),
    itemCount: domains.length,
    // onReorderItem already accounts for the removal at oldIndex.
    onReorderItem: (int oldIndex, int newIndex) {
      final ids = domains.map((MailDomain d) => d.id).toList();
      final moved = ids.removeAt(oldIndex);
      ids.insert(newIndex, moved);
      unawaited(ref.read(domainRepositoryProvider).reorder(ids));
    },
    itemBuilder: (context, index) {
      final domain = domains[index];
      return _DomainTile(key: ValueKey(domain.id), domain: domain);
    },
  );
}

class _DomainTile extends ConsumerWidget {
  const _DomainTile({required this.domain, super.key});

  final MailDomain domain;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return ListTile(
      leading: CircleAvatar(
        child: Text(domain.label.isEmpty ? '?' : domain.label[0].toUpperCase()),
      ),
      title: Row(
        children: [
          Flexible(child: Text(domain.label, overflow: TextOverflow.ellipsis)),
          if (domain.isDefault) ...[
            const SizedBox(width: 8),
            const _Chip(label: 'Default'),
          ],
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('@${domain.domain}'),
          Text(
            '${domain.host}:${domain.port} · ${domain.security.label}',
            style: theme.textTheme.bodySmall,
          ),
          if (domain.sendsCredentialsInCleartext)
            Text(
              'Credentials would be sent unencrypted',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
        ],
      ),
      isThreeLine: true,
      onTap: () => context.push(Routes.editDomain(domain.id)),
      trailing: _DomainMenu(domain: domain),
    );
  }
}

class _DomainMenu extends ConsumerWidget {
  const _DomainMenu({required this.domain});

  final MailDomain domain;

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      PopupMenuButton<String>(
        onSelected: (value) => _handle(context, ref, value),
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'edit', child: Text('Edit')),
          const PopupMenuItem(value: 'presets', child: Text('Identities')),
          const PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
          if (!domain.isDefault)
            const PopupMenuItem(value: 'default', child: Text('Make default')),
          const PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      );

  Future<void> _handle(
    BuildContext context,
    WidgetRef ref,
    String action,
  ) async {
    final repository = ref.read(domainRepositoryProvider);
    switch (action) {
      case 'edit':
        unawaited(context.push(Routes.editDomain(domain.id)));
      case 'presets':
        unawaited(context.push(Routes.presets(domain.id)));
      case 'duplicate':
        await repository.duplicate(domain.id);
      case 'default':
        await repository.setDefault(domain.id);
      case 'delete':
        await _confirmDelete(context, ref);
    }
  }

  /// Deleting a domain orphans anything that referenced it, so say how much is
  /// at stake before asking.
  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final repository = ref.read(domainRepositoryProvider);
    final referencing = await repository.referencingMessageCount(domain.id);
    if (!context.mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete "${domain.label}"?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Its saved identities and stored password will be deleted too.',
            ),
            if (referencing > 0) ...[
              const SizedBox(height: 12),
              Text(
                '$referencing message${referencing == 1 ? '' : 's'} '
                '(drafts, outbox or sent) reference this domain. '
                'They will be kept, but will no longer be able to send.',
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) await repository.delete(domain.id);
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: scheme.onSecondaryContainer,
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.alternate_email, size: 56),
          const SizedBox(height: 16),
          Text(
            'No domains yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'Add a domain and its SMTP server. You choose the address before '
            'the @ separately, every time you write a message.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.push(Routes.newDomain),
            icon: const Icon(Icons.add),
            label: const Text('Add domain'),
          ),
        ],
      ),
    ),
  );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text('Could not load domains.\n\n$error'),
    ),
  );
}
