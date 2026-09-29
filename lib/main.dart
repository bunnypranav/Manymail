// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'background/outbox_scheduler.dart';
import 'core/licensing.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Makes the GPL text readable from Settings -> Open source licences,
  // alongside the licences of every bundled package.
  Licensing.registerAppLicense();

  // Registers the background entry point so a queued message can be retried
  // even after the app is closed. A failure here must not stop the app
  // starting — the outbox still works, just without automatic retries.
  try {
    await OutboxScheduler.initialize();
  } catch (error, stack) {
    debugPrint('Background retry unavailable: $error\n$stack');
  }

  runApp(const ProviderScope(child: ManymailApp()));
}
