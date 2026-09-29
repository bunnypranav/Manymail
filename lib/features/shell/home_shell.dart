// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers.dart';
import '../../routing/app_router.dart';

/// The bottom navigation wrapper around the app's main destinations.
///
/// Compose is first because writing is what the app is for; Domains is last
/// because it is configuration you touch rarely.
class HomeShell extends ConsumerWidget {
  const HomeShell({required this.child, super.key});

  final Widget child;

  static const List<({String path, IconData icon, String label})> _tabs = [
    (path: Routes.compose, icon: Icons.edit_outlined, label: 'Write'),
    (path: Routes.drafts, icon: Icons.drafts_outlined, label: 'Drafts'),
    (path: Routes.outbox, icon: Icons.outbox_outlined, label: 'Outbox'),
    (path: Routes.sent, icon: Icons.send_outlined, label: 'Sent'),
    (path: Routes.domains, icon: Icons.dns_outlined, label: 'Domains'),
    (path: Routes.settings, icon: Icons.settings_outlined, label: 'Settings'),
  ];

  int _indexFor(String location) {
    // Longest match wins so /domains/3/edit still highlights Domains.
    var best = 0;
    var bestLength = 0;
    for (var i = 0; i < _tabs.length; i++) {
      final path = _tabs[i].path;
      if (location.startsWith(path) && path.length > bestLength) {
        best = i;
        bestLength = path.length;
      }
    }
    return best;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    final outboxCount = ref.watch(outboxProvider).value?.length ?? 0;
    final draftCount = ref.watch(draftsProvider).value?.length ?? 0;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indexFor(location),
        onDestinationSelected: (index) => context.go(_tabs[index].path),
        destinations: [
          for (var i = 0; i < _tabs.length; i++)
            NavigationDestination(
              icon: _withBadge(
                Icon(_tabs[i].icon),
                switch (_tabs[i].path) {
                  Routes.outbox => outboxCount,
                  Routes.drafts => draftCount,
                  _ => 0,
                },
              ),
              label: _tabs[i].label,
            ),
        ],
      ),
    );
  }

  Widget _withBadge(Widget icon, int count) =>
      count == 0 ? icon : Badge(label: Text('$count'), child: icon);
}
