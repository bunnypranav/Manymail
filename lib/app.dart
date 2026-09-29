// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/lock/lock_gate.dart';
import 'routing/app_router.dart';

/// Manymail — many addresses, one app.
class ManymailApp extends ConsumerWidget {
  const ManymailApp({super.key});

  /// Seed for the Material 3 palette.
  ///
  /// A light blue drawn from the app icon, which is indigo. The icon's own
  /// colour is deliberately not used as the seed: at Material 3's tone 40 it
  /// lands on a dark navy, which is heavier than this app wants to feel. This
  /// hue sits between the icon's indigo and a sky blue, so the two read as
  /// related without the UI going dark.
  static const Color _seed = Color(0xFF3D7FD6);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Manymail',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      // The rich-text toolbar looks up its button tooltips here.
      localizationsDelegates: const [
        FlutterQuillLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      // Everything behind the optional app lock.
      builder: (context, child) => LockGate(child: child ?? const SizedBox()),
    );
  }

  ThemeData _theme(Brightness brightness) {
    // `vibrant` rather than the default `tonalSpot`: tonalSpot desaturates a
    // blue seed into a greyish slate, which reads darker and duller than the
    // teal it replaced. Vibrant keeps a clean, saturated accent against light
    // containers, which is the character this palette is after.
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
      dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        isDense: true,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}
