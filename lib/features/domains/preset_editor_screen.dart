// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/validation/rfc5322.dart';
import '../../data/models/mail_domain.dart';
import '../../providers.dart';

/// Creates or edits one saved identity.
class PresetEditorScreen extends ConsumerStatefulWidget {
  const PresetEditorScreen({required this.domainId, this.presetId, super.key});

  final int domainId;

  /// Null when creating.
  final int? presetId;

  @override
  ConsumerState<PresetEditorScreen> createState() => _PresetEditorScreenState();
}

class _PresetEditorScreenState extends ConsumerState<PresetEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _localPart = TextEditingController();
  final _displayName = TextEditingController();
  final _replyTo = TextEditingController();
  final _signature = TextEditingController();

  IdentityPreset? _existing;
  bool _loading = true;

  bool get _isNew => widget.presetId == null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_isNew) {
      setState(() => _loading = false);
      return;
    }
    final presets = await ref
        .read(domainRepositoryProvider)
        .getPresets(widget.domainId);
    final preset = presets.where((p) => p.id == widget.presetId).firstOrNull;
    if (!mounted) return;
    setState(() {
      _existing = preset;
      if (preset != null) {
        _name.text = preset.name;
        _localPart.text = preset.localPart;
        _displayName.text = preset.displayName;
        _replyTo.text = preset.replyTo ?? '';
        _signature.text = preset.signature ?? '';
      }
      _loading = false;
    });
  }

  @override
  void dispose() {
    for (final c in [_name, _localPart, _displayName, _replyTo, _signature]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final repository = ref.read(domainRepositoryProvider);
    final replyTo = _replyTo.text.trim();
    final signature = _signature.text.trim();

    if (_isNew) {
      await repository.createPreset(
        widget.domainId,
        name: _name.text.trim(),
        localPart: _localPart.text.trim(),
        displayName: _displayName.text.trim(),
        replyTo: replyTo.isEmpty ? null : replyTo,
        signature: signature.isEmpty ? null : signature,
      );
    } else if (_existing != null) {
      await repository.updatePreset(
        _existing!.copyWith(
          name: _name.text.trim(),
          localPart: _localPart.text.trim(),
          displayName: _displayName.text.trim(),
          replyTo: replyTo.isEmpty ? null : replyTo,
          signature: signature.isEmpty ? null : signature,
        ),
      );
    }
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final domains =
        ref.watch(domainsProvider).value ?? const <MailDomain>[];
    final domain =
        domains.where((MailDomain d) => d.id == widget.domainId).firstOrNull;
    final preview = domain == null
        ? null
        : formatMailbox(
            displayName: _displayName.text,
            localPart: _localPart.text,
            domain: domain.domain,
          );

    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? 'New identity' : 'Edit identity'),
        actions: [
          TextButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Preset name',
                helperText: 'Shown on the quick-pick chip, e.g. "Billing"',
              ),
              validator: (v) =>
                  (v ?? '').trim().isEmpty ? 'Give the preset a name' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _localPart,
              decoration: InputDecoration(
                labelText: 'Alias',
                suffixText: domain == null ? null : '@${domain.domain}',
              ),
              autocorrect: false,
              onChanged: (_) => setState(() {}),
              validator: (v) {
                if ((v ?? '').trim().isEmpty) return 'Enter an alias';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _displayName,
              decoration: const InputDecoration(labelText: 'Display name'),
              onChanged: (_) => setState(() {}),
            ),
            if (preview != null) ...[
              const SizedBox(height: 12),
              _Preview(text: preview),
            ],
            const SizedBox(height: 12),
            TextFormField(
              controller: _replyTo,
              decoration: const InputDecoration(
                labelText: 'Reply-To (optional)',
              ),
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _signature,
              decoration: const InputDecoration(
                labelText: 'Signature override (optional)',
                helperText: 'Replaces the default signature for this identity',
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('From will read', style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 4),
          SelectableText(
            text,
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }
}
