// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/compose/compose_screen.dart';
import '../features/domains/domain_editor_screen.dart';
import '../features/domains/domain_list_screen.dart';
import '../features/domains/preset_editor_screen.dart';
import '../features/domains/preset_list_screen.dart';
import '../features/drafts/drafts_screen.dart';
import '../features/outbox/outbox_screen.dart';
import '../features/sent/sent_log_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/shell/home_shell.dart';

/// Route paths, in one place so screens never hand-write a string.
abstract final class Routes {
  static const String compose = '/compose';
  static const String drafts = '/drafts';
  static const String outbox = '/outbox';
  static const String sent = '/sent';
  static const String domains = '/domains';
  static const String settings = '/settings';
  static const String newDomain = '/domains/new';

  static String editDraft(int id) => '/compose?draft=$id';
  static String editDomain(int id) => '/domains/$id/edit';
  static String presets(int id) => '/domains/$id/presets';
  static String newPreset(int domainId) => '/domains/$domainId/presets/new';
  static String editPreset(int domainId, int presetId) =>
      '/domains/$domainId/presets/$presetId';
}

final _shellKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>(
  (ref) => GoRouter(
    initialLocation: Routes.compose,
    routes: [
      // Destinations inside the bottom navigation bar.
      ShellRoute(
        navigatorKey: _shellKey,
        builder: (context, state, child) => HomeShell(child: child),
        routes: [
          GoRoute(
            path: Routes.compose,
            builder: (context, state) {
              final raw = state.uri.queryParameters['draft'];
              return ComposeScreen(
                // A new key per draft forces a fresh compose state when
                // switching between drafts.
                key: ValueKey(raw),
                draftId: raw == null ? null : int.tryParse(raw),
              );
            },
          ),
          GoRoute(
            path: Routes.drafts,
            builder: (context, state) => const DraftsScreen(),
          ),
          GoRoute(
            path: Routes.outbox,
            builder: (context, state) => const OutboxScreen(),
          ),
          GoRoute(
            path: Routes.sent,
            builder: (context, state) => const SentLogScreen(),
          ),
          GoRoute(
            path: Routes.domains,
            builder: (context, state) => const DomainListScreen(),
          ),
          GoRoute(
            path: Routes.settings,
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),

      // Full-screen editors, pushed over the shell.
      GoRoute(
        path: '/domains/new',
        builder: (context, state) => const DomainEditorScreen(),
      ),
      GoRoute(
        path: '/domains/:id/edit',
        builder: (context, state) => DomainEditorScreen(
          domainId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/domains/:id/presets',
        builder: (context, state) =>
            PresetListScreen(domainId: int.parse(state.pathParameters['id']!)),
        routes: [
          GoRoute(
            path: 'new',
            builder: (context, state) => PresetEditorScreen(
              domainId: int.parse(state.pathParameters['id']!),
            ),
          ),
          GoRoute(
            path: ':presetId',
            builder: (context, state) => PresetEditorScreen(
              domainId: int.parse(state.pathParameters['id']!),
              presetId: int.parse(state.pathParameters['presetId']!),
            ),
          ),
        ],
      ),
    ],
  ),
);
