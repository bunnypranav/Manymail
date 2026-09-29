// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

/// Shared presentation for anything that reports what an SMTP server said.
///
/// Used by both the connection test and the send result, so the two always
/// look and behave the same.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Tone of a result banner.
enum ResultTone { success, error, warning, info }

/// A headline block: icon, title, and the server's words underneath.
class ResultBanner extends StatelessWidget {
  const ResultBanner({
    required this.icon,
    required this.tone,
    required this.title,
    required this.body,
    this.monospaceBody = false,
    super.key,
  });

  final IconData icon;
  final ResultTone tone;
  final String title;
  final String body;

  /// Set when [body] is a verbatim server reply rather than our own prose.
  final bool monospaceBody;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (background, foreground) = switch (tone) {
      ResultTone.success => (scheme.primaryContainer, scheme.onPrimaryContainer),
      ResultTone.error => (scheme.errorContainer, scheme.onErrorContainer),
      ResultTone.warning => (
        scheme.tertiaryContainer,
        scheme.onTertiaryContainer,
      ),
      ResultTone.info => (
        scheme.secondaryContainer,
        scheme.onSecondaryContainer,
      ),
    };

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: foreground, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(color: foreground),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SelectableText(
            body,
            style: TextStyle(
              color: foreground,
              fontFamily: monospaceBody ? 'monospace' : null,
              fontSize: monospaceBody ? 12 : null,
            ),
          ),
        ],
      ),
    );
  }
}

/// The redacted SMTP dialogue, with a copy button.
///
/// Credentials are already removed by `SmtpTranscript`; this only displays
/// what it was given.
class TranscriptView extends StatelessWidget {
  const TranscriptView({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SelectableText(
            text.isEmpty ? '(nothing captured)' : text,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: text));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Transcript copied')),
                );
              }
            },
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('Copy'),
          ),
        ),
      ],
    );
  }
}

/// An expander holding the transcript.
class TranscriptExpander extends StatelessWidget {
  const TranscriptExpander({required this.transcript, super.key});

  final String transcript;

  @override
  Widget build(BuildContext context) => ExpansionTile(
    tilePadding: EdgeInsets.zero,
    title: const Text('Raw SMTP transcript'),
    subtitle: const Text('Credentials are redacted'),
    children: [TranscriptView(text: transcript)],
  );
}
