// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

import 'package:flutter/material.dart';

import '../../../smtp/send_service.dart';
import '../../common/protocol_widgets.dart';

/// Shows the outcome of a send attempt.
///
/// On failure this shows the server's reply **verbatim** rather than a
/// rewritten message, plus a note explaining what that kind of refusal usually
/// means. The full transcript is one tap away.
Future<void> showSendResultSheet({
  required BuildContext context,
  required SendOutcome outcome,
  required VoidCallback onDone,
  VoidCallback? onKeepInOutbox,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  isDismissible: false,
  enableDrag: false,
  builder: (context) => DraggableScrollableSheet(
    expand: false,
    initialChildSize: 0.6,
    maxChildSize: 0.95,
    builder: (context, controller) => _SendResultView(
      outcome: outcome,
      scrollController: controller,
      onDone: onDone,
      onKeepInOutbox: onKeepInOutbox,
    ),
  ),
);

class _SendResultView extends StatelessWidget {
  const _SendResultView({
    required this.outcome,
    required this.scrollController,
    required this.onDone,
    required this.onKeepInOutbox,
  });

  final SendOutcome outcome;
  final ScrollController scrollController;
  final VoidCallback onDone;
  final VoidCallback? onKeepInOutbox;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final failure = outcome.failure;

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      children: [
        Text(outcome.headline, style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),

        if (outcome.success)
          ResultBanner(
            icon: outcome.isPartial
                ? Icons.warning_amber
                : Icons.check_circle_outline,
            tone: outcome.isPartial ? ResultTone.warning : ResultTone.success,
            title: outcome.isPartial
                ? 'Accepted for some recipients'
                : 'The server accepted the message',
            body: outcome.acceptedResponse ?? 'Delivered to the server.',
            monospaceBody: outcome.acceptedResponse != null,
          )
        else
          ResultBanner(
            icon: Icons.error_outline,
            tone: ResultTone.error,
            title: '${failure?.stage.label ?? 'Send'} failed',
            body: (failure?.serverResponse?.isNotEmpty ?? false)
                ? failure!.serverResponse!
                : failure?.summary ?? 'Unknown error.',
            monospaceBody: failure?.serverResponse?.isNotEmpty ?? false,
          ),

        // The explanation of *why* a sender was refused is the single most
        // useful thing this screen can show.
        if (failure?.hint != null)
          ResultBanner(
            icon: Icons.info_outline,
            tone: ResultTone.info,
            title: failure!.isSenderRejection
                ? 'The server refused this sender address'
                : 'What this usually means',
            body: failure.hint!,
          ),

        if (outcome.rejectedRecipients.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text('Refused recipients', style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          for (final rejected in outcome.rejectedRecipients)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(rejected.address, style: theme.textTheme.bodyMedium),
                  SelectableText(
                    rejected.response,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
        ],

        if (outcome.messageId != null) ...[
          const SizedBox(height: 4),
          Text('Message-Id', style: theme.textTheme.labelSmall),
          SelectableText(
            outcome.messageId!,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
          const SizedBox(height: 8),
        ],

        TranscriptExpander(transcript: outcome.transcript),

        const SizedBox(height: 16),
        Row(
          children: [
            if (!outcome.success && onKeepInOutbox != null) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onKeepInOutbox!();
                  },
                  child: const Text('Keep in outbox'),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onDone();
                },
                child: Text(outcome.success ? 'Done' : 'Back to message'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
