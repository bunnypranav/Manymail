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

import '../../core/validation/rfc5322.dart';
import '../../data/models/mail_domain.dart';
import '../../providers.dart';
import '../../routing/app_router.dart';

/// Saved identities for one domain, with reordering and delete.
class PresetListScreen extends ConsumerWidget {
  const PresetListScreen({required this.domainId, super.key});

  final int domainId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presets = ref.watch(presetsProvider(domainId));
    final domains =
        ref.watch(domainsProvider).value ?? const <MailDomain>[];
    final domain =
        domains.where((MailDomain d) => d.id == domainId).firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Identities'),
        bottom: domain == null
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(24),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8, left: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('@${domain.domain}'),
                  ),
                ),
              ),
        actions: [
          IconButton(
            tooltip: 'Add identity',
            icon: const Icon(Icons.add),
            onPressed: () => context.push(Routes.newPreset(domainId)),
          ),
        ],
      ),
      body: presets.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (items) => items.isEmpty
            ? const _Empty()
            : _PresetList(domainId: domainId, presets: items, domain: domain),
      ),
    );
  }
}

class _PresetList extends ConsumerWidget {
  const _PresetList({
    required this.domainId,
    required this.presets,
    required this.domain,
  });

  final int domainId;
  final List<IdentityPreset> presets;
  final MailDomain? domain;

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      ReorderableListView.builder(
        itemCount: presets.length,
        onReorderItem: (int oldIndex, int newIndex) {
          final ids = presets.map((IdentityPreset p) => p.id).toList();
          ids.insert(newIndex, ids.removeAt(oldIndex));
          unawaited(
            ref.read(domainRepositoryProvider).reorderPresets(ids),
          );
        },
        itemBuilder: (context, index) {
          final preset = presets[index];
          return Dismissible(
            key: ValueKey(preset.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              color: Theme.of(context).colorScheme.errorContainer,
              child: const Icon(Icons.delete_outline),
            ),
            onDismissed: (_) =>
                ref.read(domainRepositoryProvider).deletePreset(preset.id),
            child: ListTile(
              title: Text(preset.name),
              subtitle: Text(
                domain == null
                    ? '${preset.localPart}@…'
                    : formatMailbox(
                        displayName: preset.displayName,
                        localPart: preset.localPart,
                        domain: domain!.domain,
                      ),
              ),
              onTap: () =>
                  context.push(Routes.editPreset(domainId, preset.id)),
            ),
          );
        },
      );
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.all(32),
      child: Text(
        'No saved identities.\n\n'
        'Identities are shortcuts that fill in the address and display name '
        'when you write a message. You can always type something different '
        'instead.',
        textAlign: TextAlign.center,
      ),
    ),
  );
}
