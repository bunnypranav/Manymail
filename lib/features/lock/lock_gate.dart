// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../../providers.dart';

/// Optional lock in front of the app.
///
/// This guards the *UI*, not the data: SMTP passwords are already encrypted
/// under the Android Keystore whether or not this is on. The lock is here so a
/// handed-over or unattended phone does not expose your drafts, sent log and
/// domain settings — it is not a replacement for a device passcode.
class LockGate extends ConsumerStatefulWidget {
  const LockGate({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<LockGate> createState() => _LockGateState();
}

class _LockGateState extends ConsumerState<LockGate> {
  bool _unlocked = false;
  bool _checking = true;
  bool _prompting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _evaluate();
  }

  Future<void> _evaluate() async {
    final settings = await ref.read(settingsRepositoryProvider).get();
    if (!mounted) return;

    if (!settings.biometricLockEnabled) {
      setState(() {
        _unlocked = true;
        _checking = false;
      });
      return;
    }
    setState(() => _checking = false);
    await _authenticate();
  }

  Future<void> _authenticate() async {
    if (_prompting) return;
    setState(() {
      _prompting = true;
      _error = null;
    });

    try {
      final ok = await LocalAuthentication().authenticate(
        localizedReason: 'Unlock Manymail',
        // Device credential is accepted too, so the lock still works on a
        // phone with no enrolled biometrics.
        biometricOnly: false,
        // Survive the prompt sending the app briefly to the background.
        persistAcrossBackgrounding: true,
      );
      if (!mounted) return;
      setState(() {
        _unlocked = ok;
        _prompting = false;
        _error = ok ? null : 'Not unlocked.';
      });
    } catch (error) {
      if (!mounted) return;
      // A device that cannot authenticate must not lock you out of your own
      // mail: explain, and offer a way through.
      setState(() {
        _prompting = false;
        _error = 'This device could not authenticate: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const _Blank(child: CircularProgressIndicator());
    }
    if (_unlocked) return widget.child;

    return _Blank(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 56),
            const SizedBox(height: 16),
            Text(
              'Manymail is locked',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _prompting ? null : _authenticate,
              icon: const Icon(Icons.fingerprint),
              label: const Text('Unlock'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Blank extends StatelessWidget {
  const _Blank({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: child));
}
