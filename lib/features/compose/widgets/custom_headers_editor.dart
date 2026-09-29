// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

import 'package:flutter/material.dart';

import '../../../core/header_policy.dart';

/// Arbitrary `Name: value` headers for this message.
///
/// Anything is allowed except the headers the mailer builds itself — those are
/// refused with the reason shown inline, because letting one through would
/// either be silently overwritten or produce a duplicate header.
class CustomHeadersEditor extends StatefulWidget {
  const CustomHeadersEditor({
    required this.headers,
    required this.onChanged,
    super.key,
  });

  final Map<String, String> headers;
  final ValueChanged<Map<String, String>> onChanged;

  @override
  State<CustomHeadersEditor> createState() => _CustomHeadersEditorState();
}

class _CustomHeadersEditorState extends State<CustomHeadersEditor> {
  final _name = TextEditingController();
  final _value = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _value.dispose();
    super.dispose();
  }

  void _add() {
    final name = _name.text.trim();
    final value = sanitiseHeaderValue(_value.text);

    final verdict = checkHeaderName(name);
    if (verdict == HeaderVerdict.malformed ||
        verdict == HeaderVerdict.reserved) {
      setState(() => _error = headerVerdictMessage(name, verdict));
      return;
    }
    if (value.isEmpty) {
      setState(() => _error = 'Give the header a value.');
      return;
    }

    widget.onChanged({...widget.headers, name: value});
    _name.clear();
    _value.clear();
    setState(() => _error = null);
  }

  void _remove(String name) {
    final next = Map<String, String>.from(widget.headers)..remove(name);
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pendingName = _name.text.trim();
    final verdict = pendingName.isEmpty
        ? HeaderVerdict.allowed
        : checkHeaderName(pendingName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in widget.headers.entries)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(
              entry.key,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
            subtitle: Text(
              entry.value,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Remove',
              onPressed: () => _remove(entry.key),
            ),
          ),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: TextField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'Header',
                  hintText: 'X-Something',
                ),
                autocorrect: false,
                onChanged: (_) => setState(() => _error = null),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 5,
              child: TextField(
                controller: _value,
                decoration: const InputDecoration(labelText: 'Value'),
                autocorrect: false,
                onSubmitted: (_) => _add(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add header',
              onPressed: verdict == HeaderVerdict.reserved ? null : _add,
            ),
          ],
        ),

        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _error!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          )
        else if (verdict == HeaderVerdict.reserved ||
            verdict == HeaderVerdict.duplicated)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              headerVerdictMessage(pendingName, verdict)!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: verdict == HeaderVerdict.reserved
                    ? theme.colorScheme.error
                    : theme.colorScheme.tertiary,
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'X-* headers, In-Reply-To, References, List-Unsubscribe and '
              'Sender are all fine. From, To, Subject, Date and Content-* are '
              'built by the mailer.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
      ],
    );
  }
}
